`ifndef FULL_ADDER
`define FULL_ADDER

/* 
 * A single bit full adder 
 * x, y : operands
 * c_in : carry in bit
 * s : result
 * c_out : carry out bit
 */
module full_adder(x, y, c_in, s, c_out);
    input x, y, c_in;
    output s, c_out;
    
    assign s = x ^ y ^ c_in;
    assign c_out = x & y | x & c_in | y & c_in;
endmodule

`endif
