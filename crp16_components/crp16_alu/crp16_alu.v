`ifndef CRP16_ALU
`define CRP16_ALU
`include "./crp16_alu_adder.v"
`include "./crp16_alu_logic.v"
`include "./crp16_alu_slt.v"
`include "../../crp16_subcomponents/mux_2_to_1/mux_2_to_1.v"

/**
 * The CRP16 ALU. Contains an adder/subtractor circuit and a logical operation
 * circuit.
 * x, y : operands
 * select : operation select bit
 * alu_out : result
 * v : overflow flag
 * c : carry out flag
 * n : negative flag
 * z : zero flag
 */
module crp16_alu(x, y, select, alu_out, v, c, n, z);
    input [15:0] x;
    input [15:0] y;
    input [3:0] select;
    output [15:0] alu_out;
    output v, c, n, z;
    
    /**
     * Logic unit
     *
     * Select bits:
     * S1, S0: operation select
     */
    wire [15:0] logic_out;
    crp16_alu_logic logic_unit(x, y, select[1:0], logic_out);
    
    /**
     * Adder/subtractor unit
     * 
     * Select bits:
     * S0: add/subtract
     */
    wire [15:0] adder_out; 
    wire adder_c_out; // Carry out
    wire adder_v_out; // Overflow
    crp16_alu_adder adder_unit(x, y, select[0], adder_out, adder_c_out, 
        adder_v_out);
    
    /** 
     * Slt unit, uses adder/subtractor unit
     * 
     * Select bits:
     * S0: must be set to 1
     * S1: unsigned/signed
     */
    wire [15:0] slt_out;
    crp16_alu_slt slt_unit(adder_v_out, adder_c_out, adder_out[15], select[1],
        slt_out);
    
    // TODO: shifter unit
    
    // Mode select mux
    wire [15:0] mode_sel_out;
    mode_select_mux mode_sel(adder_out, slt_out, logic_out, , 
        select[3:2], mode_sel_out);
    
    /* Overflow, carry, and negative flags are only set if the operation is an
    arithmetic operation*/
    assign v = adder_v_out & ~select[2] & ~select[3]; // overflow
    assign c = adder_c_out & ~select[2] & ~select[3]; // carry
    assign n = mode_sel_out[15] & ~select[2] & ~select[3]; // negative
    
    assign z = ~(| mode_sel_out); // Zero flag, result of operation is 0
    
    assign alu_out = mode_sel_out;
endmodule

/**
 * 4-to-1 mux that selects between arithmetic, set less than, logic, and shifter
 * circuits.
 * ar_out : Arithmetic operation output
 * slt_out : Set less than circuit output
 * logic_out : Logic operation output
 * shift_out : Shifter circuit output
 * select : Select bits
 * alu_out : ALU result for the specified operation
 *
 * Select bits: 00 - Arithmetic, 01 - SLT, 10 - Logic, 11 - Shift
 */
module mode_select_mux(ar_out, slt_out, logic_out, shift_out, select, alu_out);
    input [15:0] ar_out;
    input [15:0] slt_out;
    input [15:0] logic_out;
    input [15:0] shift_out;
    input [1:0] select;
    output [15:0] alu_out;
    
    // Arithmetic / slt mux
    wire [15:0] ar_slt_out;
    mux_2_to_1 #(16) ar_slt(ar_out, slt_out, select[0], ar_slt_out);
    
    // Logic / shift mux
    wire [15:0] log_sft_out;
    mux_2_to_1 #(16) log_shift(logic_out, shift_out, select[0], log_sft_out);
    
    // [Arithmetic, slt] / [logic, shift] mux
    mux_2_to_1 #(16) ar_logshift(ar_slt_out, log_sft_out, select[1], alu_out);
endmodule

`endif
