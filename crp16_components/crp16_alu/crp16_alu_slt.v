`ifndef CRP16_ALU_SLT
`define CRP16_ALU_SLT
`include "../../crp16_subcomponents/mux_2_to_1/mux_2_to_1.v"

/**
 * Module that implements the set less than operation in the hardware
 * x_s, y_s : sign bits of the operands, highest bit
 * z_s : sign bit of the difference of x and y, highest bit
 * c_out : carry out bit of the adder circuit
 * us_s : unsigned or signed operation
 * is_less : result of the operation
 */
module crp16_alu_slt(x_s, y_s, z_s, c_out, us_s, is_less);
    input x_s, y_s, z_s, c_out, us_s;
    output [15:0] is_less;
    
    // Set less than unsigned logic
    wire unsigned_out;
    assign unsigned_out = ~c_out;
    
    // Set less than signed logic
    wire signed_out;
    mux_2_to_1 #(1) diff_sign(z_s, x_s, x_s ^ y_s, signed_out);
    
    // Pick between unsigned or signed
    wire slt_out;
    mux_2_to_1 #(1) us_s_mux(unsigned_out, signed_out, us_s, slt_out);
    assign is_less = {15'b0, slt_out};
endmodule

`endif