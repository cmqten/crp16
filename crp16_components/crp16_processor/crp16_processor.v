/*******************************************************************************
 *
 * CRP16 Processor Implementation
 *
 * This module serves as the interface between the DE1-SoC board and the CRP16
 * datapath. Altera's 2-Port RAM IP is used as the processor's memory. 
 *
 ******************************************************************************/

`ifndef CRP16_PROCESSOR
`define CRP16_PROCESSOR

`include "../crp16_datapath/crp16_datapath.v"
`include "../../crp16_subcomponents/hex_decoder/hex_decoder.v"


module crp16_processor (
    input   [3:0]   KEY,
    input   [9:0]   SW,
    input           CLOCK_50,
    output  [9:0]   LEDR,
    output  [6:0]   HEX0,
    output  [6:0]   HEX1,
    output  [6:0]   HEX2,
    output  [6:0]   HEX3,
    output  [6:0]   HEX4,
    output  [6:0]   HEX5
);
    wire    [15:0]  address_a, address_b, data_a, data_b, q_a, q_b;
    wire            wren_a, wren_b, mem_clock, clock, reset;
    wire    [15:0]  hex_in, counter, reg_view, instr_view, pc_view;
    
    // Clock controller
    clock_controller    clock_ctrl(CLOCK_50, KEY[2], clock, SW[9:5]);
    
    assign reset = ~KEY[1];
    
    // Dual port memory
    dual_mem memory (
        .clock(clock), 
        .address_a(address_a),  .address_b(address_b), 
        .data_a(data_a),        .data_b(data_b),
        .wren_a(wren_a),        .wren_b(wren_b),
        .q_a(q_a),              .q_b(q_b)
    );
    
    // Datapath
    crp16_datapath datapath (
        .clock(clock),              .reset(reset),
        .address_a(address_a),      .address_b(address_b), 
        .data_a(data_a),            .data_b(data_b),
        .wren_a(wren_a),            .wren_b(wren_b),
        .q_a(q_a),                  .q_b(q_b),       
        .mem_clock(mem_clock),
        .reg_sel(SW[2:0]),          .reg_view(reg_view), 
        .instr_view(instr_view),    .pc_view(pc_view),
        .counter(counter)
    );
    
    // 7 segment viewer
    hex_decoder addrlo(pc_view[3:0], HEX4);
    hex_decoder addrhi(pc_view[7:4], HEX5);
    hex_decoder h0(hex_in[3:0], HEX0);
    hex_decoder h1(hex_in[7:4], HEX1);
    hex_decoder h2(hex_in[11:8], HEX2);
    hex_decoder h3(hex_in[15:12], HEX3);
    
    assign hex_in = SW[4] ? counter  :
                    SW[3] ? reg_view : 
                    instr_view;

endmodule


/**
 * Allows scaling and stopping of clock
 */
module clock_controller (
    input           clock_in,
    input           clock_toggle,
    output          clock_out,
    input   [4:0]   scale
);
    
    reg             clock_run = 0;
    reg     [4:0]   clock_scaler = 0;
    reg     [30:0]  clock_counter = 0;
    wire    [31:0]  clock_src = {clock_counter, clock_in};
    
    assign          clock_out = clock_src[clock_scaler] & clock_run;
    
    always @(posedge clock_in)
    begin
        clock_counter <= clock_counter + 31'b1;
    end
    
    always @(posedge clock_toggle)
    begin
        clock_scaler <= scale;
        clock_run <= clock_run ^ 1'b1;
    end

endmodule

`endif
