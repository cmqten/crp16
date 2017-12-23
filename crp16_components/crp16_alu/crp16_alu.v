`ifndef CRP16_ALU
`define CRP16_ALU

/**
 * The CRP16 ALU. Supports 8 operations. 
 */
module crp16_alu (
    // Operands
    input       [15:0]  op_a,       
    input       [15:0]  op_b,  
    
    input       [2:0]   op_sel,     // Operation select
    output reg  [15:0]  alu_out,    // Result
    output reg          v,          // Overflow flag
    output reg          c,          // Carry out flag
    output              n,          // Negative flag
    output              z           // Zero flag
);
    assign n = alu_out[15];
    assign z = ~(|alu_out);
    
    always @(*)
    begin
        case (op_sel[2:0])
            3'b000: // Addition
            begin 
                {c, alu_out} = {1'b0, op_a} + {1'b0, op_b};
                
                // Addition overflows if the operands are the same sign but the
                // result has a different sign.
                v = (~(op_a[15] ^ op_b[15])) & (op_a[15] ^ alu_out[15]);
            end
            
            3'b001: // Subtraction
            begin 
                // Two's complement addition, for capturing carry out correctly
                {c, alu_out} = {1'b0, op_a} + {1'b0, ~op_b} + 17'b1;
                
                // Subtraction overflows if the operands have different signs
                // and the result has the same sign as the second operand.
                v = (op_a[15] ^ op_b[15]) & (~(op_b[15] ^ alu_out[15]));
            end
            
            3'b010: // Logical shift right
            begin 
                alu_out = op_a >> (16'b1111 & op_b);
                c = 0;
                v = 0;
            end
            
            3'b011: // Arithmetic shift right
            begin 
                alu_out = $signed(op_a) >>> (16'b1111 & op_b);
                c = 0;
                v = 0;
            end
            
            3'b100: // Logical shift left
            begin 
                alu_out = op_a << (16'b1111 & op_b);
                c = 0;
                v = 0;
            end
            
            3'b101: // Bitwise AND
            begin 
                alu_out = op_a & op_b;
                c = 0;
                v = 0;
            end
            
            3'b110: // Bitwise OR
            begin 
                alu_out = op_a | op_b;
                c = 0;
                v = 0;
            end
            
            3'b111: // Bitwise XOR
            begin 
                alu_out = op_a ^ op_b;
                c = 0;
                v = 0;
            end
        endcase
    end
endmodule

`endif
