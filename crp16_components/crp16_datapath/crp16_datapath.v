`ifndef CRP16_DATAPATH
`define CRP16_DATAPATH

`include "../crp16_alu/crp16_alu.v"
`include "../crp16_register_file/crp16_register_file.v"
`include "../../crp16_subcomponents/register/register.v"


module crp16_datapath (
    input           clock,
    input           reset,
    
    // Asynchronous Dual-Port RAM interface
    output  [15:0]  address_a,
    output  [15:0]  address_b,
    output  [15:0]  data_a,
    output  [15:0]  data_b,
    output          wren_a,
    output          wren_b,
    input   [15:0]  q_a,
    input   [15:0]  q_b,
    output          mem_clock, 
    
    // Register view
    input   [2:0]   reg_sel,
    output  [15:0]  reg_view,
    output  [15:0]  instr_view,
    output  [15:0]  pc_view
);
    /*==========================================================================
    Local Parameters, Parametrized Macros
    ==========================================================================*/
    
    // Instruction types
    `define ALU_I(instr)        (instr[1:0] == 2'b11)   
    `define CALL_I(instr)       (instr[3:0] == 4'b1010)
    `define JUMPC_I(instr)      (instr[2:0] == 3'b110)
    `define JUMPUC_I(instr)     (instr[3:0] == 4'b0010)
    `define BRANCH_I(instr)     (`CALL_I(instr) | `JUMPC_I(instr) | \
                                 `JUMPUC_I(instr))                                
    `define GT_I(instr)         (instr[3:0] == 4'b1100)
    `define LT_I(instr)         (instr[3:0] == 4'b0100)
    `define CMP_I(instr)        (`GT_I(instr) | `LT_I(instr))
    `define LOAD_I(instr)       (instr[5:0] == 6'b000001)
    `define LOADHI_I(instr)     (instr[4:0] == 5'b10001)
    `define LOADIMM_I(instr)    (instr[3:0] == 4'b1001)
    `define STORE_I(instr)      (instr[5:0] == 6'b100001)
    `define STOP_I(instr)       (instr[15:0] == 16'h8000)
    
    // Encoding
    `define ALUOP(instr)        (instr[4:2])
    `define BRANCHCOND(instr)   (instr[3])
    `define BRANCHREG(instr)    (~instr[4])
    `define BYTEWORD(instr)     (instr[6])
    `define IMM(instr)          (instr[5])
    `define LINK(instr)         (instr[3])
    `define LOADSIGNED(instr)   (instr[7])
    `define REGA(instr)         (instr[12:10])
    `define REGB(instr)         (instr[9:7])
    `define REGD(instr)         (instr[15:13])
    `define SIGNED(instr)       (instr[4])
    
    // Immediates
    // SEb : sign extend b-bit immediate
    // ZEb : zero extend b-bit immediate
    // HI8 : 8-bit immediate in the higher byte, 0 in the lower byte
    `define HI8(instr)      ({instr[12:5], 8'b0})
    `define SE4(instr)      ({{12{instr[9]}}, instr[9:6]})
    `define SE8(instr)      ({{8{instr[12]}}, instr[12:5]})
    `define SE11(instr)     ({{5{instr[15]}}, instr[15:5]})
    `define ZE4(instr)      ({12'b0, instr[9:6]})
    `define ZE8(instr)      ({8'b0, instr[12:5]})
    
    // Stages
    localparam IF = 2'b00;
    localparam DC = 2'b01;
    localparam EM = 2'b10;
    localparam WB = 2'b11;
    
    // Constants
    localparam LINK_REG = 3'b111;
    
    
    /*==========================================================================
    Data/Control Wires, Pipeline Registers
    ==========================================================================*/
    
    // Stage 0 : Instruction Fetch
    wire    [15:0]  if_instr, if_pc;
    wire            if_pc_wren;
    
    wire    [15:0]  if_branch_addr, if_mem_addr, if_next_addr;
    wire            if_pc_src;
    
    register #(16)  if_pc_r(if_next_addr, if_pc, if_pc_wren, clock, reset);
    
    
    // Stage 1 : Instruction Decode 
    wire    [15:0]  dc_instr, dc_pc;
    wire            dc_instr_wren, dc_pc_wren;
    wire    [15:0]  dc_reg_a, dc_reg_b;
    wire            dc_reg_ab_wren;
    
    wire    [15:0]  dc_reg_a_in, dc_reg_b_in, dc_rf_a_out, dc_rf_b_out;
    wire    [2:0]   dc_rf_a_sel, dc_rf_b_sel;
    
    register #(16)  dc_instr_r(if_instr, dc_instr, dc_instr_wren, clock, reset);
    
    register #(16)  dc_pc_r(if_next_addr, dc_pc, dc_pc_wren, clock, reset);
    
    register #(16)  dc_reg_a_r(dc_reg_a_in, dc_reg_a, dc_reg_ab_wren, clock, 
                               reset);
    
    register #(16)  dc_reg_b_r(dc_reg_b_in, dc_reg_b, dc_reg_ab_wren, clock, 
                               reset);
    
    
    // Stage 2 : Execute or Memory 
    wire    [15:0]  em_instr, em_pc;
    wire            em_instr_wren, em_pc_wren;
    wire    [15:0]  em_alu_reg, em_mem_reg;
    wire            em_alu_reg_wren, em_mem_reg_wren;
    
    wire    [15:0]  em_reg_d_data;
    wire    [2:0]   em_reg_d_sel;
    wire            em_reg_wren;
    
    wire    [15:0]  em_alu_a, em_alu_b, em_alu_out, em_alu_reg_in;
    wire    [15:0]  em_cmp_out, em_imm;
    wire    [2:0]   em_alu_op;
    wire            v, c, n, z;
    
    wire    [15:0]  em_mem_data, em_mem_q, em_mem_addr;
    wire            em_mem_wren;
    
    register #(16)  em_instr_r(dc_instr, em_instr, em_instr_wren, clock, reset);
    
    register #(16)  em_pc_r(dc_pc, em_pc, em_pc_wren, clock, reset);
    
    register #(16)  em_alu_reg_r(em_alu_reg_in, em_alu_reg, em_alu_reg_wren, 
                                 clock, reset);
                          
    register #(16)  em_mem_reg_r(em_mem_q, em_mem_reg, em_mem_reg_wren, clock, 
                                 reset);
                          
    
    // Stage 3 : Register Writeback 
    wire    [15:0]  wb_instr, wb_pc;
    wire            wb_instr_wren, wb_pc_wren;
    
    wire    [15:0]  wb_reg_d_data;
    wire    [2:0]   wb_reg_d_sel;
    wire            wb_reg_wren;
    
    register #(16)  wb_instr_r(em_instr, wb_instr, wb_instr_wren, clock, reset);
    
    register #(16)  wb_pc_r(em_pc, wb_pc, wb_pc_wren, clock, reset);
    
    // Other pipeline logic
    wire    stop = `STOP_I(wb_instr);
    
    
    /*==========================================================================
    Execution/Storage Modules
    ==========================================================================*/
    
    // ALU 
    crp16_alu alu (
        .op_a(em_alu_a),    .op_b(em_alu_b), 
        .op_sel(em_alu_op), .alu_out(em_alu_out),
        .v(v), .c(c), .n(n), .z(z)
    );
    
    // Register File 
    crp16_register_file register_file (
        .clock(clock),              .reset(reset),
        .a_sel(dc_rf_a_sel),        .a_val(dc_rf_a_out),
        .b_sel(dc_rf_b_sel),        .b_val(dc_rf_b_out),
        .c_sel(reg_sel),            .c_val(reg_view),
        .write_sel(wb_reg_d_sel),   .write_val(wb_reg_d_data), 
        .write(wb_reg_wren)
    );
    
    // Memory
    assign mem_clock = clock;
    assign address_a = if_mem_addr;
    assign if_instr  = q_a;
    assign address_b = em_mem_addr;
    assign data_b    = em_mem_data;
    assign wren_b    = em_mem_wren;
    assign em_mem_q  = q_b;
  
    
    /*==========================================================================
    Fetch Stage Logic
    ==========================================================================*/
    
    assign if_next_addr = if_mem_addr + 16'd1;
    assign if_mem_addr  = if_pc_src ? if_branch_addr : if_pc;
    assign if_pc_wren   = ~stop;
    
    
    /*==========================================================================
    Decode Stage Logic
    ==========================================================================*/
    
    assign dc_instr_wren  = ~stop;
    assign dc_pc_wren     = ~stop;
    assign dc_reg_ab_wren = ~stop;
    
    assign dc_rf_a_sel    = `REGA(dc_instr);
    
    assign dc_rf_b_sel    = `JUMPC_I(dc_instr) | `LOADHI_I(dc_instr) |
                            `STORE_I(dc_instr) ? 
                            `REGD(dc_instr) : `REGB(dc_instr);
                           
    assign dc_reg_a_in    = em_reg_wren & (em_reg_d_sel == dc_rf_a_sel) ?
                                em_reg_d_data :
                            wb_reg_wren & (wb_reg_d_sel == dc_rf_a_sel) ?
                                wb_reg_d_data :
                            dc_rf_a_out;
                            
    assign dc_reg_b_in    = em_reg_wren & (em_reg_d_sel == dc_rf_b_sel) ?
                                em_reg_d_data :
                            wb_reg_wren & (wb_reg_d_sel == dc_rf_b_sel) ?
                                wb_reg_d_data :
                            dc_rf_b_out;
    
    // Branch address is 0xdead if not a branch instruction for easy error 
    // detection
    assign if_branch_addr = ~`BRANCH_I(dc_instr) ? 16'hdead :
                            `BRANCHREG(dc_instr) ? dc_reg_a_in :
                            `JUMPC_I(dc_instr)   ? dc_pc + `SE8(dc_instr) :
                            dc_pc + `SE11(dc_instr);
                         
    assign if_pc_src = `CALL_I(dc_instr) | `JUMPUC_I(dc_instr) |
                       (`JUMPC_I(dc_instr) & 
                       (`BRANCHCOND(dc_instr) == (|dc_reg_b_in)));
    
    
    /*==========================================================================
    Execute or Memory Stage Logic
    ==========================================================================*/
    
    // Pipeline registers
    assign em_instr_wren   = ~stop;
    assign em_pc_wren      = ~stop;
    assign em_alu_reg_wren = ~stop;
    assign em_mem_reg_wren = ~stop;
    
    // Operands
    assign em_imm = `LOADIMM_I(em_instr)   ?
                        (`SIGNED(em_instr) ? `SE8(em_instr) : `ZE8(em_instr)) :
                    `ALU_I(em_instr) | `CMP_I(em_instr) ?
                        (`SIGNED(em_instr) ? `SE4(em_instr) : `ZE4(em_instr)) :
                    16'h0;
               
    assign em_alu_a = `LOADHI_I(em_instr)  ? `HI8(em_instr) :
                      `LOADIMM_I(em_instr) ? 16'b0 : 
                      dc_reg_a;
    
    assign em_alu_b = `LOADHI_I(em_instr)  ? dc_reg_b[7:0] :
                      `LOADIMM_I(em_instr) | `IMM(em_instr) ? em_imm : 
                      dc_reg_b;
    
    // - Subtraction for lt/gt to get result from ALU flags
    // - Addition for loadi/loadhi for obvious reasons
    // - Doesn't matter for everything else
    assign em_alu_op  = `ALU_I(em_instr) ? `ALUOP(em_instr) :
                        `CMP_I(em_instr) ? 3'b001 : 
                        3'b000; 
    
    assign em_cmp_out = {15'b0, 
                        (`GT_I(em_instr) ? 
                             (`SIGNED(em_instr) ? (n == v) & (~z) : c & (~z)) :
                         `LT_I(em_instr) ?
                             (`SIGNED(em_instr) ? (n ^ v) : ~c) :
                          1'b0)};
    
    assign em_alu_reg_in = `ALU_I(em_instr)     ? em_alu_out :
                           `CMP_I(em_instr)     ? em_cmp_out :
                           `LOADIMM_I(em_instr) ? em_alu_out :
                           `LOADHI_I(em_instr)  ? em_alu_out :
                           16'hdead;
    
    assign em_mem_addr = dc_reg_a;
    assign em_mem_data = dc_reg_b;
    assign em_mem_wren = ~stop & `STORE_I(em_instr);
    
    // Advertising register to be written to for data hazard detection
    assign em_reg_d_sel  = `CALL_I(em_instr) ? LINK_REG : `REGD(em_instr);
    
    assign em_reg_d_data = `CALL_I(em_instr) ? em_pc : 
                           `LOAD_I(em_instr) ? em_mem_q :
                           (`ALU_I(em_instr)    | `LOADIMM_I(em_instr) |
                            `LOADHI_I(em_instr) | `CMP_I(em_instr)) ? 
                                em_alu_reg_in :
                           16'hdead;
    
    assign em_reg_wren   = ~stop & 
                           (`ALU_I(em_instr)  | `LOADIMM_I(em_instr) | 
                            `LOAD_I(em_instr) | `LOADHI_I(em_instr)  | 
                            `CALL_I(em_instr) | `CMP_I(em_instr));  
    
    
    /*==========================================================================
    Writeback Stage Logic
    ==========================================================================*/
    
    assign wb_instr_wren = ~stop;
    assign wb_pc_wren    = ~stop;
    
    assign wb_reg_d_sel  = `CALL_I(wb_instr) ? LINK_REG : `REGD(wb_instr);
    
    // Writes 0xdead to register for easy error detection
    assign wb_reg_d_data = `CALL_I(wb_instr) ? wb_pc : 
                           `LOAD_I(wb_instr) ? em_mem_reg :
                           (`ALU_I(wb_instr)    | `LOADIMM_I(wb_instr) |
                            `LOADHI_I(wb_instr) | `CMP_I(wb_instr)) ? 
                                em_alu_reg :
                           16'hdead;
    
    assign wb_reg_wren   = ~stop & 
                           (`ALU_I(wb_instr)  | `LOADIMM_I(wb_instr) | 
                            `LOAD_I(wb_instr) | `LOADHI_I(wb_instr)  | 
                            `CALL_I(wb_instr) | `CMP_I(wb_instr));   
    
    assign instr_view = wb_instr;
    assign pc_view    = wb_pc - 16'd1;
    
endmodule


`endif
