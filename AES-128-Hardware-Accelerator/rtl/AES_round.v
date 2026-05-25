`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 09:10:07 PM
// Design Name: 
// Module Name: AES_round
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


module AES_round(
input[127:0] state_in,
input[127:0] round_key,
output [127:0] state_out
    );
wire [127:0] sub_out;
wire [127:0] shift_out;
wire [127:0] mix_out;

subbyte SB(.state_in(state_in),.state_out(sub_out));
shiftrows SR(.state_in(sub_out),.state_out(shift_out));
MixColumns MC(.state_in(shift_out),.state_out(mix_out));
addroundkey ARK(.state_in(mix_out),.round_key(round_key),.state_out(state_out));

endmodule
