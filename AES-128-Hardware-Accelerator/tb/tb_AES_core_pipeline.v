`timescale 1ns/1ps

module tb_AES_core_pipeline;

    reg clk;
    reg reset;
    reg in_valid;
    reg [127:0] plaintext;
    reg [127:0] key;
    wire [127:0] ciphertext;
    wire out_valid;

    AES_core_pipeline uut (
        .clk(clk),
        .reset(reset),
        .in_valid(in_valid),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext),
        .out_valid(out_valid)
    );

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        in_valid = 0;
        plaintext = 128'd0;
        key = 128'd0;

        // keep reset for a few cycles
        #20;
        reset = 0;

        // apply input BEFORE posedge, so DUT samples cleanly
        @(negedge clk);
        plaintext = 128'h00112233445566778899AABBCCDDEEFF;
        key       = 128'h000102030405060708090A0B0C0D0E0F;
        in_valid  = 1'b1;

        // keep valid for one full clock cycle
        @(negedge clk);
        in_valid  = 1'b0;
    end

    always @(posedge clk) begin
        if (out_valid) begin
            $display("Time = %0t, Ciphertext = %h", $time, ciphertext);

            if (ciphertext == 128'h69C4E0D86A7B0430D8CDB78070B4C55A)
                $display("PASS: Pipeline AES correct");
            else
                $display("FAIL: Pipeline AES incorrect");

            $stop;
        end
    end

endmodule