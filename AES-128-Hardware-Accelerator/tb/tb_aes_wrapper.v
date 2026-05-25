`timescale 1ns/1ps

module tb_AES_wrapper_32bit;

    reg clk;
    reg reset;
    reg in_valid;
    reg [31:0] data_in;
    reg [127:0] key;
    wire [31:0] data_out;
    wire out_valid;

    AES_wrapper_32bit uut (
        .clk(clk),
        .reset(reset),
        .in_valid(in_valid),
        .data_in(data_in),
        .key(key),
        .data_out(data_out),
        .out_valid(out_valid)
    );

    reg [31:0] out_words [0:3];
    integer idx;

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        in_valid = 0;
        data_in = 32'd0;
        key = 128'd0;
        idx = 0;

        #20;
        reset = 0;

        key = 128'h000102030405060708090A0B0C0D0E0F;

        // Send 4 input words before posedge sampling
        @(negedge clk);
        in_valid = 1'b1;
        data_in  = 32'h00112233;

        @(negedge clk);
        data_in  = 32'h44556677;

        @(negedge clk);
        data_in  = 32'h8899AABB;

        @(negedge clk);
        data_in  = 32'hCCDDEEFF;

        @(negedge clk);
        in_valid = 1'b0;
        data_in  = 32'd0;
    end

always @(posedge clk) begin
    if (out_valid) begin
        out_words[idx] = data_out;
        $display("Output word %0d = %h", idx, data_out);
        idx = idx + 1;

        if (idx == 4) begin
            if (out_words[0] == 32'h69C4E0D8 &&
                out_words[1] == 32'h6A7B0430 &&
                out_words[2] == 32'hD8CDB780 &&
                out_words[3] == 32'h70B4C55A)
                $display("PASS: Wrapper output correct");
            else
                $display("FAIL: Wrapper output incorrect");

            #10;
            $stop;
        end
    end
end
endmodule