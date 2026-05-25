`timescale 1ns/1ps

module tb_AES_system_top;

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

    reg [31:0] out0, out1, out2, out3;

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------
    // CONTROL AXI WRITE
    // ---------------------------------
    task ctrl_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            ctrl_AWADDR  <= addr;
            ctrl_WDATA   <= data;
            ctrl_AWVALID <= 1'b1;
            ctrl_WVALID  <= 1'b1;
            ctrl_BREADY  <= 1'b1;

            @(posedge clk);
            ctrl_AWVALID <= 1'b0;
            ctrl_WVALID  <= 1'b0;

            repeat(2) @(posedge clk);
            ctrl_BREADY <= 1'b0;
        end
    endtask

    // ---------------------------------
    // CONTROL AXI READ
    // ---------------------------------
    task ctrl_read;
        input [31:0] addr;
        begin
            @(posedge clk);
            ctrl_ARADDR  <= addr;
            ctrl_ARVALID <= 1'b1;
            ctrl_RREADY  <= 1'b1;

            @(posedge clk);
            ctrl_ARVALID <= 1'b0;

            repeat(2) @(posedge clk);
            $display("CTRL Read [%h] = %h", addr, ctrl_RDATA);
            ctrl_RREADY <= 1'b0;
        end
    endtask

    // ---------------------------------
    // MEMORY AXI WRITE
    // ---------------------------------
    task mem_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            mem_AWADDR  <= addr;
            mem_WDATA   <= data;
            mem_AWVALID <= 1'b1;
            mem_WVALID  <= 1'b1;
            mem_BREADY  <= 1'b1;

            @(posedge clk);
            mem_AWVALID <= 1'b0;
            mem_WVALID  <= 1'b0;

            repeat(2) @(posedge clk);
            mem_BREADY <= 1'b0;
        end
    endtask

    // ---------------------------------
    // MEMORY AXI READ
    // ---------------------------------
    task mem_read;
        input [31:0] addr;
        output [31:0] data;
        begin
            @(posedge clk);
            mem_ARADDR  <= addr;
            mem_ARVALID <= 1'b1;
            mem_RREADY  <= 1'b1;

            @(posedge clk);
            mem_ARVALID <= 1'b0;

            repeat(2) @(posedge clk);
            data = mem_RDATA;
            $display("MEM Read [%h] = %h", addr, data);
            mem_RREADY <= 1'b0;
        end
    endtask

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

        out0 = 32'd0;
        out1 = 32'd0;
        out2 = 32'd0;
        out3 = 32'd0;

        #20;
        reset = 1'b0;

        // ---------------------------------
        // Write plaintext into memory
        // mem[0..3]
        // ---------------------------------
        mem_write(32'h00000000, 32'h00112233);
        mem_write(32'h00000004, 32'h44556677);
        mem_write(32'h00000008, 32'h8899AABB);
        mem_write(32'h0000000C, 32'hCCDDEEFF);

        // ---------------------------------
        // Write key into control registers
        // ---------------------------------
        ctrl_write(32'h00000008, 32'h00010203);
        ctrl_write(32'h0000000C, 32'h04050607);
        ctrl_write(32'h00000010, 32'h08090A0B);
        ctrl_write(32'h00000014, 32'h0C0D0E0F);

        // ---------------------------------
        // Start
        // ---------------------------------
        ctrl_write(32'h00000000, 32'h00000001);

        // wait long enough
        repeat(120) @(posedge clk);

        // read status
        ctrl_read(32'h00000004);

        // ---------------------------------
        // Read ciphertext from memory
        // mem[4..7] => addresses 0x10,0x14,0x18,0x1C
        // ---------------------------------
        mem_read(32'h00000010, out0);
        mem_read(32'h00000014, out1);
        mem_read(32'h00000018, out2);
        mem_read(32'h0000001C, out3);

        if (out0 == 32'h69C4E0D8 &&
            out1 == 32'h6A7B0430 &&
            out2 == 32'hD8CDB780 &&
            out3 == 32'h70B4C55A)
            $display("PASS: AES_system_top correct");
        else
            $display("FAIL: AES_system_top incorrect");

        #20;
        $stop;
    end

endmodule