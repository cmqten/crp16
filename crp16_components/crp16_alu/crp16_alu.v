`ifndef CRP16_ALU
`define CRP16_ALU
`include "./crp16_alu_adder.v"
`include "./crp16_alu_logic.v"
`include "../../crp16_subcomponents/mux_2_to_1/mux_2_to_1.v"

/*
 * The CRP16 ALU. Contains an adder/subtractor circuit and a logical operation
 * circuit.
 * x, y : operands
 * select : operation select bit
 * alu_out : result
 * v : overflow flag
 * c : carry out flag
 * n : negative flag
 * z : zero flag
 */
module crp16_alu(x, y, select, alu_out, v, c, n, z);
    input [15:0] x;
    input [15:0] y;
    input [3:0] select;
    output [15:0] alu_out;
    output v, c, n, z;
    
    // Logic unit
    wire [15:0] logic_out;
    crp16_alu_logic logic_unit(x, y, select[1:0], logic_out);
    
    // Adder/subtractor unit
    wire [15:0] adder_out;
    wire c_out;
    crp16_alu_adder adder_unit(x, y, select[0], adder_out, c_out);
    
    // TODO: shifter unit
    
    // TODO: slt unit
    
    // Logic/shift mux
    wire [15:0] ls_out;
    mux_2_to_1 #(16) log_shift(logic_out, 16'd0, select[2], ls_out);
    
    // Arithmetic/logic+shift mux
    wire [15:0] ar_ls_out;
    mux_2_to_1 #(16) ar_logshift(adder_out, ls_out, select[3], ar_ls_out);
    
    assign c = c_out;
    assign z = | ar_ls_out;
    assign alu_out = ar_ls_out;
endmodule

`endif
