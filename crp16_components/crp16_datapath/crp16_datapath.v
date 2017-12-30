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
    `define CALL_INSTR(instr)       (instr[3:0] == 4'b1010)
    `define JUMPC_INSTR(instr)      (instr[2:0] == 3'b110)
    `define JUMPUC_INSTR(instr)     (instr[3:0] == 4'b0010)
    `define LOAD_INSTR(instr)       (instr[5:0] == 6'b000001)
    `define LOADHI_INSTR(instr)     (instr[4:0] == 5'b10001)
    `define LOADIMM_INSTR(instr)    (instr[3:0] == 4'b1001)
    `define NOOP_INSTR(instr)       (instr[15:0] == 16'b0)
    `define SGT_INSTR(instr)        (instr[3:0] == 4'b1100)
    `define SLT_INSTR(instr)        (instr[3:0] == 4'b0100)
    `define STORE_INSTR(instr)      (instr[5:0] == 6'b100001)
    
    // Other encoding
    `define INSTR_ALUOP(instr)      (instr[4:2])
    `define INSTR_BRANCHCOND(instr) (instr[3])
    `define INSTR_BRANCHREG(instr)  (!instr[4])
    `define INSTR_BYTEWORD(instr)   (instr[6])
    `define INSTR_IMM(instr)        (instr[5])
    `define INSTR_LINK(instr)       (instr[3])
    `define INSTR_LOADSIGNED(instr) (instr[7])
    `define INSTR_REGA(instr)       (instr[12:10])
    `define INSTR_REGB(instr)       (instr[9:7])
    `define INSTR_REGD(instr)       (instr[15:13])
    `define INSTR_SIGNED(instr)     (instr[4])
    
    // Immediates
    // SEb : sign extend b-bit immediate
    // ZEb : zero extend b-bit immediate
    // HI8 : 8-bit immediate in the higher byte, 0 in the lower byte
    `define HI8(instr)      ({instr[12:5], 8'b0})
    `define SE4(instr)      ({{12{instr[9]}}, instr[9:6]})
    `define SE8(instr)      ({{8{instr[12]}}, instr[12:5]})
    `define SE11(instr)     ({{5{instr[15]}}, instr[15:5]})
    `define ZE4(instr)      ({12'b0, instr[9:6]})
    `define ZE8(instr)      ({8'b0, instr[12:5]})
    
    // Stages
    localparam  IF  = 2'b00;
    localparam  DC  = 2'b01;
    localparam  EM  = 2'b10;
    localparam  WB  = 2'b11;
    
    
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
    
    assign dc_rf_b_sel = `JUMPC_INSTR(dc_instr) | `LOADHI_INSTR(dc_instr) ? 
                         `INSTR_REGD(dc_instr) : `INSTR_REGB(dc_instr);
                           
    assign dc_reg_a_in = dc_rf_a_out;
    assign dc_reg_b_in = dc_rf_b_out;
    
    // Branch resolution
    //
    // Branch addresses sources:
    //   Register A : Instruction is not an immediate instruction
    //   PC + SE8 : Conditional jump on immediate offset
    //   PC + SE11 : Unconditional branch (jump/call) on immediate offset
    //
    // PC source :
    //   Branch address : During unconditional jump/call or conditional jump 
    //     where the condition register macthes the jump condition 
    //     (zero/non-zero)
    //   PC + 1 : For every other instruction
    assign if_branch_addr = `INSTR_BRANCHREG(dc_instr) ? dc_reg_a_in :
                            `CALL_INSTR(dc_instr) ? dc_pc + `SE11(dc_instr) :
                            `JUMPC_INSTR(dc_instr) ? dc_pc + `SE8(dc_instr) :
                            `JUMPUC_INSTR(dc_instr) ? dc_pc + `SE11(dc_instr) :
                             16'b0;
                         
    assign if_pc_src = `CALL_INSTR(dc_instr) | `JUMPUC_INSTR(dc_instr) |
                       (`JUMPC_INSTR(dc_instr) & 
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
    
    // - Load hi uses the ALU by adding the 8-bit immediate in the higher byte 
    //     and the lower byte of register b
    // - Load immediate uses the ALU by adding 0 and the 8-bit immediate
    assign em_alu_a = `LOADHI_INSTR(em_instr) ? `HI8(em_instr) :
                      `LOADIMM_INSTR(em_instr) ? 16'b0 : 
                      em_reg_a;
    
    
    assign em_alu_b = `LOADHI_INSTR(em_instr) ? em_reg_b[7:0] :
                      `LOADIMM_INSTR(em_instr) | `INSTR_IMM(em_instr) ? em_imm : 
                      em_reg_b;
    
    // - Subtraction for slt/sgt to get the result from the alu flags
    // - Addition for load immediate to add 8-bit immediate with 0
    // - Addition for load to add 8-bit immediate in the higher byte and lower 
    //     byte of register b
    // - Doesn't matter for everything else 
    assign em_alu_op = `ALU_INSTR(em_instr) ? `INSTR_ALUOP(em_instr) :
                       `SGT_INSTR(em_instr) ? 3'b001 : 
                       `SLT_INSTR(em_instr) ? 3'b001 : 
                       3'b000; 
    
    assign em_mem_data_in = em_reg_b;
    assign em_mem_addr = em_reg_a;
    assign em_mem_read = (stage == EM) & `LOAD_INSTR(em_instr);
    assign em_mem_write = (stage == EM) & `STORE_INSTR(em_instr);
    
    
    /*==========================================================================
    Writeback Stage Logic
    ==========================================================================*/
    
    assign wb_reg_d_sel = `INSTR_REGD(wb_instr);
    
    assign wb_reg_d_data = `LOAD_INSTR(wb_instr) ? em_mem_data_out : wb_alu_reg;
    
    assign wb_reg_write = (stage == WB) & (`ALU_INSTR(wb_instr) | 
                          `LOADIMM_INSTR(wb_instr) | `LOAD_INSTR(wb_instr) | 
                          `LOADHI_INSTR(wb_instr));
                
                
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
