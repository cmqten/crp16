`ifndef EXTEND_16
`define EXTEND_16

module extend_16 (val, zero_sign, val_ext);
    parameter       val_width = 4;
    
    input   [(val_width-1):0]   val;
    input           zero_sign;
    output  [15:0]  val_ext;
    
    // sign extend or zero extend
    assign val_ext = zero_sign ? {{(16-val_width){val[(val_width-1)]}}, val} :
                                 {{(16-val_width){1'b0}}, val};

endmodule

`endif
