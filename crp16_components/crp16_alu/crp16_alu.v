`ifndef CRP16_ALU
`define CRP16_ALU
`include "./crp16_alu_adder.v"
`include "./crp16_alu_logic.v"
`include "./crp16_alu_shifter_left.v"
`include "./crp16_alu_shifter_right.v"
`include "../../crp16_subcomponents/mux_2_to_1/mux_2_to_1.v"

/**
 * The CRP16 ALU. Contains an adder/subtractor circuit and a logical operation
 * circuit.
 * x, y : operands
 * select : operation select bit
 * alu_out : result
 * v : overflow flag
 * c : carry out flag
 * n : negative flag
 * z : zero flag
 *
 * Select bits:
 * 0xx0 : add
 * 0xx1 : subtract
 * 100x : left shift
 * 1010 : logical right shift
 * 1011 : arithmetic right shift
 * 1100 : bitwise and
 * 1101 : bitwise or
 * 1110 : bitwise not
 * 1111 : bitwise xor
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
    wire adder_c_out; // Carry out
    wire adder_v_out; // Overflow
    crp16_alu_adder adder_unit(x, y, select[0], adder_out, c, v);
    
    // Shifter unit
    wire [15:0] left_shift_out; // Left shifter
    crp16_alu_shifter_left left_shift(x, y[3:0], left_shift_out); 
    
    wire [15:0] right_shift_out; // Right shifter
    crp16_alu_shifter_right right_shift(x, y[3:0], select[0], right_shift_out);
    
    wire [15:0] shift_out; // Shifter selector
    mux_2_to_1 #(16) shift_sel(left_shift_out, right_shift_out, select[1], 
        shift_out);
        
    // Selector mux for shifter and bitwise and/or/not/xor
    wire [15:0] logic_shift_out;
    mux_2_to_1 #(16) logic_shift_sel(shift_out, logic_out, select[2], 
        logic_shift_out);
    
    // Selector mux for arithmetic/logic
    wire [15:0] alu_sel_out;
    mux_2_to_1 #(16) alu_sel(adder_out, logic_shift_out, select[3], 
        alu_sel_out);
    
    assign n = alu_sel_out[15]; // Negative flag
    assign z = ~(| alu_sel_out); // Zero flag 
    assign alu_out = alu_sel_out;
endmodule

`endif
