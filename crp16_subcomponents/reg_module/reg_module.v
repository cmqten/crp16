/**
 * A single register of any size. Positive edge triggered, 
 * active high write.
 *
 * data  : value to load to register
 * q     : value stored in register
 * wren  : 0 to disable write, 1 to enable write
 * clock : clock source
 * reset : reset value to 0
 */
module reg_module(data, q, wren, clock, reset);
    parameter width = 16;
    
    input   [(width-1):0]   data;
    output  [(width-1):0]   q;
    input   wren, clock, reset;
    
    reg [(width-1):0] data_reg = 0;
    assign q = data_reg;
  
    always @(posedge clock, posedge reset)
    begin
        if (reset) data_reg <= 0;
        else if (wren) data_reg <= data;
    end
endmodule