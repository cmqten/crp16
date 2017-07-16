`ifndef CRP16_ALU_SLT
`define CRP16_ALU_SLT
`include "../../crp16_subcomponents/mux_2_to_1/mux_2_to_1.v"

/**
 * Module that implements the set less than operation in the hardware
 * v : overflow bit of the adder circuit
 * c : carry out bit of the adder circuit
 * n : negative bit of the adder circuit
 * us_s : unsigned or signed operation
 * is_less : result of the operation
 */
module crp16_alu_slt(v, c, n, us_s, is_less);
    input v, c, n, us_s;
    output [15:0] is_less;
    
    // Set less than unsigned logic
    wire unsigned_out = ~c;
    
    // Set less than signed logic
    wire signed_out = v ^ n;
    
    // Pick between unsigned or signed
    wire slt_out;
    mux_2_to_1 #(1) us_s_mux(unsigned_out, signed_out, us_s, slt_out);
    assign is_less = {15'b0, slt_out};
endmodule

`endif