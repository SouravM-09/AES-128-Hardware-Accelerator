`timescale 1ns / 1ps

module AES_system_top(
    input clk,
    input reset,

    // ----------------------------
    // CONTROL AXI SLAVE PORTS
    // ----------------------------
    input  [31:0] ctrl_AWADDR,
    input         ctrl_AWVALID,
    output        ctrl_AWREADY,

    input  [31:0] ctrl_WDATA,
    input         ctrl_WVALID,
    output        ctrl_WREADY,

    output        ctrl_BVALID,
    input         ctrl_BREADY,

    input  [31:0] ctrl_ARADDR,
    input         ctrl_ARVALID,
    output        ctrl_ARREADY,

    output [31:0] ctrl_RDATA,
    output        ctrl_RVALID,
    input         ctrl_RREADY,

    // ----------------------------
    // MEMORY AXI SLAVE PORTS
    // ----------------------------
    input  [31:0] mem_AWADDR,
    input         mem_AWVALID,
    output        mem_AWREADY,

    input  [31:0] mem_WDATA,
    input         mem_WVALID,
    output        mem_WREADY,

    output        mem_BVALID,
    input         mem_BREADY,

    input  [31:0] mem_ARADDR,
    input         mem_ARVALID,
    output        mem_ARREADY,

    output [31:0] mem_RDATA,
    output        mem_RVALID,
    input         mem_RREADY
);

    // ----------------------------
    // Control slave signals
    // ----------------------------
    wire        start_o;
    wire        stop_o;
    wire [127:0] key_o;
    wire        key_valid_o;

    wire        busy_i;
    wire        idle_i;
    wire        done_i;

    AES_axi_slave CTRL (
        .clk(clk),
        .reset(reset),

        .AWADDR(ctrl_AWADDR),
        .AWVALID(ctrl_AWVALID),
        .AWREADY(ctrl_AWREADY),

        .WDATA(ctrl_WDATA),
        .WVALID(ctrl_WVALID),
        .WREADY(ctrl_WREADY),

        .BVALID(ctrl_BVALID),
        .BREADY(ctrl_BREADY),

        .ARADDR(ctrl_ARADDR),
        .ARVALID(ctrl_ARVALID),
        .ARREADY(ctrl_ARREADY),

        .RDATA(ctrl_RDATA),
        .RVALID(ctrl_RVALID),
        .RREADY(ctrl_RREADY),

        .start_o(start_o),
        .stop_o(stop_o),
        .key_o(key_o),
        .key_valid_o(key_valid_o),

        .busy_i(busy_i),
        .idle_i(idle_i),
        .done_i(done_i)
    );

    // ----------------------------
    // Memory slave signals
    // ----------------------------
    reg         mem_rd_en;
    reg  [3:0]  mem_rd_addr;
    wire [31:0] mem_rd_data;

    reg         mem_wr_en;
    reg  [3:0]  mem_wr_addr;
    reg  [31:0] mem_wr_data;

    AES_axi_slave_memory MEM (
        .clk(clk),
        .reset(reset),

        .AWADDR(mem_AWADDR),
        .AWVALID(mem_AWVALID),
        .AWREADY(mem_AWREADY),

        .WDATA(mem_WDATA),
        .WVALID(mem_WVALID),
        .WREADY(mem_WREADY),

        .BVALID(mem_BVALID),
        .BREADY(mem_BREADY),

        .ARADDR(mem_ARADDR),
        .ARVALID(mem_ARVALID),
        .ARREADY(mem_ARREADY),

        .RDATA(mem_RDATA),
        .RVALID(mem_RVALID),
        .RREADY(mem_RREADY),

        .mem_rd_en(mem_rd_en),
        .mem_rd_addr(mem_rd_addr),
        .mem_rd_data(mem_rd_data),

        .mem_wr_en(mem_wr_en),
        .mem_wr_addr(mem_wr_addr),
        .mem_wr_data(mem_wr_data)
    );

    // ----------------------------
    // AES engine
    // ----------------------------
    reg        aes_start;
    reg        aes_stop;
    reg        aes_data_in_valid;
    reg [31:0] aes_data_in;

    wire [31:0] aes_data_out;
    wire        aes_out_valid;
    wire        aes_done;
    wire        aes_busy;
    wire        aes_idle;

    AES_top_control DUT (
        .clk(clk),
        .reset(reset),
        .start(aes_start),
        .stop(aes_stop),
        .data_in_valid(aes_data_in_valid),
        .data_in(aes_data_in),
        .key(key_o),
        .key_valid(key_valid_o),
        .data_out(aes_data_out),
        .out_valid(aes_out_valid),
        .done(aes_done),
        .busy(aes_busy),
        .idle(aes_idle)
    );

    assign busy_i = aes_busy;
    assign idle_i = aes_idle;
    assign done_i = aes_done;

    // ----------------------------
    // Small sequencer
    // ----------------------------
    localparam IDLE  = 4'd0;
    localparam RD0   = 4'd1;
    localparam RD1   = 4'd2;
    localparam RD2   = 4'd3;
    localparam RD3   = 4'd4;
    localparam WAITO = 4'd5;
    localparam WR0   = 4'd6;
    localparam WR1   = 4'd7;
    localparam WR2   = 4'd8;
    localparam WR3   = 4'd9;

    reg [3:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;

            mem_rd_en <= 1'b0;
            mem_rd_addr <= 4'd0;
            mem_wr_en <= 1'b0;
            mem_wr_addr <= 4'd0;
            mem_wr_data <= 32'd0;

            aes_start <= 1'b0;
            aes_stop <= 1'b0;
            aes_data_in_valid <= 1'b0;
            aes_data_in <= 32'd0;
        end
        else begin
            // defaults
            mem_rd_en <= 1'b0;
            mem_wr_en <= 1'b0;
            aes_start <= 1'b0;
            aes_stop <= 1'b0;
            aes_data_in_valid <= 1'b0;

            case (state)
                IDLE: begin
                    if (start_o) begin
                        aes_start <= 1'b1;
                        mem_rd_addr <= 4'd0;
                        mem_rd_en <= 1'b1;
                        state <= RD0;
                    end
                end

                RD0: begin
                    aes_data_in <= mem_rd_data;
                    aes_data_in_valid <= 1'b1;
                    mem_rd_addr <= 4'd1;
                    mem_rd_en <= 1'b1;
                    state <= RD1;
                end

                RD1: begin
                    aes_data_in <= mem_rd_data;
                    aes_data_in_valid <= 1'b1;
                    mem_rd_addr <= 4'd2;
                    mem_rd_en <= 1'b1;
                    state <= RD2;
                end

                RD2: begin
                    aes_data_in <= mem_rd_data;
                    aes_data_in_valid <= 1'b1;
                    mem_rd_addr <= 4'd3;
                    mem_rd_en <= 1'b1;
                    state <= RD3;
                end

                RD3: begin
                    aes_data_in <= mem_rd_data;
                    aes_data_in_valid <= 1'b1;
                    state <= WAITO;
                end

                WAITO: begin
                    if (stop_o) begin
                        aes_stop <= 1'b1;
                        state <= IDLE;
                    end
                    else if (aes_out_valid) begin
                        mem_wr_addr <= 4'd4;
                        mem_wr_data <= aes_data_out;
                        mem_wr_en <= 1'b1;
                        state <= WR1;
                    end
                end

                WR1: begin
                    if (aes_out_valid) begin
                        mem_wr_addr <= 4'd5;
                        mem_wr_data <= aes_data_out;
                        mem_wr_en <= 1'b1;
                        state <= WR2;
                    end
                end

                WR2: begin
                    if (aes_out_valid) begin
                        mem_wr_addr <= 4'd6;
                        mem_wr_data <= aes_data_out;
                        mem_wr_en <= 1'b1;
                        state <= WR3;
                    end
                end

                WR3: begin
                    if (aes_out_valid) begin
                        mem_wr_addr <= 4'd7;
                        mem_wr_data <= aes_data_out;
                        mem_wr_en <= 1'b1;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule