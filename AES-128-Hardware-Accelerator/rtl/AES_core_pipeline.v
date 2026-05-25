`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2026 07:29:12 PM
// Design Name: 
// Module Name: AES_core_pipeline
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


module AES_core_pipeline(
input clk,
input reset,
input in_valid,
input [127:0] plaintext,
input [127:0] key,
output [127:0] ciphertext,
output out_valid
    );
    
 wire [127:0] round_key0, round_key1, round_key2, round_key3, round_key4;
 wire[127:0] round_key5, round_key6, round_key7, round_key8, round_key9, round_key10;
    
 key_expansion KEY(
 .key(key),
 .round_key0(round_key0),.round_key1(round_key1),.round_key2(round_key2),
 .round_key3(round_key3),.round_key4(round_key4),.round_key5(round_key5),
 .round_key6(round_key6),.round_key7(round_key7),.round_key8(round_key8),
 .round_key9(round_key9),.round_key10(round_key10)
 );    
    
 wire [127:0] stage0_next,stage1_next,stage2_next,stage3_next,stage4_next,stage5_next;
 wire [127:0] stage6_next,stage7_next,stage8_next,stage9_next,stage10_next;
  
 reg [127:0] stage0_reg,stage1_reg,stage2_reg,stage3_reg,stage4_reg,stage5_reg;
 reg [127:0] stage6_reg,stage7_reg,stage8_reg,stage9_reg,stage10_reg;
  
 reg valid0,valid1,valid2,valid3,valid4,valid5;
 reg valid6,valid7,valid8,valid9,valid10;
 
 
 // initial AddRoundKey
    addroundkey ARK(
        .state_in(plaintext),
        .round_key(round_key0),
        .state_out(stage0_next)
    );

    // round 1
    AES_round AR1(
        .state_in(stage0_reg),
        .round_key(round_key1),
        .state_out(stage1_next)
    );

    // round 2
    AES_round AR2(
        .state_in(stage1_reg),
        .round_key(round_key2),
        .state_out(stage2_next)
    );

    // round 3
    AES_round AR3(
        .state_in(stage2_reg),
        .round_key(round_key3),
        .state_out(stage3_next)
    );

    // round 4
    AES_round AR4(
        .state_in(stage3_reg),
        .round_key(round_key4),
        .state_out(stage4_next)
    );

    // round 5
    AES_round AR5(
        .state_in(stage4_reg),
        .round_key(round_key5),
        .state_out(stage5_next)
    );

    // round 6
    AES_round AR6(
        .state_in(stage5_reg),
        .round_key(round_key6),
        .state_out(stage6_next)
    );

    // round 7
    AES_round AR7(
        .state_in(stage6_reg),
        .round_key(round_key7),
        .state_out(stage7_next)
    );

    // round 8
    AES_round AR8(
        .state_in(stage7_reg),
        .round_key(round_key8),
        .state_out(stage8_next)
    );

    // round 9
    AES_round AR9(
        .state_in(stage8_reg),
        .round_key(round_key9),
        .state_out(stage9_next)
    );

    // final round
    AES_final_round AFR(
        .state_in(stage9_reg),
        .round_key(round_key10),
        .state_out(stage10_next)
    );
    
    
    always @(posedge clk or posedge reset)
    begin
    if(reset)
    begin
    stage0_reg<=128'd0;stage1_reg<=128'd0;stage2_reg<=128'd0;stage3_reg<=128'd0;stage4_reg<=128'd0;stage5_reg<=128'd0;
    stage6_reg<=128'd0;stage7_reg<=128'd0;stage8_reg<=128'd0;stage9_reg<=128'd0;stage10_reg<=128'd0;
    
    valid0<=1'b0;valid1<=1'b0;valid2<=1'b0;valid3<=1'b0;valid4<=1'b0;valid5<=1'b0;
    valid6<=1'b0;valid7<=1'b0;valid8<=1'b0;valid9<=1'b0;valid10<=1'b0;
    end
    
    else
    begin
    stage0_reg<=stage0_next;stage1_reg<=stage1_next;stage2_reg<=stage2_next;stage3_reg<=stage3_next;stage4_reg<=stage4_next;stage5_reg<=stage5_next;
    stage6_reg<=stage6_next;stage7_reg<=stage7_next;stage8_reg<=stage8_next;stage9_reg<=stage9_next;stage10_reg<=stage10_next;
    
    valid0<=in_valid;valid1<=valid0;valid2<=valid1;valid3<=valid2;valid4<=valid3;valid5<=valid4;
    valid6<=valid5;valid7<=valid6;valid8<=valid7;valid9<=valid8;valid10<=valid9;
    end
    
    end
assign ciphertext = stage10_reg;
assign out_valid  = valid10;

    
endmodule
