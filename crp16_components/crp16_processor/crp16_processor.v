`ifndef CRP16_PROCESSOR
`define CRP16_PROCESSOR

`include "../crp16_datapath/crp16_datapath.v"
`include "../../crp16_subcomponents/hex_decoder/hex_decoder.v"

// Clock period / 2
`define HI_PERIOD 32'd12499999  

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
    
    // Clock divider
    reg             clock_div = 1'b0;
    reg     [31:0]  clock_counter = `HI_PERIOD;
    
    assign reset     = ~KEY[1];
    assign clock     = clock_div;
    
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
    hex_decoder addrhi(pc_view[4], HEX5);
    hex_decoder h0(hex_in[3:0], HEX0);
    hex_decoder h1(hex_in[7:4], HEX1);
    hex_decoder h2(hex_in[11:8], HEX2);
    hex_decoder h3(hex_in[15:12], HEX3);
    
    assign hex_in = SW[4] ? counter  :
                    SW[3] ? reg_view : 
                    instr_view;
    
    // 2 Hz clock
    always @(posedge CLOCK_50)
    begin
        if (clock_counter > 32'd0) clock_counter <= clock_counter - 1;
        
        else
        begin
            clock_counter <= `HI_PERIOD;
            clock_div <= clock_div ^ 1'b1;
        end
    end

endmodule

`endif
