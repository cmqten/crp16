`ifndef CRP16_REGISTER_FILE
`define CRP16_REGISTER_FILE
`include "../../crp16_subcomponents/register_16_bit/register_16_bit.v"
`include "../../crp16_subcomponents/mux_16_to_1/mux_16_to_1.v"

/**
 * Collection of registers to be used for computations.
 * reg_a_select, reg_b_select : selectors for first and second registers to be
 *      used for computation, respectively
 * reg_a_val, reg_b_val : ports where the values for the selected registers can
 *      be obtained
 * load_val : value to be loaded to one of the registers
 * write_select : selector for register in which load_val will be written
 * write : 1 to enable writing, 0 otherwise
 * clock : clock source
 */
module crp16_register_file(reg_a_select, reg_b_select, reg_a_val, reg_b_val,
    load_val, write_select, write, clock);
    
    input [3:0] reg_a_select;
    input [3:0] reg_b_select;
    output [15:0] reg_a_val;
    output [15:0] reg_b_val;
    input [15:0] load_val;
    input [3:0] write_select;
    input write, clock;
    
    wire [15:0] reg_to_sel[0:15]; // wires to connect registers to selectors
    
    // Selector mux for the first register
    mux_16_to_1 #(16) reg_a_mux(reg_to_sel[0], reg_to_sel[1], reg_to_sel[2], 
        reg_to_sel[3], reg_to_sel[4], reg_to_sel[5], reg_to_sel[6], 
        reg_to_sel[7], reg_to_sel[8], reg_to_sel[9], reg_to_sel[10], 
        reg_to_sel[11], reg_to_sel[12], reg_to_sel[13], reg_to_sel[14],
        reg_to_sel[15], reg_a_select, reg_a_val);
    
    // Selector mux for the second register
    mux_16_to_1 #(16) reg_b_mux(reg_to_sel[0], reg_to_sel[1], reg_to_sel[2], 
        reg_to_sel[3], reg_to_sel[4], reg_to_sel[5], reg_to_sel[6], 
        reg_to_sel[7], reg_to_sel[8], reg_to_sel[9], reg_to_sel[10], 
        reg_to_sel[11], reg_to_sel[12], reg_to_sel[13], reg_to_sel[14],
        reg_to_sel[15], reg_b_select, reg_b_val);
    
    // Registers
    assign reg_to_sel[0] = 16'b0; // Zero "register", just like MIPS, read-only
    register_16_bit reg1(load_val, reg_to_sel[1], 1'b0, clock);
    register_16_bit reg2(load_val, reg_to_sel[2], 1'b0, clock);
    register_16_bit reg3(load_val, reg_to_sel[3], 1'b0, clock);
    register_16_bit reg4(load_val, reg_to_sel[4], 1'b0, clock);
    register_16_bit reg5(load_val, reg_to_sel[5], 1'b0, clock);
    register_16_bit reg6(load_val, reg_to_sel[6], 1'b0, clock);
    register_16_bit reg7(load_val, reg_to_sel[7], 1'b0, clock);
    register_16_bit reg8(load_val, reg_to_sel[8], 1'b0, clock);
    register_16_bit reg9(load_val, reg_to_sel[9], 1'b0, clock);
    register_16_bit reg10(load_val, reg_to_sel[10], 1'b0, clock);
    register_16_bit reg11(load_val, reg_to_sel[11], 1'b0, clock);
    register_16_bit reg12(load_val, reg_to_sel[12], 1'b0, clock);
    register_16_bit reg13(load_val, reg_to_sel[13], 1'b0, clock);
    register_16_bit reg14(load_val, reg_to_sel[14], 1'b0, clock);
    register_16_bit reg15(load_val, reg_to_sel[15], 1'b0, clock);
endmodule

`endif