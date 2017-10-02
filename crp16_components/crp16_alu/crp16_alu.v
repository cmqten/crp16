`ifndef CRP16_ALU
`define CRP16_ALU

/**
 * The CRP16 ALU. Supports 8 operations. 
 */
module crp16_alu (
    input [15:0] x,             // First operand
    input [15:0] y,             // Second operand
    input [2:0] select,         // Operation select
    output reg [15:0] alu_out,  // Result
    output reg v,               // Overflow flag
    output reg c,               // Carry out flag
    output n,                   // Negative flag
    output z                    // Zero flag
);
    assign n = alu_out[15];
    assign z = ~(|alu_out);
    
    always @(*)
    begin
        case (select[2:0])
            3'b000: begin // Addition
                {c, alu_out} = {1'b0, x} + {1'b0, y};// For capturing carry out
                
                // Addition overflows if the operands are the same sign but the
                // result has a different sign
                v = (~(x[15] ^ y[15])) & (x[15] ^ alu_out[15]);
            end
            
            3'b001: begin // Subtraction
                // Two's complement addition, for capturing carry out correctly
                {c, alu_out} = {1'b0, x} + {1'b0, ~y} + 17'b1;
                
                // Subtraction overflows if the operands have different signs
                // and the result has the same sign as the second operand.
                v = (x[15] ^ y[15]) & (~(y[15] ^ alu_out[15]));
            end
            
            3'b010: begin // Logical shift right
                alu_out = x >> (16'b1111 & y);
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b011: begin // Arithmetic shift right
                alu_out = $signed(x) >>> (16'b1111 & y);
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b100: begin // Logical shift left
                alu_out = x << (16'b1111 & y);
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b101: begin // Bitwise AND
                alu_out = x & y;
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b110: begin // Bitwise OR
                alu_out = x | y;
                c = 1'b0;
                v = 1'b0;
            end
            
            3'b111: begin // Bitwise XOR
                alu_out = x ^ y;
                c = 1'b0;
                v = 1'b0;
            end
        endcase
    end
endmodule

`endif
