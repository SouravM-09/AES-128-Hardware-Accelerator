`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 11:11:36 PM
// Design Name: 
// Module Name: AES_final_round
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


module AES_final_round(
input[127:0] state_in,
input[127:0] round_key,
output [127:0] state_out
    );
    
wire [127:0] sub_out;
wire [127:0] shift_out;

subbyte SB(.state_in(state_in),.state_out(sub_out));
shiftrows SR(.state_in(sub_out),.state_out(shift_out));
addroundkey ARK(.state_in(shift_out),.round_key(round_key),.state_out(state_out));

endmodule
