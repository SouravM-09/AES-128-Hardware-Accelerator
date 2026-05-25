`timescale 1ns/1ps

module tb_AES_axi_slave;

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

AES_axi_slave uut(
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

// clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// ----------------------------
// SIMPLE WRITE TASK
// ----------------------------
task write;
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

    repeat(3) @(posedge clk);

    BREADY <= 1'b0;
end
endtask

// ----------------------------
// SIMPLE READ TASK
// ----------------------------
task read;
input [31:0] addr;
begin
    @(posedge clk);
    ARADDR  <= addr;
    ARVALID <= 1'b1;
    RREADY  <= 1'b1;

    @(posedge clk);
    ARVALID <= 1'b0;

    repeat(3) @(posedge clk);

    $display("Read [%h] = %h", addr, RDATA);

    RREADY <= 1'b0;
end
endtask

// ----------------------------
// TEST
// ----------------------------
initial begin
    reset = 1'b1;
    AWADDR = 32'd0;
    AWVALID = 1'b0;
    WDATA = 32'd0;
    WVALID = 1'b0;
    BREADY = 1'b0;
    ARADDR = 32'd0;
    ARVALID = 1'b0;
    RREADY = 1'b0;

    #20;
    reset = 1'b0;

    // Write key
    write(32'h00000008, 32'h00010203);
    write(32'h0000000C, 32'h04050607);
    write(32'h00000010, 32'h08090A0B);
    write(32'h00000014, 32'h0C0D0E0F);

    // Start
    write(32'h00000000, 32'h00000001);

    // Write plaintext input words
    write(32'h00000018, 32'h00112233);
    write(32'h0000001C, 32'h44556677);
    write(32'h00000020, 32'h8899AABB);
    write(32'h00000024, 32'hCCDDEEFF);

    // Wait long enough for AES processing
    repeat(80) @(posedge clk);

    // Read status
    read(32'h00000004);

    // Read output words
    read(32'h00000028);
    read(32'h0000002C);
    read(32'h00000030);
    read(32'h00000034);

    #20;
    $stop;
end

endmodule