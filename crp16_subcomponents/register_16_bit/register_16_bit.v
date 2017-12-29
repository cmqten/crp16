/**
 * A single 16-bit register. Positive edge triggered, active high write.
 * load_val : value to load to register
 * stored_val : value stored in register
 * write : 0 to disable write, 1 to enable write
 * clock : clock source
 */
module register_16_bit(load_val, stored_val, write, clock);
    input write, clock;
    input [15:0] load_val;
    output reg [15:0] stored_val;
    
    initial
    begin
        stored_val <= 16'b0;
    end
    
    always @(posedge clock)
    begin
        if (write) stored_val <= load_val;
    end
endmodule