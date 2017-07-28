`ifndef DEMUX_1_TO_16
`define DEMUX_1_TO_16
`include "../demux_1_to_4/demux_1_to_4.v"

/**
 * A one hot decoder, 1 to 16
 *
 * Ports
 * in : input data
 * select : select bits
 * out_a, ..., out_p : outputs
 *
 * Parameters
 * bits : data width
 */
module demux_1_to_16(in, select, out_a, out_b, out_c, out_d, out_e, out_f,
    out_g, out_h, out_i, out_j, out_k, out_l, out_m, out_n, out_o, out_p);
    
    parameter bits = 1;
    input [3:0] select;
    input [(bits-1):0] in;
    output [(bits-1):0] out_a;
    output [(bits-1):0] out_b;
    output [(bits-1):0] out_c;
    output [(bits-1):0] out_d;
    output [(bits-1):0] out_e;
    output [(bits-1):0] out_f;
    output [(bits-1):0] out_g;
    output [(bits-1):0] out_h;
    output [(bits-1):0] out_i;
    output [(bits-1):0] out_j;
    output [(bits-1):0] out_k;
    output [(bits-1):0] out_l;
    output [(bits-1):0] out_m;
    output [(bits-1):0] out_n;
    output [(bits-1):0] out_o;
    output [(bits-1):0] out_p;
    
    wire [(bits-1):0] l1_to_l2[0:3]; // From level 1 demux to level 2 demuxes
    
    demux_1_to_4 #(bits) l1(in, select[3:2], l1_to_l2[0], l1_to_l2[1], 
        l1_to_l2[2], l1_to_l2[3]);
        
    demux_1_to_4 #(bits) l2_a(l1_to_l2[0], select[1:0], out_a, out_b, out_c, 
        out_d);
        
    demux_1_to_4 #(bits) l2_b(l1_to_l2[1], select[1:0], out_e, out_f, out_g, 
        out_h);
    
    demux_1_to_4 #(bits) l2_c(l1_to_l2[2], select[1:0], out_i, out_j, out_k, 
        out_l);
    
    demux_1_to_4 #(bits) l2_d(l1_to_l2[3], select[1:0], out_m, out_n, out_o, 
        out_p);
endmodule

`endif