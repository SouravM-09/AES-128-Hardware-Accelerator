`timescale 1ns/1ps

module tb_AES_system_top_final;
  initial begin
    $dumpfile("aes.vcd");
    $dumpvars(0, tb_AES_system_top_final);
end
    reg clk;
    reg reset;

    // ----------------------------
    // CONTROL AXI PORTS
    // ----------------------------
    reg  [31:0] ctrl_AWADDR;
    reg         ctrl_AWVALID;
    wire        ctrl_AWREADY;

    reg  [31:0] ctrl_WDATA;
    reg         ctrl_WVALID;
    wire        ctrl_WREADY;

    wire        ctrl_BVALID;
    reg         ctrl_BREADY;

    reg  [31:0] ctrl_ARADDR;
    reg         ctrl_ARVALID;
    wire        ctrl_ARREADY;

    wire [31:0] ctrl_RDATA;
    wire        ctrl_RVALID;
    reg         ctrl_RREADY;

    // ----------------------------
    // MEMORY AXI PORTS
    // ----------------------------
    reg  [31:0] mem_AWADDR;
    reg         mem_AWVALID;
    wire        mem_AWREADY;

    reg  [31:0] mem_WDATA;
    reg         mem_WVALID;
    wire        mem_WREADY;

    wire        mem_BVALID;
    reg         mem_BREADY;

    reg  [31:0] mem_ARADDR;
    reg         mem_ARVALID;
    wire        mem_ARREADY;

    wire [31:0] mem_RDATA;
    wire        mem_RVALID;
    reg         mem_RREADY;

    // DUT
    AES_system_top uut (
        .clk(clk),
        .reset(reset),

        .ctrl_AWADDR(ctrl_AWADDR),
        .ctrl_AWVALID(ctrl_AWVALID),
        .ctrl_AWREADY(ctrl_AWREADY),

        .ctrl_WDATA(ctrl_WDATA),
        .ctrl_WVALID(ctrl_WVALID),
        .ctrl_WREADY(ctrl_WREADY),

        .ctrl_BVALID(ctrl_BVALID),
        .ctrl_BREADY(ctrl_BREADY),

        .ctrl_ARADDR(ctrl_ARADDR),
        .ctrl_ARVALID(ctrl_ARVALID),
        .ctrl_ARREADY(ctrl_ARREADY),

        .ctrl_RDATA(ctrl_RDATA),
        .ctrl_RVALID(ctrl_RVALID),
        .ctrl_RREADY(ctrl_RREADY),

        .mem_AWADDR(mem_AWADDR),
        .mem_AWVALID(mem_AWVALID),
        .mem_AWREADY(mem_AWREADY),

        .mem_WDATA(mem_WDATA),
        .mem_WVALID(mem_WVALID),
        .mem_WREADY(mem_WREADY),

        .mem_BVALID(mem_BVALID),
        .mem_BREADY(mem_BREADY),

        .mem_ARADDR(mem_ARADDR),
        .mem_ARVALID(mem_ARVALID),
        .mem_ARREADY(mem_ARREADY),

        .mem_RDATA(mem_RDATA),
        .mem_RVALID(mem_RVALID),
        .mem_RREADY(mem_RREADY)
    );

    // Reference AES for expected ciphertext generation
    reg  [127:0] ref_plaintext;
    reg  [127:0] ref_key;
    wire [127:0] ref_ciphertext;

    AES_core REF (
        .plaintext(ref_plaintext),
        .key(ref_key),
        .ciphertext(ref_ciphertext)
    );

    reg [31:0] out0, out1, out2, out3;
    reg [127:0] current_key;
    reg [127:0] expected_block;
    reg [127:0] expected_busy_block;
    integer pass_count;
    integer fail_count;
    integer i;

    // ----------------------------
  
    // clock
    // ----------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ----------------------------
    // AXI TASKS
    // ----------------------------
    task ctrl_write;
        input [31:0] addr;
        input [31:0] data;
        input integer delay_bready_cycles;
        begin
            @(posedge clk);
            ctrl_AWADDR  <= addr;
            ctrl_WDATA   <= data;
            ctrl_AWVALID <= 1'b1;
            ctrl_WVALID  <= 1'b1;

            @(posedge clk);
            ctrl_AWVALID <= 1'b0;
            ctrl_WVALID  <= 1'b0;

            repeat(delay_bready_cycles) @(posedge clk);
            ctrl_BREADY <= 1'b1;
            @(posedge clk);
            ctrl_BREADY <= 1'b0;
        end
    endtask

    task ctrl_read;
        input [31:0] addr;
        input integer delay_rready_cycles;
        begin
            @(posedge clk);
            ctrl_ARADDR  <= addr;
            ctrl_ARVALID <= 1'b1;

            @(posedge clk);
            ctrl_ARVALID <= 1'b0;

            repeat(delay_rready_cycles) @(posedge clk);
            ctrl_RREADY <= 1'b1;
            @(posedge clk);
            $display("CTRL Read [%h] = %h", addr, ctrl_RDATA);
            ctrl_RREADY <= 1'b0;
        end
    endtask

    task mem_write;
        input [31:0] addr;
        input [31:0] data;
        input integer delay_bready_cycles;
        begin
            @(posedge clk);
            mem_AWADDR  <= addr;
            mem_WDATA   <= data;
            mem_AWVALID <= 1'b1;
            mem_WVALID  <= 1'b1;

            @(posedge clk);
            mem_AWVALID <= 1'b0;
            mem_WVALID  <= 1'b0;

            repeat(delay_bready_cycles) @(posedge clk);
            mem_BREADY <= 1'b1;
            @(posedge clk);
            mem_BREADY <= 1'b0;
        end
    endtask

    task mem_read;
        input [31:0] addr;
        input integer delay_rready_cycles;
        output [31:0] data;
        begin
            @(posedge clk);
            mem_ARADDR  <= addr;
            mem_ARVALID <= 1'b1;

            @(posedge clk);
            mem_ARVALID <= 1'b0;

            repeat(delay_rready_cycles) @(posedge clk);
            mem_RREADY <= 1'b1;
            @(posedge clk);
            data = mem_RDATA;
            $display("MEM Read [%h] = %h", addr, data);
            mem_RREADY <= 1'b0;
        end
    endtask

    // ----------------------------
    // Helper tasks
    // ----------------------------
    task load_key;
        input [127:0] key_in;
        input integer delayed_mode;
        begin
            current_key = key_in;
            if (delayed_mode == 0) begin
                ctrl_write(32'h00000008, key_in[127:96], 2);
                ctrl_write(32'h0000000C, key_in[95:64],  2);
                ctrl_write(32'h00000010, key_in[63:32],  2);
                ctrl_write(32'h00000014, key_in[31:0],   2);
            end
            else begin
                ctrl_write(32'h00000008, key_in[127:96], 5);
                ctrl_write(32'h0000000C, key_in[95:64],  4);
                ctrl_write(32'h00000010, key_in[63:32],  3);
                ctrl_write(32'h00000014, key_in[31:0],   5);
            end
        end
    endtask

    task compute_expected;
        input [127:0] ptext;
        input [127:0] k;
        begin
            ref_plaintext = ptext;
            ref_key = k;
            #1;
            expected_block = ref_ciphertext;
        end
    endtask

    task write_plaintext_to_memory;
        input [31:0] p0;
        input [31:0] p1;
        input [31:0] p2;
        input [31:0] p3;
        input integer delayed_mode;
        begin
            if (delayed_mode == 0) begin
                mem_write(32'h00000000, p0, 2);
                mem_write(32'h00000004, p1, 2);
                mem_write(32'h00000008, p2, 2);
                mem_write(32'h0000000C, p3, 2);
            end
            else begin
                mem_write(32'h00000000, p0, 5);
                mem_write(32'h00000004, p1, 4);
                mem_write(32'h00000008, p2, 3);
                mem_write(32'h0000000C, p3, 5);
            end
        end
    endtask

    task start_block;
        input integer delayed_mode;
        begin
            if (delayed_mode == 0)
                ctrl_write(32'h00000000, 32'h00000001, 2);
            else
                ctrl_write(32'h00000000, 32'h00000001, 5);
        end
    endtask

    task read_ciphertext_from_memory;
        input integer delayed_mode;
        begin
            if (delayed_mode == 0) begin
                mem_read(32'h00000010, 2, out0);
                mem_read(32'h00000014, 2, out1);
                mem_read(32'h00000018, 2, out2);
                mem_read(32'h0000001C, 2, out3);
            end
            else begin
                mem_read(32'h00000010, 5, out0);
                mem_read(32'h00000014, 4, out1);
                mem_read(32'h00000018, 3, out2);
                mem_read(32'h0000001C, 5, out3);
            end
        end
    endtask

    task check_expected;
        input [127:0] exp;
        input [255:0] testname;
        begin
            if ({out0,out1,out2,out3} == exp) begin
                $display("PASS: %0s", testname);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: %0s", testname);
                $display("Expected = %h", exp);
                $display("Got      = %h%h%h%h", out0, out1, out2, out3);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task run_one_block_and_check;
        input [31:0] p0;
        input [31:0] p1;
        input [31:0] p2;
        input [31:0] p3;
        input integer delayed_mode;
        input [255:0] testname;
        reg [127:0] pblock;
        begin
            pblock = {p0,p1,p2,p3};
            compute_expected(pblock, current_key);

            write_plaintext_to_memory(p0,p1,p2,p3,delayed_mode);
            start_block(delayed_mode);

            repeat(120) @(posedge clk);
            ctrl_read(32'h00000004, delayed_mode ? 5 : 2);
            read_ciphertext_from_memory(delayed_mode);

            check_expected(expected_block, testname);
        end
    endtask

    // ----------------------------
    // TEST SEQUENCE
    // ----------------------------
    initial begin
        reset = 1'b1;

        ctrl_AWADDR = 32'd0;
        ctrl_AWVALID = 1'b0;
        ctrl_WDATA = 32'd0;
        ctrl_WVALID = 1'b0;
        ctrl_BREADY = 1'b0;
        ctrl_ARADDR = 32'd0;
        ctrl_ARVALID = 1'b0;
        ctrl_RREADY = 1'b0;

        mem_AWADDR = 32'd0;
        mem_AWVALID = 1'b0;
        mem_WDATA = 32'd0;
        mem_WVALID = 1'b0;
        mem_BREADY = 1'b0;
        mem_ARADDR = 32'd0;
        mem_ARVALID = 1'b0;
        mem_RREADY = 1'b0;

        ref_plaintext = 128'd0;
        ref_key = 128'd0;
        current_key = 128'd0;
        expected_block = 128'd0;
        expected_busy_block = 128'd0;

        out0 = 32'd0; out1 = 32'd0; out2 = 32'd0; out3 = 32'd0;

        pass_count = 0;
        fail_count = 0;

        #20;
        reset = 1'b0;

        // ==========================================
        // TEST 1: Standard AES vector
        // ==========================================
        $display("===== TEST 1: STANDARD VECTOR =====");
        load_key(128'h000102030405060708090A0B0C0D0E0F, 0);
        run_one_block_and_check(
            32'h00112233, 32'h44556677, 32'h8899AABB, 32'hCCDDEEFF,
            0, "Standard AES vector"
        );

        // ==========================================
        // TEST 2: Multi-block operation
        // ==========================================
        $display("===== TEST 2: MULTI-BLOCK =====");
        run_one_block_and_check(
            32'h00000000, 32'h11111111, 32'h22222222, 32'h33333333,
            0, "Multi-block block 2"
        );

        run_one_block_and_check(
            32'hDEADBEEF, 32'hCAFEBABE, 32'h12345678, 32'hA5A5A5A5,
            0, "Multi-block block 3"
        );

        // ==========================================
        // TEST 3: Randomized verification
        // ==========================================
        $display("===== TEST 3: RANDOMIZED =====");
        for (i = 0; i < 3; i = i + 1) begin
            run_one_block_and_check(
                $random, $random, $random, $random,
                0, "Random block"
            );
        end

        // ==========================================
        // TEST 4: Key update behavior
        // ==========================================
        $display("===== TEST 4: KEY UPDATE =====");

        // Expected for first block with old key
        compute_expected(
            128'h00112233445566778899AABBCCDDEEFF,
            current_key
        );
        expected_busy_block = expected_block;

        // Launch block under old key
        write_plaintext_to_memory(32'h00112233, 32'h44556677, 32'h8899AABB, 32'hCCDDEEFF, 0);
        start_block(0);

        // Try changing key while system is busy
        repeat(20) @(posedge clk);
        load_key(128'h2B7E151628AED2A6ABF7158809CF4F3C, 0);

        repeat(120) @(posedge clk);
        read_ciphertext_from_memory(0);

        // Current block should still match old-key expectation
        if ({out0,out1,out2,out3} == expected_busy_block) begin
            $display("PASS: Busy-time key update did not corrupt in-flight block");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Busy-time key update corrupted current block");
            fail_count = fail_count + 1;
        end

        // Next block should use new key
        current_key = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
        run_one_block_and_check(
            32'h00112233, 32'h44556677, 32'h8899AABB, 32'hCCDDEEFF,
            0, "Idle-time updated key block"
        );

        // ==========================================
        // TEST 5: Delayed-ready / backpressure-style
        // ==========================================
        $display("===== TEST 5: DELAYED READY =====");
        load_key(128'h000102030405060708090A0B0C0D0E0F, 1);
        run_one_block_and_check(
            32'h0F0E0D0C, 32'h0B0A0908, 32'h07060504, 32'h03020100,
            1, "Delayed-ready AXI case"
        );

        // ==========================================
        // SUMMARY
        // ==========================================
        $display("======================================");
        $display("FINAL SUMMARY: PASS=%0d FAIL=%0d", pass_count, fail_count);
        $display("======================================");

        #40;
        $stop;
    end

endmodule