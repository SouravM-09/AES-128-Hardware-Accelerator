`timescale 1ns/1ps

module tb_AES_random;

    reg clk;
    reg reset;
    reg in_valid;
    reg [127:0] plaintext;
    reg [127:0] key;

    wire [127:0] ref_cipher;
    wire [127:0] pipe_cipher;
    wire out_valid;

    integer i;
    integer sent_count;
    integer recv_count;
    integer pass_count;
    integer fail_count;

    reg [127:0] expected [0:19];

    // Reference combinational AES
    AES_core REF (
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ref_cipher)
    );

    // Pipeline AES
    AES_core_pipeline DUT (
        .clk(clk),
        .reset(reset),
        .in_valid(in_valid),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(pipe_cipher),
        .out_valid(out_valid)
    );

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        in_valid = 0;
        plaintext = 128'd0;
        key = 128'h000102030405060708090A0B0C0D0E0F;

        sent_count = 0;
        recv_count = 0;
        pass_count = 0;
        fail_count = 0;

        #20;
        reset = 0;

        // send 10 random plaintext blocks
        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);
            plaintext = { $random, $random, $random, $random };
            #1;  // allow REF output to settle
            expected[sent_count] = ref_cipher;
            in_valid = 1'b1;
            sent_count = sent_count + 1;
        end

        @(negedge clk);
        in_valid = 1'b0;
    end

    always @(posedge clk) begin
        if (out_valid) begin
            $display("Random test %0d: expected=%h got=%h",
                     recv_count, expected[recv_count], pipe_cipher);

            if (pipe_cipher == expected[recv_count]) begin
                $display("PASS");
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL");
                fail_count = fail_count + 1;
            end

            recv_count = recv_count + 1;

            if (recv_count == 10) begin
                $display("Random verification completed: PASS=%0d FAIL=%0d",
                         pass_count, fail_count);
                #20;
                $stop;
            end
        end
    end

endmodule