`timescale 1ns/1ps

module tb_AES_axi_slave_memory;

    reg clk;
    reg reset;

    // Write address channel
    reg  [31:0] AWADDR;
    reg         AWVALID;
    wire        AWREADY;

    // Write data channel
    reg  [31:0] WDATA;
    reg         WVALID;
    wire        WREADY;

    // Write response channel
    wire        BVALID;
    reg         BREADY;

    // Read address channel
    reg  [31:0] ARADDR;
    reg         ARVALID;
    wire        ARREADY;

    // Read data channel
    wire [31:0] RDATA;
    wire        RVALID;
    reg         RREADY;

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
        .RREADY(RREADY)
    );

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ----------------------------
    // SIMPLE AXI WRITE TASK
    // ----------------------------
    task write_mem;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            AWADDR  <= addr;
            WDATA   <= data;
            AWVALID <= 1'b1;
            WVALID  <= 1'b1;
            BREADY  <= 1'b1;

            @(posedge clk);
            AWVALID <= 1'b0;
            WVALID  <= 1'b0;

            repeat(2) @(posedge clk);
            BREADY <= 1'b0;
        end
    endtask

    // ----------------------------
    // SIMPLE AXI READ TASK
    // ----------------------------
    task read_mem;
        input [31:0] addr;
        begin
            @(posedge clk);
            ARADDR  <= addr;
            ARVALID <= 1'b1;
            RREADY  <= 1'b1;

            @(posedge clk);
            ARVALID <= 1'b0;

            repeat(2) @(posedge clk);
            $display("Read [%h] = %h", addr, RDATA);

            RREADY <= 1'b0;
        end
    endtask

    initial begin
        reset   = 1'b1;
        AWADDR  = 32'd0;
        AWVALID = 1'b0;
        WDATA   = 32'd0;
        WVALID  = 1'b0;
        BREADY  = 1'b0;
        ARADDR  = 32'd0;
        ARVALID = 1'b0;
        RREADY  = 1'b0;

        #20;
        reset = 1'b0;

        // Write some memory locations
        write_mem(32'h00000000, 32'h11111111);
        write_mem(32'h00000004, 32'h22222222);
        write_mem(32'h00000008, 32'h33333333);
        write_mem(32'h0000000C, 32'h44444444);

        // Read them back
        read_mem(32'h00000000);
        read_mem(32'h00000004);
        read_mem(32'h00000008);
        read_mem(32'h0000000C);

        #20;
        $stop;
    end

endmodule