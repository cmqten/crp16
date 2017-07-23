`ifndef DEMUX_1_TO_2
`define DEMUX_1_TO_2

/**
 * A one hot decoder, one input, two outputs
 * 
 * Ports
 * in : input data
 * select : select bit
 * out_x, out_y : outputs
 *
 * Parameters
 * bits : data width
 */
module demux_1_to_2(in, select, out_x, out_y);
    parameter bits = 1;
    input select;
    input [(bits-1):0] in;
    output [(bits-1):0] out_x;
    output [(bits-1):0] out_y;
    
    // 0 to output to x, 1 to output to y
    assign out_x = select ? {bits{1'b0}} : in;
    assign out_y = select ? in : {bits{1'b0}};
endmodule

`endif
