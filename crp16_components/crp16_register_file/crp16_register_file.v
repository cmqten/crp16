`ifndef CRP16_REGISTER_FILE
`define CRP16_REGISTER_FILE

/**
 * Collection of registers.
 */
module crp16_register_file (
    input   clock,
    
    // 4 ports for reading register values
    input   [2:0]   a_sel,       
    input   [2:0]   b_sel,
    input   [2:0]   c_sel,
    input   [2:0]   d_sel,
    output  [15:0]  a_val,    
    output  [15:0]  b_val,   
    output  [15:0]  c_val,    
    output  [15:0]  d_val,
    
    // 1 port for writing data to register
    input   write,
    input   [2:0]   write_sel, 
    input   [15:0]  write_val      
              
);
    reg [15:0] registers [0:7]; 
    
    assign a_val = registers[a_sel];
    assign b_val = registers[b_sel];
    assign c_val = registers[c_sel];
    assign d_val = registers[d_sel];
    
    // Positive edge write
    always @(posedge clock) 
    begin
        if (write) registers[write_sel] <= write_val;
    end
 
endmodule

`endif
