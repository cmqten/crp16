`ifndef CRP16_ALU
`define CRP16_ALU

/**
 * The CRP16 ALU. Supports 8 operations. 
 * x, y : operands
 * select : operation select bit
 * alu_out : result
 * v : overflow flag
 * c : carry out flag
 * n : negative flag
 * z : zero flag
 */
module crp16_alu(x, y, select, alu_out, v, c, n, z);
    input [15:0] x;
    input [15:0] y;
    input [2:0] select;
    output reg [15:0] alu_out;
    output reg v, c;
    output n = alu_out[15];
    output z = ~(|alu_out);
    
    always @(*)
    begin
        case (select[2:0])
            3'b000: begin // Logical shift right
                alu_out = x >> (16'b1111 & y);
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b001: begin // Arithmetic shift right
                alu_out = $signed(x) >>> (16'b1111 & y);
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b010: begin // Logical shift left
                alu_out = x << (16'b1111 & y);
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b011: begin // Bitwise AND
                alu_out = x & y;
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b100: begin // Bitwise OR
                alu_out = x | y;
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b101: begin // Bitwise XOR
                alu_out = x ^ y;
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b110: begin // Addition
                {c, alu_out} = {1'b0, x} + {1'b0, y};// For capturing carry out
                
                // Addition overflows if the operands are the same sign but the
                // result has a different sign
                v = (~(x[15] ^ y[15])) & (x[15] ^ alu_out[15]);
            end
            
            3'b111: begin // Subtraction
                // Two's complement addition, for capturing carry out correctly
                {c, alu_out} = {1'b0, x} + {1'b0, ~y} + 17'b1;
                
                // Subtraction overflows if the operands have different signs
                // and the result has the same sign as the second operand.
                v = (x[15] ^ y[15]) & (~(y[15] ^ alu_out[15]));
            end
        endcase
    end
endmodule

`endif
