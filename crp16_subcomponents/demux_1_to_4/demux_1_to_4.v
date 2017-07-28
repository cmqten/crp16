`ifndef DEMUX_1_TO_4
`define DEMUX_1_TO_4
`include "../demux_1_to_2/demux_1_to_2.v"

/**
 * A one hot decoder, 1 to 4
 *
 * Ports
 * in : input data
 * select : select bits
 * out_w, out_x, out_y, out_z : outputs
 *
 * Parameters
 * bits : data width
 */
module demux_1_to_4(in, select, out_w, out_x, out_y, out_z);
    parameter bits = 1;
    input [1:0] select;
    input [(bits-1):0] in;
    output [(bits-1):0] out_w;
    output [(bits-1):0] out_x;
    output [(bits-1):0] out_y;
    output [(bits-1):0] out_z;
    
    wire [(bits-1):0] l1_to_l2[0:1]; // From level 1 demux to level 2 demuxes
    demux_1_to_2 #(bits) l1(in, select[1], l1_to_l2[0], l1_to_l2[1]);
    demux_1_to_2 #(bits) l2_a(l1_to_l2[0], select[0], out_w, out_x);
    demux_1_to_2 #(bits) l2_b(l1_to_l2[1], select[0], out_y, out_z);
endmodule

`endif