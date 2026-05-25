`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2026 01:02:52 AM
// Design Name: 
// Module Name: AES_core
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


module AES_core(
input [127:0] plaintext,
input [127:0] key,
output [127:0] ciphertext
    );
    wire [127:0] round_key0, round_key1, round_key2, round_key3, round_key4;
    wire[127:0] round_key5, round_key6, round_key7, round_key8, round_key9, round_key10;
    
 key_expansion KE(
 .key(key),
 .round_key0(round_key0),.round_key1(round_key1),.round_key2(round_key2),
 .round_key3(round_key3),.round_key4(round_key4),.round_key5(round_key5),
 .round_key6(round_key6),.round_key7(round_key7),.round_key8(round_key8),
 .round_key9(round_key9),.round_key10(round_key10)
 );   

wire[127:0] state0,state1,state2,state3,state4,state5,state6,state7,state8,state9;

// initial AddRoundKey
    addroundkey ARK(
        .state_in(plaintext),
        .round_key(round_key0),
        .state_out(state0)
    );

    // round 1
    AES_round AR1(
        .state_in(state0),
        .round_key(round_key1),
        .state_out(state1)
    );

    // round 2
    AES_round AR2(
        .state_in(state1),
        .round_key(round_key2),
        .state_out(state2)
    );

    // round 3
    AES_round AR3(
        .state_in(state2),
        .round_key(round_key3),
        .state_out(state3)
    );

    // round 4
    AES_round AR4(
        .state_in(state3),
        .round_key(round_key4),
        .state_out(state4)
    );

    // round 5
    AES_round AR5(
        .state_in(state4),
        .round_key(round_key5),
        .state_out(state5)
    );

    // round 6
    AES_round AR6(
        .state_in(state5),
        .round_key(round_key6),
        .state_out(state6)
    );

    // round 7
    AES_round AR7(
        .state_in(state6),
        .round_key(round_key7),
        .state_out(state7)
    );

    // round 8
    AES_round AR8(
        .state_in(state7),
        .round_key(round_key8),
        .state_out(state8)
    );

    // round 9
    AES_round AR9(
        .state_in(state8),
        .round_key(round_key9),
        .state_out(state9)
    );

    // final round
    AES_final_round AFR(
        .state_in(state9),
        .round_key(round_key10),
        .state_out(ciphertext)
    );


endmodule
