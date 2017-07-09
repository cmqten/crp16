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
    
    // Logic unit
    wire [15:0] logic_out;
    crp16_alu_logic logic_unit(x, y, select[1:0], logic_out);
    
    // Adder/subtractor unit
    wire [15:0] adder_out;
    wire c_out;
    crp16_alu_adder adder_unit(x, y, select[0], adder_out, c_out);
    
    // Slt unit, only concerned about sign bits
    wire [15:0] slt_out;
    crp16_alu_slt slt_unit(x[15], y[15], adder_out[15], c_out, 
        select[1], slt_out);
    
    // TODO: shifter unit
    
    // Logic/shift mux
    wire [15:0] ls_out;
    mux_2_to_1 #(16) log_shift(logic_out, 16'd0, select[2], ls_out);
    
    // Addsub/slt mux
    wire [15:0] ar_out;
    mux_2_to_1 #(16) as_slt(adder_out, slt_out, select[2], ar_out);
    
    // Arithmetic/logic+shift mux
    wire [15:0] ar_ls_out;
    mux_2_to_1 #(16) ar_logshift(ar_out, ls_out, select[3], ar_ls_out);
    
    // Only set if the operation is a signed arithmetic operation
    wire add_v = ~(x[15] ^ y[15]) & (x[15] ^ adder_out[15]);
    wire sub_v = (x[15] ^ y[15]) & ~(y[15] ^ adder_out[15]);
    wire v_mux_out;
    mux_2_to_1 #(1) v_mux(add_v, sub_v, select[0], v_mux_out);
    assign v = v_mux_out & select[1] & ~select[2] & ~select[3];
        
    // Only set if operation is an unsigned arithmetic operation
    assign c = c_out & ~select[1] & ~select[2] & ~select[3];
    
    // Only set if operation is a signed arithmetic operation
    assign n = ar_ls_out[15] & select[1] & ~select[2] & ~select[3];
    
    assign z = ~(| ar_ls_out);
    assign alu_out = ar_ls_out;
endmodule

`endif
