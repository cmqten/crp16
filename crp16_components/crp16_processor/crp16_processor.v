`ifndef CRP16_PROCESSOR
`define CRP16_PROCESSOR

`include "../crp16_alu/crp16_alu.v"
`include "../crp16_register_file/crp16_register_file.v"
`include "../../crp16_subcomponents/register_16_bit/register_16_bit.v"

module crp16_processor (
    input   clock,
    input   [2:0]   reg_view_sel,
    output  [15:0]  reg_view_val,
    output  [15:0]  pc
);
    /*==========================================================================
    Local Parameters, Parametrized Macros
    ==========================================================================*/
    
    // Instruction types
    `define ALU_INSTR(instr)        (instr[1:0] == 2'b11)
    `define CALLC_INSTR(instr)      (instr[3:0] == 4'b1110)
    `define CALLUC_INSTR(instr)     (instr[3:0] == 4'b1010)
    `define DIVIDE_INSTR(instr)     (instr[3:0] == 4'b1101)
    `define JUMPC_INSTR(instr)      (instr[3:0] == 4'b0110)
    `define JUMPUC_INSTR(instr)     (instr[3:0] == 4'b0010)
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
    `define INSTR_IMM4(instr)       (instr[9:6])
    `define INSTR_IMM7(instr)       (instr[12:6])
    `define INSTR_IMM8(instr)       (instr[12:5])
    `define INSTR_IMM10(instr)      (instr[15:6])
    `define INSTR_IMMOP(instr)      (instr[5])
    `define INSTR_REGA(instr)       (instr[12:10])
    `define INSTR_REGB(instr)       (instr[9:7])
    `define INSTR_REGD(instr)       (instr[15:13])
    `define INSTR_SIGNED(instr)     (instr[4])
    
    // Functions
    `define SIGN_EXTEND(data, width) ({(16-width){data[width-1]}, data})
    `define ZERO_EXTEND(data, width) ({(16-width){1'b0}, data})
    
    // Stages
    localparam  IF      = 2'b00;
    localparam  DC      = 2'b01;
    localparam  EXMEM   = 2'b10;
    localparam  WB      = 2'b11;
    
    /*==========================================================================
    Data/Control Wires, Pipeline Registers
    ==========================================================================*/
    
    reg     [1:0]   stage = 2'b0;
    
    // Stage 0 : Instruction Fetch 
    reg     [15:0]  if_pc;
    wire    [15:0]  if_instr, if_mem_addr;
    wire            if_mem_read, pc_src;
    wire    [15:0]  branch_addr, next_addr;
    
    // Stage 1 : Instruction Decode 
    reg     [15:0]  dc_instr, dc_pc;
    reg     [15:0]  reg_a, reg_b;
    wire    [15:0]  reg_a_in, reg_b_in, regfile_a_out, regfile_b_out;
    wire    [2:0]   regfile_a_sel, regfile_b_sel;
    
    // Stage 2 : Execute or Memory 
    reg     [15:0]  ex_instr, ex_pc;
    reg     [15:0]  alu_out_reg, mem_data_reg;
    wire    [15:0]  alu_op_a, alu_op_b, alu_out, mem_data, mem_data_addr;
    wire    [2:0]   alu_op;
    wire            v, c, n ,z;
    
    // Stage 3 : Register Writeback 
    reg     [15:0]  wb_instr, wb_pc;
    wire    [15:0]  reg_d_data;
    wire    [2:0]   reg_d_sel;
    wire            reg_write;
    
    
    /*==========================================================================
    Execution/Storage Modules
    ==========================================================================*/
    
    // ALU 
    crp16_alu alu (
        .op_a(alu_op_a), .op_b(alu_op_b), .op_sel(alu_op), .alu_out(alu_out),
        .v(v), .c(c), .n(n), .z(z)
    );
    
    // Register File 
    crp16_register_file register_file (
        .clock(clock), 
        .a_sel(regfile_a_sel), .a_val(regfile_a_out),
        .b_sel(regfile_b_sel), .b_val(regfile_b_out),
        .c_sel(reg_view_sel), .c_val(reg_view_val),
        .write_sel(reg_d_sel), .write_val(reg_d_data), .write(reg_write)
    );
    
    
    /*==========================================================================
    Data/Control/Pipeline Logic
    ==========================================================================*/
    
    // Fetch 
    assign next_addr = if_mem_addr + 1;
    assign if_mem_addr = pc_src ? branch_addr : if_pc;
    assign if_mem_read = stage == IF;
    
    // Decode
    assign regfile_a_sel = `INSTR_REGA(dc_instr);
    assign regfile_b_sel = `CALLC_INSTR(dc_instr) | `JUMPC_INSTR(dc_instr) ? 
                           `INSTR_REGD(dc_instr) : `INSTR_REGB(dc_instr);
    assign reg_a_in = regfile_a_out;
    assign reg_b_in = regfile_b_out;
    
endmodule

`endif
