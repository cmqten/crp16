`ifndef CRP16_ALU
`define CRP16_ALU
`include "./crp16_alu_adder.v"
`include "./crp16_alu_logic.v"
`include "./crp16_alu_slt.v"
`include "../../crp16_subcomponents/mux_2_to_1/mux_2_to_1.v"
`include "../../crp16_subcomponents/mux_4_to_1/mux_4_to_1.v"

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
    
    /* The subtraction bit must be a logical or between select[2] and select[1]
    because it has to be in subtraction mode (1) when the ALU is in slt mode 
    (select[2] == 1) or when the ALU is in subtraction mode (select[2] == 0 &&
    select[1] == 1)*/
    crp16_alu_adder adder_unit(x, y, select[2] | select[1], adder_out, 
        adder_c_out, adder_v_out);
    
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
    mux_4_to_1 #(16) mode_sel(16'b0, logic_out, adder_out, slt_out, 
        select[3:2], mode_sel_out);
    
    /* Overflow, carry, and negative flags are only set if the operation is an
    arithmetic operation*/
    assign v = adder_v_out & ~select[2] & select[3]; // overflow
    assign c = adder_c_out & ~select[2] & select[3]; // carry
    assign n = mode_sel_out[15] & ~select[2] & select[3]; // negative
    
    assign z = ~(| mode_sel_out); // Zero flag, result of operation is 0
    
    assign alu_out = mode_sel_out;
endmodule

`endif
