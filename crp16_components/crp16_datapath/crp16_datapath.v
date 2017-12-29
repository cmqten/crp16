`ifndef CRP16_DATAPATH
`define CRP16_DATAPATH

`include "../crp16_alu/crp16_alu.v"
`include "../crp16_register_file/crp16_register_file.v"
`include "../../crp16_subcomponents/register_16_bit/register_16_bit.v"
`include "../../crp16_subcomponents/hex_decoder/hex_decoder.v"

module crp16_datapath (
    input           clock,
    
    // Asynchronous Dual-Port RAM interface
    output  [15:0]  address_a,
    output  [15:0]  address_b,
    output  [15:0]  data_a,
    output  [15:0]  data_b,
    output          wren_a,
    output          wren_b,
    input   [15:0]  q_a,
    input   [15:0]  q_b,
    output          mem_clock 
);
    /*==========================================================================
    Local Parameters, Parametrized Macros
    ==========================================================================*/
    
    // Instruction types
    `define ALU_INSTR(instr)        (instr[1:0] == 2'b11)
    `define BRANCHC_INSTR(instr)    (instr[2:0] == 3'b110)
    `define BRANCHUC_INSTR(instr)   (instr[2:0] == 3'b010)
    `define DIVIDE_INSTR(instr)     (instr[3:0] == 4'b1101)
    `define LOAD_INSTR(instr)       (instr[3:0] == 4'b0001 && !instr[5])
    `define LOADIMM_INSTR(instr)    (instr[3:0] == 4'b1001)
    `define MULTIPLY_INSTR(instr)   (instr[3:0] == 4'b0101)
    `define NOOP_INSTR(instr)       (instr[15:0] == 16'b0)
    `define SGT_INSTR(instr)        (instr[3:0] == 4'b1100)
    `define SLT_INSTR(instr)        (instr[3:0] == 4'b0100)
    `define STORE_INSTR(instr)      (instr[3:0] == 4'b0001 && instr[5])
    
    // Other encoding
    `define INSTR_ALUOP(instr)      (instr[4:2])
    `define INSTR_BRANCHCOND(instr) (instr[4])
    `define INSTR_BYTEWORD(instr)   (instr[6])
    `define INSTR_IMM(instr)        (instr[5])
    `define INSTR_LINK(instr)       (instr[3])
    `define INSTR_REGA(instr)       (instr[12:10])
    `define INSTR_REGB(instr)       (instr[9:7])
    `define INSTR_REGD(instr)       (instr[15:13])
    `define INSTR_REGOP(instr)      (!instr[5])
    `define INSTR_SIGNED(instr)     (instr[4])
    
    // Sign/zero-extended immediates
    `define SE4(instr)      ({{12{instr[9]}}, instr[9:6]})
    `define SE7(instr)      ({{9{instr[12]}}, instr[12:6]})
    `define SE8(instr)      ({{8{instr[12]}}, instr[12:5]})
    `define SE10(instr)     ({{6{instr[15]}}, instr[15:6]})
    `define ZE4(instr)      ({{12{1'b0}}, instr[9:6]})
    `define ZE8(instr)      ({{8{1'b0}}, instr[12:5]})
    
    // Stages
    localparam  IF      = 2'b00;
    localparam  DC      = 2'b01;
    localparam  EXMEM   = 2'b10;
    localparam  WB      = 2'b11;
    
    
    /*==========================================================================
    Data/Control Wires, Pipeline Registers
    ==========================================================================*/
    
    reg     [1:0]   stage = 2'd0;
    
    // Stage 0 : Instruction Fetch 
    reg     [15:0]  if_pc;
    wire    [15:0]  if_instr, if_mem_addr;
    wire    [15:0]  branch_addr, next_addr;
    wire            pc_src;
    
    // Stage 1 : Instruction Decode 
    reg     [15:0]  dc_instr, dc_pc;
    wire    [15:0]  reg_a_in, reg_b_in, regfile_a_out, regfile_b_out;
    wire    [2:0]   regfile_a_sel, regfile_b_sel;
    
    // Stage 2 : Execute or Memory 
    reg     [15:0]  ex_mem_instr, ex_mem_pc;
    reg     [15:0]  reg_a, reg_b;
    wire    [15:0]  alu_op_a, alu_op_b, alu_out, imm_op;
    wire    [2:0]   alu_op;
    wire            vflag, cflag, nflag, zflag;
    
    wire    [15:0]  mem_data_in, mem_data_out, mem_addr;
    wire            mem_read, mem_write;
    
    // Stage 3 : Register Writeback 
    reg     [15:0]  wb_instr, wb_pc;
    reg     [15:0]  alu_out_reg, mem_data_reg;
    wire    [15:0]  reg_d_data;
    wire    [2:0]   reg_d_sel;
    wire            reg_write;
    
    
    /*==========================================================================
    Execution/Storage Modules
    ==========================================================================*/
    
    // ALU 
    crp16_alu alu (
        .op_a(alu_op_a), .op_b(alu_op_b), .op_sel(alu_op), .alu_out(alu_out),
        .v(vflag), .c(cflag), .n(nflag), .z(zflag)
    );
    
    // Register File 
    crp16_register_file register_file (
        .clock(clock), 
        .a_sel(regfile_a_sel), .a_val(regfile_a_out),
        .b_sel(regfile_b_sel), .b_val(regfile_b_out),
        .write_sel(reg_d_sel), .write_val(reg_d_data), .write(reg_write)
    );
    
    // Memory
    assign mem_clock = clock;
    assign address_a = if_mem_addr;
    assign if_instr = q_a;
    assign address_b = mem_addr;
    assign data_b = mem_data_in;
    assign wren_b = mem_write;
    assign mem_data_out = q_b;
  
    
    /*==========================================================================
    Fetch Stage Logic
    ==========================================================================*/
    
    assign next_addr = if_mem_addr + 1;
    assign if_mem_addr = pc_src ? branch_addr : if_pc;
    
    
    /*==========================================================================
    Decode Stage Logic
    ==========================================================================*/
    
    assign regfile_a_sel = `INSTR_REGA(dc_instr);
    
    assign regfile_b_sel = `BRANCHC_INSTR(dc_instr) ? 
                           `INSTR_REGD(dc_instr) : `INSTR_REGB(dc_instr);
                           
    assign reg_a_in = regfile_a_out;
    assign reg_b_in = regfile_b_out;
    
    /*
    Branch resolution
    
    Branch addresses sources:
      Register A : Instruction is not an immediate instruction
      PC + SE7 : Conditional branch (jump/call) on immediate offset
      PC + SE10 : Unconditional branch (jump/call) on immediate offset
    
    PC source :
      Branch address : During unconditional jump or conditional jump where the 
        register reduction value matches register B
      PC + 1 : For every other instruction
    */
    assign branch_addr = `INSTR_REGOP(dc_instr) ? reg_a_in :
                         `BRANCHC_INSTR(dc_instr) ? dc_pc + `SE7(dc_instr) :
                         `BRANCHUC_INSTR(dc_instr) ? dc_pc + `SE10(dc_instr) :
                         16'b0;
                         
    assign pc_src = `BRANCHUC_INSTR(dc_instr) | 
                    (`BRANCHC_INSTR(dc_instr) & (`INSTR_BRANCHCOND(dc_instr) ^ 
                    (|reg_b_in)));
    
    
    /*==========================================================================
    Execute or Memory Stage Logic
    ==========================================================================*/
    
    assign imm_op = `LOADIMM_INSTR(ex_mem_instr) ?
                     (`INSTR_SIGNED(ex_mem_instr) ? `SE8(ex_mem_instr) : 
                                                    `ZE8(ex_mem_instr)) :
    
    // Other instructions that are not load immediate use the 4-bit immediate
                     (`INSTR_SIGNED(ex_mem_instr) ? `SE4(ex_mem_instr) : 
                                                    `ZE4(ex_mem_instr));
    
    assign alu_op_a = `LOADIMM_INSTR(ex_mem_instr) ? 16'b0 : reg_a;
    
    assign alu_op_b = `LOADIMM_INSTR(ex_mem_instr) | `INSTR_IMM(ex_mem_instr) ?
                      imm_op : reg_b;
                      
    assign alu_op = `ALU_INSTR(ex_mem_instr) ? `INSTR_ALUOP(ex_mem_instr) :
                    `SGT_INSTR(ex_mem_instr) ? 3'b001 : // Subtract for sgt
                    `SLT_INSTR(ex_mem_instr) ? 3'b001 : // Subtract for slt
                    3'b000; // Add for load immediate, doesn't matter for rest
    
    assign mem_data_in = reg_b;
    assign mem_addr = reg_a;
    assign mem_read = (stage == EXMEM) & `LOAD_INSTR(ex_mem_instr);
    assign mem_write = (stage == EXMEM) & `STORE_INSTR(ex_mem_instr);
    
    
    /*==========================================================================
    Writeback Stage Logic
    ==========================================================================*/
    
    assign reg_d_sel = `INSTR_REGD(wb_instr);
    
    assign reg_d_data = `ALU_INSTR(wb_instr) | `LOADIMM_INSTR(wb_instr) ? 
                        alu_out_reg : mem_data_out;
    
    assign reg_write = (stage == WB) & (`ALU_INSTR(wb_instr) | 
                       `LOADIMM_INSTR(wb_instr) | `LOAD_INSTR(wb_instr));
                
                
    always @(posedge clock)
    begin
        case (stage[1:0])
            2'd0:
            begin
                dc_instr <= if_instr;
                if_pc <= next_addr;
                dc_pc <= if_mem_addr;
            end
            
            2'd1:
            begin
                ex_mem_instr <= dc_instr;
                ex_mem_pc <= dc_pc;
                reg_a <= reg_a_in;
                reg_b <= reg_b_in;
            end
            
            2'd2:
            begin
                wb_instr <= ex_mem_instr;
                wb_pc <= ex_mem_pc;
                alu_out_reg <= alu_out;
                mem_data_reg <= mem_data_out;
            end
            
            2'd3:;
        endcase
        
        stage <= stage + 2'd1;
    end
    
endmodule


`endif
