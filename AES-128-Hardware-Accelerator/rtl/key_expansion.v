`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 11:22:00 PM
// Design Name: 
// Module Name: key_expansion
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

module subword32(
    input  [31:0] in,
    output [31:0] out
);

    sbox s0 (.in(in[31:24]), .out(out[31:24]));
    sbox s1 (.in(in[23:16]), .out(out[23:16]));
    sbox s2 (.in(in[15:8]),  .out(out[15:8]));
    sbox s3 (.in(in[7:0]),   .out(out[7:0]));

endmodule

module key_expansion(
    input  [127:0] key,
    output [127:0] round_key0, round_key1, round_key2, round_key3, round_key4,
    output [127:0] round_key5, round_key6, round_key7, round_key8, round_key9, round_key10
);

    wire [31:0] w0,  w1,  w2,  w3;
    wire [31:0] w4,  w5,  w6,  w7;
    wire [31:0] w8,  w9,  w10, w11;
    wire [31:0] w12, w13, w14, w15;
    wire [31:0] w16, w17, w18, w19;
    wire [31:0] w20, w21, w22, w23;
    wire [31:0] w24, w25, w26, w27;
    wire [31:0] w28, w29, w30, w31;
    wire [31:0] w32, w33, w34, w35;
    wire [31:0] w36, w37, w38, w39;
    wire [31:0] w40, w41, w42, w43;

    assign w0 = key[127:96];
    assign w1 = key[95:64];
    assign w2 = key[63:32];
    assign w3 = key[31:0];

    assign round_key0 = {w0, w1, w2, w3};

    wire [31:0] rot_w3,  sub_w3,  g_w3;
    wire [31:0] rot_w7,  sub_w7,  g_w7;
    wire [31:0] rot_w11, sub_w11, g_w11;
    wire [31:0] rot_w15, sub_w15, g_w15;
    wire [31:0] rot_w19, sub_w19, g_w19;
    wire [31:0] rot_w23, sub_w23, g_w23;
    wire [31:0] rot_w27, sub_w27, g_w27;
    wire [31:0] rot_w31, sub_w31, g_w31;
    wire [31:0] rot_w35, sub_w35, g_w35;
    wire [31:0] rot_w39, sub_w39, g_w39;

    assign rot_w3  = {w3[23:16],  w3[15:8],  w3[7:0],  w3[31:24]};
    assign rot_w7  = {w7[23:16],  w7[15:8],  w7[7:0],  w7[31:24]};
    assign rot_w11 = {w11[23:16], w11[15:8], w11[7:0], w11[31:24]};
    assign rot_w15 = {w15[23:16], w15[15:8], w15[7:0], w15[31:24]};
    assign rot_w19 = {w19[23:16], w19[15:8], w19[7:0], w19[31:24]};
    assign rot_w23 = {w23[23:16], w23[15:8], w23[7:0], w23[31:24]};
    assign rot_w27 = {w27[23:16], w27[15:8], w27[7:0], w27[31:24]};
    assign rot_w31 = {w31[23:16], w31[15:8], w31[7:0], w31[31:24]};
    assign rot_w35 = {w35[23:16], w35[15:8], w35[7:0], w35[31:24]};
    assign rot_w39 = {w39[23:16], w39[15:8], w39[7:0], w39[31:24]};

    subword32 sw0 (.in(rot_w3),  .out(sub_w3));
    subword32 sw1 (.in(rot_w7),  .out(sub_w7));
    subword32 sw2 (.in(rot_w11), .out(sub_w11));
    subword32 sw3 (.in(rot_w15), .out(sub_w15));
    subword32 sw4 (.in(rot_w19), .out(sub_w19));
    subword32 sw5 (.in(rot_w23), .out(sub_w23));
    subword32 sw6 (.in(rot_w27), .out(sub_w27));
    subword32 sw7 (.in(rot_w31), .out(sub_w31));
    subword32 sw8 (.in(rot_w35), .out(sub_w35));
    subword32 sw9 (.in(rot_w39), .out(sub_w39));

    assign g_w3  = sub_w3  ^ 32'h01000000;
    assign g_w7  = sub_w7  ^ 32'h02000000;
    assign g_w11 = sub_w11 ^ 32'h04000000;
    assign g_w15 = sub_w15 ^ 32'h08000000;
    assign g_w19 = sub_w19 ^ 32'h10000000;
    assign g_w23 = sub_w23 ^ 32'h20000000;
    assign g_w27 = sub_w27 ^ 32'h40000000;
    assign g_w31 = sub_w31 ^ 32'h80000000;
    assign g_w35 = sub_w35 ^ 32'h1b000000;
    assign g_w39 = sub_w39 ^ 32'h36000000;

    assign w4  = w0  ^ g_w3;
    assign w5  = w1  ^ w4;
    assign w6  = w2  ^ w5;
    assign w7  = w3  ^ w6;
    assign round_key1 = {w4, w5, w6, w7};

    assign w8  = w4  ^ g_w7;
    assign w9  = w5  ^ w8;
    assign w10 = w6  ^ w9;
    assign w11 = w7  ^ w10;
    assign round_key2 = {w8, w9, w10, w11};

    assign w12 = w8  ^ g_w11;
    assign w13 = w9  ^ w12;
    assign w14 = w10 ^ w13;
    assign w15 = w11 ^ w14;
    assign round_key3 = {w12, w13, w14, w15};

    assign w16 = w12 ^ g_w15;
    assign w17 = w13 ^ w16;
    assign w18 = w14 ^ w17;
    assign w19 = w15 ^ w18;
    assign round_key4 = {w16, w17, w18, w19};

    assign w20 = w16 ^ g_w19;
    assign w21 = w17 ^ w20;
    assign w22 = w18 ^ w21;
    assign w23 = w19 ^ w22;
    assign round_key5 = {w20, w21, w22, w23};

    assign w24 = w20 ^ g_w23;
    assign w25 = w21 ^ w24;
    assign w26 = w22 ^ w25;
    assign w27 = w23 ^ w26;
    assign round_key6 = {w24, w25, w26, w27};

    assign w28 = w24 ^ g_w27;
    assign w29 = w25 ^ w28;
    assign w30 = w26 ^ w29;
    assign w31 = w27 ^ w30;
    assign round_key7 = {w28, w29, w30, w31};

    assign w32 = w28 ^ g_w31;
    assign w33 = w29 ^ w32;
    assign w34 = w30 ^ w33;
    assign w35 = w31 ^ w34;
    assign round_key8 = {w32, w33, w34, w35};

    assign w36 = w32 ^ g_w35;
    assign w37 = w33 ^ w36;
    assign w38 = w34 ^ w37;
    assign w39 = w35 ^ w38;
    assign round_key9 = {w36, w37, w38, w39};

    assign w40 = w36 ^ g_w39;
    assign w41 = w37 ^ w40;
    assign w42 = w38 ^ w41;
    assign w43 = w39 ^ w42;
    assign round_key10 = {w40, w41, w42, w43};

endmodule
