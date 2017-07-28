`ifndef CRP16_ALU_ADDER
`define CRP16_ALU_ADDER

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
    
    // y or 2's complement of y depending on the operation
    wire unsigned [16:0] y_2c = sub == 0 ? {1'b0, y} : {1'b0, ~y} + 16'd1;
    
    /* 17 bits is needed in order to generate a carry out for a 16 bit
    operation. The MSB of the result acts as the carry out, and the MSBs of the
    operands are filled with 0. */
    wire unsigned [16:0] result_carry = {1'b0, x} + y_2c;
    assign r = result_carry[15:0];
    assign c_out = result_carry[16];
    
    /* There is an overflow iff the operands have the same sign bits but the 
    result has a different sign bit as the operands. */
    assign v = (~(x[15] ^ y_2c[15])) & (x[15] ^ r[15]); 
endmodule

`endif
