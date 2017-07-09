`ifndef CRP16_ALU_LOGIC
`define CRP16_ALU_LOGIC
`include "../../crp16_subcomponents/mux_2_to_1/mux_2_to_1.v"

/**
 * The logic part of the ALU
 * x, y : operands
 * select : operator select
 * out : output
 */
module crp16_alu_logic(x, y, select, out);
    input [15:0] x;
    input [15:0] y;
    input [1:0] select;
    output [15:0] out;
    
    // 4 to 1 mux to select between and, or, not, xor
    wire [15:0] mux_select[0:1]; 
    
    // and/or mux
    mux_2_to_1 #(16) and_or(x & y, x | y, select[0], mux_select[0]); 
    
    // not/xor mux
    mux_2_to_1 #(16) not_xor(~x, x ^ y, select[0], mux_select[1]); 
    
    // selects between and/or and not/xor
    mux_2_to_1 #(16) logic_sel(mux_select[0], mux_select[1], select[1], out);
endmodule

`endif