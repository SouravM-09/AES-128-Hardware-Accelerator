`timescale 1ns/1ps

module tb_AES_top_control;

    reg clk;
    reg reset;
    reg start;
    reg stop;
    reg data_in_valid;
    reg [31:0] data_in;
    reg [127:0] key;
    reg key_valid;

    wire [31:0] data_out;
    wire out_valid;
    wire done;
    wire busy;
    wire idle;

    AES_top_control uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .stop(stop),
        .data_in_valid(data_in_valid),
        .data_in(data_in),
        .key(key),
        .key_valid(key_valid),
        .data_out(data_out),
        .out_valid(out_valid),
        .done(done),
        .busy(busy),
        .idle(idle)
    );

    reg [31:0] out0, out1, out2, out3;
    integer idx;

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        start = 0;
        stop = 0;
        data_in_valid = 0;
        data_in = 32'd0;
        key = 128'd0;
        key_valid = 0;
        idx = 0;

        // reset hold
        #20;
        reset = 0;

        // load key while idle
        @(negedge clk);
        key = 128'h000102030405060708090A0B0C0D0E0F;
        key_valid = 1'b1;

        @(negedge clk);
        key_valid = 1'b0;

        // start transaction
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // send 4 input words
        @(negedge clk);
        data_in_valid = 1'b1;
        data_in = 32'h00112233;

        @(negedge clk);
        data_in = 32'h44556677;

        @(negedge clk);
        data_in = 32'h8899AABB;

        @(negedge clk);
        data_in = 32'hCCDDEEFF;

        @(negedge clk);
        data_in_valid = 1'b0;
        data_in = 32'd0;
    end

    // capture output words
    always @(posedge clk) begin
        if (out_valid) begin
            case (idx)
                0: out0 <= data_out;
                1: out1 <= data_out;
                2: out2 <= data_out;
                3: out3 <= data_out;
            endcase

            $display("Output word %0d = %h", idx, data_out);
            idx <= idx + 1;
        end
    end

    // monitor status
    always @(posedge clk) begin
        if (done) begin
            $display("DONE pulse detected");
            $display("busy = %b, idle = %b", busy, idle);

            if (out0 == 32'h69C4E0D8 &&
                out1 == 32'h6A7B0430 &&
                out2 == 32'hD8CDB780 &&
                out3 == 32'h70B4C55A)
                $display("PASS: AES_top_control correct");
            else
                $display("FAIL: AES_top_control incorrect");

            #10;
            $stop;
        end
    end

endmodule