/* Displays the hex value of a 4-bit binary number on a 7 segment display */

module hex_decoder(SW, HEX0);
    input [3:0] SW; // switches
    output [6:0] HEX0; // 7 segment
    
    assign HEX0[0] = (~SW[2] | ~SW[1]) & (~SW[3] | SW[0]) & (~SW[3] | SW[2] | SW[1]) 
        & (SW[2] | SW[0]) & (SW[3] | ~SW[2] | ~SW[0]) & (SW[3] | SW[2] | ~SW[1]);
    assign HEX0[1] = (SW[3] | SW[2]) & (SW[2] | SW[0]) & (~SW[3] | SW[1] | ~SW[0]) 
        & (SW[3] | SW[1] | SW[0]) & (SW[3] | ~SW[1] | ~SW[0]);
    assign HEX0[2] = (SW[3] | ~SW[2]) & (~SW[3] | SW[2]) & (SW[2] | ~SW[0]) 
        & (SW[3] | SW[1]) & (SW[1] | ~SW[0]);
    assign HEX0[3] = (~SW[3] | SW[1]) & (SW[3] | SW[2] | SW[0]) & (SW[2] | ~SW[1] | ~SW[0])
        & (~SW[2] | ~SW[1] | SW[0]) & (~SW[2] | SW[1] | ~SW[0]);
    assign HEX0[4] = (~SW[3] | ~SW[2]) & (~SW[1] | SW[0]) & (SW[2] | SW[0])
        & (~SW[3] | ~SW[1]);
    assign HEX0[5] = (SW[1] | SW[0]) & (~SW[3] | SW[2]) & (~SW[2] | SW[0]) & (~SW[3] | ~SW[1])
        & (SW[3] | ~SW[2] | SW[1]);
    assign HEX0[6] = (~SW[3] | SW[2]) & (SW[2] | ~SW[1]) & (~SW[1] | SW[0])
        & (~SW[3] | ~SW[0]) & (SW[3] | ~SW[2] | SW[1]);
endmodule