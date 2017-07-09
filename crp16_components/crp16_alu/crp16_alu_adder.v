`ifndef CRP16_ALU_ADDER
`define CRP16_ALU_ADDER
`include "../../crp16_subcomponents/full_adder/full_adder.v"

/**
 * A 16-bit full adder/subtractor
 * x, y : operands 
 * sub : 0 to add, 1 to subtract
 * r_out : result
 * c_out : carry out bit
 */
module crp16_alu_adder(x, y, sub, r_out, c_out);
    input [15:0] x;
    input [15:0] y;
    input sub;
    output [15:0] r_out;
    output c_out;
    
    wire [14:0] adder_c; // Connects adder's c_out to next adder's c_in
    full_adder f0(x[0], y[0] ^ sub, sub, r_out[0], adder_c[0]);
    full_adder f1(x[1], y[1] ^ sub, adder_c[0], r_out[1], adder_c[1]);
    full_adder f2(x[2], y[2] ^ sub, adder_c[1], r_out[2], adder_c[2]);
    full_adder f3(x[3], y[3] ^ sub, adder_c[2], r_out[3], adder_c[3]);
    full_adder f4(x[4], y[4] ^ sub, adder_c[3], r_out[4], adder_c[4]);
    full_adder f5(x[5], y[5] ^ sub, adder_c[4], r_out[5], adder_c[5]);
    full_adder f6(x[6], y[6] ^ sub, adder_c[5], r_out[6], adder_c[6]);
    full_adder f7(x[7], y[7] ^ sub, adder_c[6], r_out[7], adder_c[7]);
    full_adder f8(x[8], y[8] ^ sub, adder_c[7], r_out[8], adder_c[8]);
    full_adder f9(x[9], y[9] ^ sub, adder_c[8], r_out[9], adder_c[9]);
    full_adder f10(x[10], y[10] ^ sub, adder_c[9], r_out[10], adder_c[10]);
    full_adder f11(x[11], y[11] ^ sub, adder_c[10], r_out[11], adder_c[11]);
    full_adder f12(x[12], y[12] ^ sub, adder_c[11], r_out[12], adder_c[12]);
    full_adder f13(x[13], y[13] ^ sub, adder_c[12], r_out[13], adder_c[13]);
    full_adder f14(x[14], y[14] ^ sub, adder_c[13], r_out[14], adder_c[14]);
    full_adder f15(x[15], y[15] ^ sub, adder_c[14], r_out[15], c_out);
endmodule

`endif
