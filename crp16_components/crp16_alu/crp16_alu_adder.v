`ifndef CRP16_ALU_ADDER
`define CRP16_ALU_ADDER
`include "../../crp16_subcomponents/full_adder/full_adder.v"

/**
 * A 16-bit full adder/subtractor
 * x, y : operands 
 * sub : 0 to add, 1 to subtract
 * r : result
 * c_out : carry out bit
 * v : overflow flag
 */
module crp16_alu_adder(x, y, sub, r, c_out, v);
    input [15:0] x;
    input [15:0] y;
    input sub;
    output [15:0] r;
    output c_out, v;
    
    wire [14:0] adder_c; // Connects adder's c_out to next adder's c_in
    full_adder f0(x[0], y[0] ^ sub, sub, r[0], adder_c[0]);
    full_adder f1(x[1], y[1] ^ sub, adder_c[0], r[1], adder_c[1]);
    full_adder f2(x[2], y[2] ^ sub, adder_c[1], r[2], adder_c[2]);
    full_adder f3(x[3], y[3] ^ sub, adder_c[2], r[3], adder_c[3]);
    full_adder f4(x[4], y[4] ^ sub, adder_c[3], r[4], adder_c[4]);
    full_adder f5(x[5], y[5] ^ sub, adder_c[4], r[5], adder_c[5]);
    full_adder f6(x[6], y[6] ^ sub, adder_c[5], r[6], adder_c[6]);
    full_adder f7(x[7], y[7] ^ sub, adder_c[6], r[7], adder_c[7]);
    full_adder f8(x[8], y[8] ^ sub, adder_c[7], r[8], adder_c[8]);
    full_adder f9(x[9], y[9] ^ sub, adder_c[8], r[9], adder_c[9]);
    full_adder f10(x[10], y[10] ^ sub, adder_c[9], r[10], adder_c[10]);
    full_adder f11(x[11], y[11] ^ sub, adder_c[10], r[11], adder_c[11]);
    full_adder f12(x[12], y[12] ^ sub, adder_c[11], r[12], adder_c[12]);
    full_adder f13(x[13], y[13] ^ sub, adder_c[12], r[13], adder_c[13]);
    full_adder f14(x[14], y[14] ^ sub, adder_c[13], r[14], adder_c[14]);
    full_adder f15(x[15], y[15] ^ sub, adder_c[14], r[15], c_out);
    
    assign v = adder_c[14] ^ c_out;
endmodule

`endif
