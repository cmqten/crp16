`ifndef CRP16_ALU
`define CRP16_ALU
`include "./crp16_alu_adder.v"
`include "./crp16_alu_logic.v"
`include "./crp16_alu_shifter_left.v"
`include "./crp16_alu_shifter_right.v"
`include "./crp16_alu_slt.v"
`include "../../crp16_subcomponents/mux_2_to_1/mux_2_to_1.v"
`include "../../crp16_subcomponents/mux_4_to_1/mux_4_to_1.v"

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
 * Select bits (1:1 with the opcode, mostly):
 * 0000*, 0001 : shift left logical
 * 0010 : shift right logical
 * 0011 : shift right arithmetic
 * 0100 : logical and
 * 0101 : logical or
 * 0110 : logical not
 * 0111 : logical xor
 * 1000, 1001 : add
 * 1010, 1011 : subtract
 * 1100, 1101* : set less than unsigned
 * 1110, 1111* : set less than signed
 * (* denotes that select bit is used by an opcode with a different function)
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
    
    /* The subtraction bit must be a logical or between select[2] and select[1]
    because it has to be in subtraction mode (1) when the ALU is in slt mode 
    (select[2] == 1) or when the ALU is in subtraction mode (select[2] == 0 &&
    select[1] == 1). */
    crp16_alu_adder adder_unit(x, y, select[2] | select[1], adder_out, 
        adder_c_out, adder_v_out);
    
    // Set less than unit
    wire [15:0] slt_out;
    crp16_alu_slt slt_unit(adder_v_out, adder_c_out, adder_out[15], select[1],
        slt_out);
    
    // Shifter unit
    wire [15:0] left_shift_out; // Left shifter
    crp16_alu_shifter_left left_shift(x, y[3:0], left_shift_out); 
    
    wire [15:0] right_shift_out; // Right shifter
    crp16_alu_shifter_right right_shift(x, y[3:0], select[0], right_shift_out);
    
    wire [15:0] shift_out; // Shifter selector
    mux_2_to_1 #(16) shift_sel(left_shift_out, right_shift_out, select[1], 
        shift_out);
    
    // Mode select mux
    wire [15:0] mode_sel_out;
    mux_4_to_1 #(16) mode_sel(shift_out, logic_out, adder_out, slt_out, 
        select[3:2], mode_sel_out);
    
    /* Overflow, carry, and negative flags are only set if the operation is an
    arithmetic operation. */
    assign v = adder_v_out & ~select[2] & select[3]; // Overflow
    assign c = adder_c_out & ~select[2] & select[3]; // Carry
    assign n = mode_sel_out[15] & ~select[2] & select[3]; // Negative
    
    assign z = ~(| mode_sel_out); // Zero flag, result of operation is 0
    
    assign alu_out = mode_sel_out;
endmodule

`endif
