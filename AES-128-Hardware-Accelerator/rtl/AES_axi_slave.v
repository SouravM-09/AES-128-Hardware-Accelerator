`timescale 1ns / 1ps

module AES_axi_slave(
    input clk,
    input reset,

    // Write address channel
    input  [31:0] AWADDR,
    input         AWVALID,
    output reg    AWREADY,

    // Write data channel
    input  [31:0] WDATA,
    input         WVALID,
    output reg    WREADY,

    // Write response channel
    output reg    BVALID,
    input         BREADY,

    // Read address channel
    input  [31:0] ARADDR,
    input         ARVALID,
    output reg    ARREADY,

    // Read data channel
    output reg [31:0] RDATA,
    output reg        RVALID,
    input             RREADY,

    // =========================
    // OUTPUTS TO AES SYSTEM
    // =========================
    output reg        start_o,
    output reg        stop_o,
    output [127:0]    key_o,
    output reg        key_valid_o,

    // =========================
    // INPUTS FROM AES SYSTEM
    // =========================
    input             busy_i,
    input             idle_i,
    input             done_i
);

    // =========================
    // INTERNAL REGISTERS
    // =========================

    // control registers
    reg start_reg;
    reg stop_reg;

    // key registers
    reg [31:0] key0, key1, key2, key3;

    // expose full key
    assign key_o = {key0, key1, key2, key3};

    // =========================
    // AXI LOGIC
    // =========================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // AXI signals
            AWREADY <= 1'b0;
            WREADY  <= 1'b0;
            BVALID  <= 1'b0;
            ARREADY <= 1'b0;
            RVALID  <= 1'b0;
            RDATA   <= 32'd0;

            // control
            start_reg <= 1'b0;
            stop_reg  <= 1'b0;

            start_o <= 1'b0;
            stop_o  <= 1'b0;
            key_valid_o <= 1'b0;

            // key
            key0 <= 32'd0;
            key1 <= 32'd0;
            key2 <= 32'd0;
            key3 <= 32'd0;
        end
        else begin
            // default signals
            AWREADY <= 1'b0;
            WREADY  <= 1'b0;
            ARREADY <= 1'b0;

            // pulses default low
            start_o <= 1'b0;
            stop_o  <= 1'b0;
            key_valid_o <= 1'b0;

            // =========================
            // WRITE CHANNEL
            // =========================
            if (AWVALID && WVALID && !BVALID) begin
                AWREADY <= 1'b1;
                WREADY  <= 1'b1;
                BVALID  <= 1'b1;

                case (AWADDR)

                    // CONTROL REGISTER
                    // bit0 = start
                    // bit1 = stop
                    32'h00000000: begin
                        start_reg <= WDATA[0];
                        stop_reg  <= WDATA[1];

                        if (WDATA[0])
                            start_o <= 1'b1;

                        if (WDATA[1])
                            stop_o <= 1'b1;
                    end

                    // KEY REGISTERS
                    32'h00000008: key0 <= WDATA;
                    32'h0000000C: key1 <= WDATA;
                    32'h00000010: key2 <= WDATA;

                    32'h00000014: begin
                        key3 <= WDATA;
                        key_valid_o <= 1'b1;  // last word triggers valid
                    end

                    default: begin
                        // do nothing
                    end
                endcase
            end

            // clear write response
            if (BVALID && BREADY) begin
                BVALID <= 1'b0;
            end

            // =========================
            // READ CHANNEL
            // =========================
            if (ARVALID && !RVALID) begin
                ARREADY <= 1'b1;
                RVALID  <= 1'b1;

                case (ARADDR)

                    // CONTROL REGISTER (readback)
                    32'h00000000:
                        RDATA <= {30'd0, stop_reg, start_reg};

                    // STATUS REGISTER
                    // bit0 = idle
                    // bit1 = busy
                    // bit2 = done
                    // bit3 = error (0)
                    32'h00000004:
                        RDATA <= {28'd0, 1'b0, done_i, busy_i, idle_i};

                    // KEY REGISTERS
                    32'h00000008: RDATA <= key0;
                    32'h0000000C: RDATA <= key1;
                    32'h00000010: RDATA <= key2;
                    32'h00000014: RDATA <= key3;

                    default:
                        RDATA <= 32'd0;
                endcase
            end

            // clear read response
            if (RVALID && RREADY) begin
                RVALID <= 1'b0;
            end
        end
    end

endmodule