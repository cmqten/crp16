`ifndef CRP16_ALU_SHIFTER_LEFT
`define CRP16_ALU_SHIFTER_LEFT

`include "../../crp16_subcomponents/mux_16_to_1/mux_16_to_1.v"

/**
 * A 16-bit left barrel shifter
 * x : number to shift
 * shift : shift amount
 * out : output
 */
module crp16_alu_shifter_left(x, shift, out);
    input [15:0] x;
    input [3:0] shift;
    output [15:0] out;
    
    /* Muxes. Look up barrel shifter on google I'm not gonna explain how barrel 
    shifters work. */
    mux_16_to_1 b0(x[0], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[0]); // LSB
    
    mux_16_to_1 b1(x[1], x[0], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[1]); // Bit 1
    
    mux_16_to_1 b2(x[2], x[1], x[0], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[2]); // Bit 2
    
    mux_16_to_1 b3(x[3], x[2], x[1], x[0], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[3]); // Bit 3
    
    mux_16_to_1 b4(x[4], x[3], x[2], x[1], x[0], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[4]); // Bit 4
    
    mux_16_to_1 b5(x[5], x[4], x[3], x[2], x[1], x[0], 1'b0, 1'b0, 1'b0, 1'b0, 
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[5]); // Bit 5
    
    mux_16_to_1 b6(x[6], x[5], x[4], x[3], x[2], x[1], x[0], 1'b0, 1'b0, 1'b0,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[6]); // Bit 6
    
    mux_16_to_1 b7(x[7], x[6], x[5], x[4], x[3], x[2], x[1], x[0], 1'b0, 1'b0,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[7]); // Bit 7
    
    mux_16_to_1 b8(x[8], x[7], x[6], x[5], x[4], x[3], x[2], x[1], x[0], 1'b0,
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[8]); // Bit 8
    
    mux_16_to_1 b9(x[9], x[8], x[7], x[6], x[5], x[4], x[3], x[2], x[1], x[0],
        1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[9]); // Bit 9
    
    mux_16_to_1 b10(x[10], x[9], x[8], x[7], x[6], x[5], x[4], x[3], x[2], x[1],
        x[0], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, shift, out[10]); // Bit 10
    
    mux_16_to_1 b11(x[11], x[10], x[9], x[8], x[7], x[6], x[5], x[4], x[3],
        x[2], x[1], x[0], 1'b0, 1'b0, 1'b0, 1'b0, shift, out[11]); // Bit 11
    
    mux_16_to_1 b12(x[12], x[11], x[10], x[9], x[8], x[7], x[6], x[5], x[4], 
        x[3], x[2], x[1], x[0], 1'b0, 1'b0, 1'b0, shift, out[12]); // Bit 12
    
    mux_16_to_1 b13(x[13], x[12], x[11], x[10], x[9], x[8], x[7], x[6], x[5], 
        x[4], x[3], x[2], x[1], x[0], 1'b0, 1'b0, shift, out[13]); // Bit 13
    
    mux_16_to_1 b14(x[14], x[13], x[12], x[11], x[10], x[9], x[8], x[7], x[6], 
        x[5], x[4], x[3], x[2], x[1], x[0], 1'b0, shift, out[14]); // Bit 14
    
    mux_16_to_1 b15(x[15], x[14], x[13], x[12], x[11], x[10], x[9], x[8], x[7],
        x[6], x[5], x[4], x[3], x[2], x[1], x[0], shift, out[15]); // Bit 15
endmodule

`endif