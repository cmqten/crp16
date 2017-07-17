`ifndef MUX_16_TO_1
`define MUX_16_TO_1

`include "../mux_4_to_1/mux_4_to_1.v"

/**
 * A 16 to 1 mux
 * a - p : 16 inputs
 * select : select bits
 * out : output
 */
module mux_16_to_1(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, select, out);
    parameter bits = 1;
    input [(bits - 1):0] a;
    input [(bits - 1):0] b;
    input [(bits - 1):0] c;
    input [(bits - 1):0] d;
    input [(bits - 1):0] e;
    input [(bits - 1):0] f;
    input [(bits - 1):0] g;
    input [(bits - 1):0] h;
    input [(bits - 1):0] i;
    input [(bits - 1):0] j;
    input [(bits - 1):0] k;
    input [(bits - 1):0] l;
    input [(bits - 1):0] m;
    input [(bits - 1):0] n;
    input [(bits - 1):0] o;
    input [(bits - 1):0] p;
    input [3:0] select;
    output [(bits - 1):0] out;
    
    // Wires from the 1st level to the second level muxes
    wire l1_a_l2;
    wire l1_b_l2;
    wire l1_c_l2;
    wire l1_d_l2;
    mux_4_to_1 #(bits) l1_a(a, b, c, d, select[1:0], l1_a_l2);
    mux_4_to_1 #(bits) l1_b(e, f, g, h, select[1:0], l1_b_l2);
    mux_4_to_1 #(bits) l1_c(i, j, k, l, select[1:0], l1_c_l2);
    mux_4_to_1 #(bits) l1_d(m, n, o, p, select[1:0], l1_d_l2);
    
    // Second level mux
    mux_4_to_1 #(bits) l2(l1_a_l2, l1_b_l2, l1_c_l2, l1_d_l2, select[3:2], out);
endmodule

`endif