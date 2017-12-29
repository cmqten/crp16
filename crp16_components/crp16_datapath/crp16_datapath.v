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
    wire    [15:0]  if_branch_addr, if_next_addr;
    wire            if_pc_src;
    
    // Stage 1 : Instruction Decode 
    reg     [15:0]  dc_instr, dc_pc;
    wire    [15:0]  dc_reg_a_in, dc_reg_b_in, dc_rf_a_out, dc_rf_b_out;
    wire    [2:0]   dc_rf_a_sel, dc_rf_b_sel;
    
    // Stage 2 : Execute or Memory 
    reg     [15:0]  em_instr, em_pc;
    reg     [15:0]  em_reg_a, em_reg_b;
    wire    [15:0]  em_alu_a, em_alu_b, em_alu_out, em_imm;
    wire    [2:0]   em_alu_op;
    wire            em_v, em_c, em_n, em_z;
    
    wire    [15:0]  em_mem_data_in, em_mem_data_out, em_mem_addr;
    wire            em_mem_read, em_mem_write;
    
    // Stage 3 : Register Writeback 
    reg     [15:0]  wb_instr, wb_pc;
    reg     [15:0]  wb_alu_reg, wb_mem_reg;
    wire    [15:0]  wb_reg_d_data;
    wire    [2:0]   wb_reg_d_sel;
    wire            wb_reg_write;
    
    
    /*==========================================================================
    Execution/Storage Modules
    ==========================================================================*/
    
    // ALU 
    crp16_alu alu (
        .op_a(em_alu_a), .op_b(em_alu_b), .op_sel(em_alu_op), .alu_out(em_alu_out),
        .v(em_v), .c(em_c), .n(em_n), .z(em_z)
    );
    
    // Register File 
    crp16_register_file register_file (
        .clock(clock), 
        .a_sel(dc_rf_a_sel), .a_val(dc_rf_a_out),
        .b_sel(dc_rf_b_sel), .b_val(dc_rf_b_out),
        .write_sel(wb_reg_d_sel), .write_val(wb_reg_d_data), .write(wb_reg_write)
    );
    
    // Memory
    assign mem_clock = clock;
    assign address_a = if_mem_addr;
    assign if_instr = q_a;
    assign address_b = em_mem_addr;
    assign data_b = em_mem_data_in;
    assign wren_b = em_mem_write;
    assign em_mem_data_out = q_b;
  
    
    /*==========================================================================
    Fetch Stage Logic
    ==========================================================================*/
    
    assign if_next_addr = if_mem_addr + 1;
    assign if_mem_addr = if_pc_src ? if_branch_addr : if_pc;
    
    
    /*==========================================================================
    Decode Stage Logic
    ==========================================================================*/
    
    assign dc_rf_a_sel = `INSTR_REGA(dc_instr);
    
    assign dc_rf_b_sel = `BRANCHC_INSTR(dc_instr) ? 
                         `INSTR_REGD(dc_instr) : `INSTR_REGB(dc_instr);
                           
    assign dc_reg_a_in = dc_rf_a_out;
    assign dc_reg_b_in = dc_rf_b_out;
    
    // Branch resolution
    //
    // Branch addresses sources:
    //   Register A : Instruction is not an immediate instruction
    //   PC + SE7 : Conditional branch (jump/call) on immediate offset
    //   PC + SE10 : Unconditional branch (jump/call) on immediate offset
    //
    // PC source :
    //   Branch address : During unconditional jump or conditional jump where 
    //     the register reduction value matches register B
    //   PC + 1 : For every other instruction
    assign if_branch_addr = `INSTR_REGOP(dc_instr) ? dc_reg_a_in :
                            `BRANCHC_INSTR(dc_instr) ? dc_pc + `SE7(dc_instr) :
                            `BRANCHUC_INSTR(dc_instr) ? dc_pc+`SE10(dc_instr) :
                             16'b0;
                         
    assign if_pc_src = `BRANCHUC_INSTR(dc_instr) | 
                       (`BRANCHC_INSTR(dc_instr) & 
                       (`INSTR_BRANCHCOND(dc_instr) ^ (|dc_reg_b_in)));
    
    
    /*==========================================================================
    Execute or Memory Stage Logic
    ==========================================================================*/
    
    // Load immediate uses the 8-bit immediate
    assign em_imm = `LOADIMM_INSTR(em_instr) ?
                     (`INSTR_SIGNED(em_instr) ? `SE8(em_instr) : 
                                                `ZE8(em_instr)) :
    
    // - Other instructions that are not load immediate use the 4-bit immediate
    // - Branch immediate values don't matter because branching doesn't use ALU
                     (`INSTR_SIGNED(em_instr) ? `SE4(em_instr) : 
                                                `ZE4(em_instr));
    
    // Load immediate uses the ALU by adding 0 and the 8-bit immediate
    assign em_alu_a = `LOADIMM_INSTR(em_instr) ? 16'b0 : em_reg_a;
    
    assign em_alu_b = `LOADIMM_INSTR(em_instr) | `INSTR_IMM(em_instr) ?
                       em_imm : em_reg_b;
    
    // - Subtraction for slt/sgt to get the result from the alu flags
    // - Addition for load immediate to add 8-bit immediate with 0
    // - Doesn't matter for everything else 
    assign em_alu_op = `ALU_INSTR(em_instr) ? `INSTR_ALUOP(em_instr) :
                       `SGT_INSTR(em_instr) ? 3'b001 : 
                       `SLT_INSTR(em_instr) ? 3'b001 : 
                       3'b000; 
    
    assign em_mem_data_in = em_reg_b;
    assign em_mem_addr = em_reg_a;
    assign em_mem_read = (stage == EXMEM) & `LOAD_INSTR(em_instr);
    assign em_mem_write = (stage == EXMEM) & `STORE_INSTR(em_instr);
    
    
    /*==========================================================================
    Writeback Stage Logic
    ==========================================================================*/
    
    assign wb_reg_d_sel = `INSTR_REGD(wb_instr);
    
    assign wb_reg_d_data = `ALU_INSTR(wb_instr) | `LOADIMM_INSTR(wb_instr) ? 
                           wb_alu_reg : em_mem_data_out;
    
    assign wb_reg_write = (stage == WB) & (`ALU_INSTR(wb_instr) | 
                          `LOADIMM_INSTR(wb_instr) | `LOAD_INSTR(wb_instr));
                
                
    always @(posedge clock)
    begin
        case (stage[1:0])
            2'd0:
            begin
                dc_instr <= if_instr;
                if_pc <= if_next_addr;
                dc_pc <= if_mem_addr;
            end
            
            2'd1:
            begin
                em_instr <= dc_instr;
                em_pc <= dc_pc;
                em_reg_a <= dc_reg_a_in;
                em_reg_b <= dc_reg_b_in;
            end
            
            2'd2:
            begin
                wb_instr <= em_instr;
                wb_pc <= em_pc;
                wb_alu_reg <= em_alu_out;
                wb_mem_reg <= em_mem_data_out;
            end
            
            2'd3:;
        endcase
        
        stage <= stage + 2'd1;
    end
    
endmodule


`endif
