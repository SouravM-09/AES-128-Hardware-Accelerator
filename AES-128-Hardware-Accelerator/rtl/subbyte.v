`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 07:51:35 PM
// Design Name: 
// Module Name: subbyte
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module subbyte(
 input  [127:0] state_in,
 output [127:0] state_out
    );
sbox s0  (.in(state_in[127:120]), .out(state_out[127:120]));
sbox s1  (.in(state_in[119:112]), .out(state_out[119:112]));
sbox s2  (.in(state_in[111:104]), .out(state_out[111:104]));
sbox s3  (.in(state_in[103:96]),  .out(state_out[103:96]));
sbox s4  (.in(state_in[95:88]),   .out(state_out[95:88]));
sbox s5  (.in(state_in[87:80]),   .out(state_out[87:80]));
sbox s6  (.in(state_in[79:72]),   .out(state_out[79:72]));
sbox s7  (.in(state_in[71:64]),   .out(state_out[71:64]));
sbox s8  (.in(state_in[63:56]),   .out(state_out[63:56]));
sbox s9  (.in(state_in[55:48]),   .out(state_out[55:48]));
sbox s10 (.in(state_in[47:40]),   .out(state_out[47:40]));
sbox s11 (.in(state_in[39:32]),   .out(state_out[39:32]));
sbox s12 (.in(state_in[31:24]),   .out(state_out[31:24]));
sbox s13 (.in(state_in[23:16]),   .out(state_out[23:16]));
sbox s14 (.in(state_in[15:8]),    .out(state_out[15:8]));
sbox s15 (.in(state_in[7:0]),     .out(state_out[7:0]));
endmodule
