`ifndef CRP16_REGISTER_FILE
`define CRP16_REGISTER_FILE

/**
 * Collection of registers.
 */
module crp16_register_file (
    input [2:0] a_select,       // Selector for first register
    input [2:0] b_select,       // Selector for second register
    output reg [15:0] a_val,    // First register value 
    output reg [15:0] b_val,    // Second register value
    input [15:0] write_val,     // Value to be written 
    input [2:0] write_select,   // Register to be written 
    input write,                // Enable writing, active high
    input clock                 // Clock source, positive edge
);
    reg [15:0] registers [0:7]; // Registers
    
    always @(posedge clock) // Writing to register
    begin
        if (write) registers[write_select] <= write_val;
    end
    
    always @(*) // Reading register value
    begin
        a_val = registers[a_select];
        b_val = registers[b_select];
    end
endmodule

`endif
