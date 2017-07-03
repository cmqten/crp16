`ifndef MUX_2_TO_1
`define MUX_2_TO_1

/* 2 to 1 mux */
module mux_2_to_1(x, y, select, out);
    parameter bits = 1;
    input [(bits - 1):0] x;
    input [(bits - 1):0] y;
    input select;
    output reg [(bits - 1):0] out;
    always @(*) begin
        if (!select) out = x;
        else out = y;
    end
endmodule

`endif
