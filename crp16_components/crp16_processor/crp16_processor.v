`ifndef CRP16_PROCESSOR
`define CRP16_PROCESSOR

`include "../crp16_datapath/crp16_datapath.v"
`include "../../crp16_subcomponents/hex_decoder/hex_decoder.v"

module crp16_processor (
    input   [3:0]   KEY,
    input   [9:0]   SW,
    output  [9:0]   LEDR,
    output  [6:0]   HEX0,
    output  [6:0]   HEX1,
    output  [6:0]   HEX2,
    output  [6:0]   HEX3,
    output  [6:0]   HEX4,
    output  [6:0]   HEX5
);

    wire    [15:0]  address_a, address_b, data_a, data_b, q_a, q_b;
    wire            wren_a, wren_b, mem_clock, reset;
    wire    [15:0]  hex_in, reg_view, instr_view;
    
    assign reset = ~KEY[1];
    
    dual_mem memory (
        .clock(~mem_clock), 
        .address_a(address_a), .address_b(address_b), 
        .data_a(data_a), .data_b(data_b),
        .wren_a(wren_a), .wren_b(wren_b),
        .q_a(q_a), .q_b(q_b)
    );
    
    crp16_datapath datapath (
        .clock(KEY[0]), .reset(reset),
        .address_a(address_a), .address_b(address_b), 
        .data_a(data_a), .data_b(data_b),
        .wren_a(wren_a), .wren_b(wren_b),
        .q_a(q_a), .q_b(q_b), .mem_clock(mem_clock),
        .reg_sel(SW[2:0]), .reg_view(reg_view), .dc_instr_view(instr_view)
    );
    
    hex_decoder addrlo(address_a[3:0], HEX4);
    hex_decoder addrhi(address_a[4], HEX5);
    hex_decoder h0(hex_in[3:0], HEX0);
    hex_decoder h1(hex_in[7:4], HEX1);
    hex_decoder h2(hex_in[11:8], HEX2);
    hex_decoder h3(hex_in[15:12], HEX3);
    
    assign hex_in = SW[3] ? reg_view : instr_view;

endmodule

`endif
