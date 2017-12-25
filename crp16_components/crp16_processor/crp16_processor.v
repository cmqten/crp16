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
    Data/Control Wires, Pipeline Registers
    ==========================================================================*/
    
    // Stage 0 : Instruction Fetch 
    reg     [15:0]  if_pc;
    wire    [15:0]  if_instr, if_mem_addr;
    wire            if_mem_read, pc_src, pc_write;
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
    
    
endmodule

`endif
