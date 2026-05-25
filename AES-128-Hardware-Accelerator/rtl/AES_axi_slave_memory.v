`timescale 1ns / 1ps

module AES_axi_slave_memory(
    input clk,
    input reset,

    // AXI write address channel
    input  [31:0] AWADDR,
    input         AWVALID,
    output reg    AWREADY,

    // AXI write data channel
    input  [31:0] WDATA,
    input         WVALID,
    output reg    WREADY,

    // AXI write response channel
    output reg    BVALID,
    input         BREADY,

    // AXI read address channel
    input  [31:0] ARADDR,
    input         ARVALID,
    output reg    ARREADY,

    // AXI read data channel
    output reg [31:0] RDATA,
    output reg        RVALID,
    input             RREADY,

    // Internal read port
    input             mem_rd_en,
    input  [3:0]      mem_rd_addr,
    output reg [31:0] mem_rd_data,

    // Internal write port
    input             mem_wr_en,
    input  [3:0]      mem_wr_addr,
    input  [31:0]     mem_wr_data
);

    reg [31:0] mem [0:15];
    integer i;

    // -------------------------
    // Combinational internal read
    // -------------------------
    always @(*) begin
        if (mem_rd_en)
            mem_rd_data = mem[mem_rd_addr];
        else
            mem_rd_data = 32'd0;
    end

    // -------------------------
    // Sequential AXI + writes
    // -------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            AWREADY <= 1'b0;
            WREADY  <= 1'b0;
            BVALID  <= 1'b0;
            ARREADY <= 1'b0;
            RVALID  <= 1'b0;
            RDATA   <= 32'd0;

            for (i = 0; i < 16; i = i + 1)
                mem[i] <= 32'd0;
        end
        else begin
            AWREADY <= 1'b0;
            WREADY  <= 1'b0;
            ARREADY <= 1'b0;

            // internal write
            if (mem_wr_en)
                mem[mem_wr_addr] <= mem_wr_data;

            // AXI write
            if (AWVALID && WVALID && !BVALID) begin
                mem[AWADDR[5:2]] <= WDATA;
                AWREADY <= 1'b1;
                WREADY  <= 1'b1;
                BVALID  <= 1'b1;
            end

            if (BVALID && BREADY)
                BVALID <= 1'b0;

            // AXI read
            if (ARVALID && !RVALID) begin
                RDATA   <= mem[ARADDR[5:2]];
                ARREADY <= 1'b1;
                RVALID  <= 1'b1;
            end

            if (RVALID && RREADY)
                RVALID <= 1'b0;
        end
    end

endmodule