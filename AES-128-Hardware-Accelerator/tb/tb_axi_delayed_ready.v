`timescale 1ns/1ps

module tb_AXI_delayed_ready;

    reg clk;
    reg reset;

    reg [31:0] AWADDR;
    reg AWVALID;
    wire AWREADY;

    reg [31:0] WDATA;
    reg WVALID;
    wire WREADY;

    wire BVALID;
    reg BREADY;

    reg [31:0] ARADDR;
    reg ARVALID;
    wire ARREADY;

    wire [31:0] RDATA;
    wire RVALID;
    reg RREADY;

    AES_axi_slave_memory uut (
        .clk(clk),
        .reset(reset),

        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),

        .WDATA(WDATA),
        .WVALID(WVALID),
        .WREADY(WREADY),

        .BVALID(BVALID),
        .BREADY(BREADY),

        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),

        .RDATA(RDATA),
        .RVALID(RVALID),
        .RREADY(RREADY),

        .mem_rd_en(1'b0),
        .mem_rd_addr(4'd0),
        .mem_rd_data(),

        .mem_wr_en(1'b0),
        .mem_wr_addr(4'd0),
        .mem_wr_data(32'd0)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        AWADDR = 0; AWVALID = 0;
        WDATA = 0;  WVALID = 0;
        BREADY = 0;
        ARADDR = 0; ARVALID = 0;
        RREADY = 0;

        #20;
        reset = 0;

        // Write with delayed BREADY
        @(posedge clk);
        AWADDR <= 32'h00000000;
        WDATA  <= 32'hA5A5A5A5;
        AWVALID <= 1'b1;
        WVALID  <= 1'b1;

        @(posedge clk);
        AWVALID <= 1'b0;
        WVALID  <= 1'b0;

        repeat(5) @(posedge clk);
        BREADY <= 1'b1;

        @(posedge clk);
        BREADY <= 1'b0;

        // Read with delayed RREADY
        @(posedge clk);
        ARADDR <= 32'h00000000;
        ARVALID <= 1'b1;

        @(posedge clk);
        ARVALID <= 1'b0;

        repeat(5) @(posedge clk);
        RREADY <= 1'b1;

        @(posedge clk);
        $display("Delayed-ready read data = %h", RDATA);

        if (RDATA == 32'hA5A5A5A5)
            $display("PASS: delayed ready behavior okay");
        else
            $display("FAIL: delayed ready behavior incorrect");

        RREADY <= 1'b0;

        #40;
        $stop;
    end

endmodule