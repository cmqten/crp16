`ifndef CRP16_ALU_SHIFTER_RIGHT
`define CRP16_ALU_SHIFTER_RIGHT

`include "../../crp16_subcomponents/mux_16_to_1/mux_16_to_1.v"

/**
 * A 16-bit arithmetic/logical right barrel shifter.
 * x : number to shift
 * shift : shift amount
 * log_ar : 0 for logical shift, 1 for arithmetic shift
 * out : output
 */
module crp16_alu_shifter_right(x, shift, log_ar, out);
    input [15:0] x;
    input [3:0] shift;
    input log_ar;
    output [15:0] out;
    
    /* Value to shift in from the right, forced to 0 if set to logical shift, 
    MSB if set to arithmetic shift. */
    wire sft_in = x[15] & log_ar; 
    
    /* Muxes. Look up barrel shifter on google I'm not gonna explain how barrel 
    shifters work. */
    mux_16_to_1 b15(x[15], sft_in, sft_in, sft_in, sft_in, sft_in, sft_in,
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in,
        shift, out[15]); // MSB
        
    mux_16_to_1 b14(x[14], x[15], sft_in, sft_in, sft_in, sft_in, sft_in,
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in,
        shift, out[14]); // Bit 14
    
    mux_16_to_1 b13(x[13], x[14], x[15], sft_in, sft_in, sft_in, sft_in, sft_in, 
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, shift, 
        out[13]); // Bit 13
    
    mux_16_to_1 b12(x[12], x[13], x[14], x[15], sft_in, sft_in, sft_in, sft_in, 
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, shift, 
        out[12]); // Bit 12
    
    mux_16_to_1 b11(x[11], x[12], x[13], x[14], x[15], sft_in, sft_in, sft_in, 
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, shift, 
        out[11]); // Bit 11
    
    mux_16_to_1 b10(x[10], x[11], x[12], x[13], x[14], x[15], sft_in, sft_in, 
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, shift, 
        out[10]); // Bit 10
    
    mux_16_to_1 b9(x[9], x[10], x[11], x[12], x[13], x[14], x[15], sft_in, 
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, shift, 
        out[9]); // Bit 9
    
    mux_16_to_1 b8(x[8], x[9], x[10], x[11], x[12], x[13], x[14], x[15], sft_in,
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, shift, out[8]); 
        // Bit 8
        
    mux_16_to_1 b7(x[7], x[8], x[9], x[10], x[11], x[12], x[13], x[14], x[15],
        sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, shift, out[7]); 
        // Bit 7
        
    mux_16_to_1 b6(x[6], x[7], x[8], x[9], x[10], x[11], x[12], x[13], x[14], 
        x[15], sft_in, sft_in, sft_in, sft_in, sft_in, sft_in, shift, out[6]); 
        // Bit 6
        
    mux_16_to_1 b5(x[5], x[6], x[7], x[8], x[9], x[10], x[11], x[12], x[13], 
        x[14], x[15], sft_in, sft_in, sft_in, sft_in, sft_in, shift, out[5]); 
        // Bit 5
    
    mux_16_to_1 b4(x[4], x[5], x[6], x[7], x[8], x[9], x[10], x[11], x[12], 
        x[13], x[14], x[15], sft_in, sft_in, sft_in, sft_in, shift, out[4]); 
        // Bit 4
    
    mux_16_to_1 b3(x[3], x[4], x[5], x[6], x[7], x[8], x[9], x[10], x[11], 
        x[12], x[13], x[14], x[15], sft_in, sft_in, sft_in, shift, out[3]); 
        // Bit 3
    
    mux_16_to_1 b2(x[2], x[3], x[4], x[5], x[6], x[7], x[8], x[9], x[10], x[11], 
        x[12], x[13], x[14], x[15], sft_in, sft_in, shift, out[2]); // Bit 2
    
    mux_16_to_1 b1(x[1], x[2], x[3], x[4], x[5], x[6], x[7], x[8], x[9], x[10], 
        x[11], x[12], x[13], x[14], x[15], sft_in, shift, out[1]); // Bit 1
    
    mux_16_to_1 b0(x[0], x[1], x[2], x[3], x[4], x[5], x[6], x[7], x[8], x[9], 
        x[10], x[11], x[12], x[13], x[14], x[15], shift, out[0]); // Bit 0
endmodule

`endif
