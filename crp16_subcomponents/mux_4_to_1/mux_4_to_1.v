`ifndef MUX_4_TO_1
`define MUX_4_TO_1

`include "../mux_2_to_1/mux_2_to_1.v"

/**
 * A 4-to-1 mux.
 * w, x, y, x : inputs
 * select : select bits
 * out : output
 */
module mux_4_to_1(w, x, y, z, select, out);
    parameter bits = 1;
    input [(bits - 1):0] w;
    input [(bits - 1):0] x;
    input [(bits - 1):0] y;
    input [(bits - 1):0] z;
    input [1:0] select;
    output [(bits - 1):0] out;
    
    // Wires from the 1st level muxes to the 2nd level mux
    wire [(bits - 1):0] l1_a_l2;
    wire [(bits - 1):0] l1_b_l2;
    mux_2_to_1 #(bits) mux_l1_a(w, x, select[0], l1_a_l2);
    mux_2_to_1 #(bits) mux_l1_b(y, z, select[0], l1_b_l2);
    mux_2_to_1 #(bits) mux_l2(l1_a_l2, l1_b_l2, select[1], out);
endmodule

`endif 