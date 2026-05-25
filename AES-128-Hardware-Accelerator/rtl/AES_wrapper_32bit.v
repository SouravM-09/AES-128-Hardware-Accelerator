`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2026 08:58:41 PM
// Design Name: 
// Module Name: AES_wrapper_32bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AES_wrapper_32bit(
    input clk,
    input reset,
    input in_valid,
    input [31:0] data_in,
    input [127:0] key,
    output [31:0] data_out,
    output out_valid
);

    // =========================
    // Input side
    // =========================
    reg [127:0] plain_reg;
    reg [1:0] in_count;
    reg block_in_valid;

    // =========================
    // AES connection
    // =========================
    wire [127:0] cipher_block;
    wire aes_out_valid;

    AES_core_pipeline ACP(
        .clk(clk),
        .reset(reset),
        .in_valid(block_in_valid),
        .plaintext(plain_reg),
        .key(key),
        .ciphertext(cipher_block),
        .out_valid(aes_out_valid)
    );

    // =========================
    // Output FIFO (4 entries)
    // =========================
    reg [127:0] fifo_mem [0:3];
    reg [1:0] fifo_wr_ptr;
    reg [1:0] fifo_rd_ptr;
    reg [2:0] fifo_count;   // 0 to 4

    // =========================
    // Output side
    // =========================
    reg [127:0] cipher_reg;
    reg [1:0] out_count;
    reg sending_out;

    reg [31:0] data_out_reg;
    reg out_valid_reg;

    assign data_out  = data_out_reg;
    assign out_valid = out_valid_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            plain_reg       <= 128'd0;
            in_count        <= 2'd0;
            block_in_valid  <= 1'b0;

            fifo_mem[0]     <= 128'd0;
            fifo_mem[1]     <= 128'd0;
            fifo_mem[2]     <= 128'd0;
            fifo_mem[3]     <= 128'd0;
            fifo_wr_ptr     <= 2'd0;
            fifo_rd_ptr     <= 2'd0;
            fifo_count      <= 3'd0;

            cipher_reg      <= 128'd0;
            out_count       <= 2'd0;
            sending_out     <= 1'b0;

            data_out_reg    <= 32'd0;
            out_valid_reg   <= 1'b0;
        end
        else begin
            // default one-cycle style signals
            block_in_valid <= 1'b0;
            out_valid_reg  <= 1'b0;

            // =====================================
            // Input assembly: 4 x 32-bit -> 128-bit
            // =====================================
            if (in_valid) begin
                case (in_count)
                    2'd0: begin
                        plain_reg[127:96] <= data_in;
                        in_count <= 2'd1;
                    end
                    2'd1: begin
                        plain_reg[95:64] <= data_in;
                        in_count <= 2'd2;
                    end
                    2'd2: begin
                        plain_reg[63:32] <= data_in;
                        in_count <= 2'd3;
                    end
                    2'd3: begin
                        plain_reg[31:0] <= data_in;
                        block_in_valid <= 1'b1;
                        in_count <= 2'd0;
                    end
                endcase
            end

            // =====================================
            // Capture AES output into FIFO
            // =====================================
            if (aes_out_valid) begin
                if (fifo_count < 4) begin
                    fifo_mem[fifo_wr_ptr] <= cipher_block;
                    fifo_wr_ptr <= fifo_wr_ptr + 2'd1;
                    fifo_count <= fifo_count + 3'd1;
                end
                // else: FIFO full, block is dropped
                // For full PS-quality AXI design, this should become proper backpressure/flow control.
            end

            // =====================================
            // If not currently sending, load next block from FIFO
            // =====================================
            if (!sending_out && (fifo_count > 0)) begin
                cipher_reg  <= fifo_mem[fifo_rd_ptr];
                fifo_rd_ptr <= fifo_rd_ptr + 2'd1;
                fifo_count  <= fifo_count - 3'd1;

                sending_out <= 1'b1;
                out_count   <= 2'd0;
            end

            // =====================================
            // Output splitting: 128-bit -> 4 x 32-bit
            // =====================================
            if (sending_out) begin
                out_valid_reg <= 1'b1;

                case (out_count)
                    2'd0: begin
                        data_out_reg <= cipher_reg[127:96];
                        out_count <= 2'd1;
                    end
                    2'd1: begin
                        data_out_reg <= cipher_reg[95:64];
                        out_count <= 2'd2;
                    end
                    2'd2: begin
                        data_out_reg <= cipher_reg[63:32];
                        out_count <= 2'd3;
                    end
                    2'd3: begin
                        data_out_reg <= cipher_reg[31:0];
                        out_count <= 2'd0;
                        sending_out <= 1'b0;
                    end
                endcase
            end
        end
    end

endmodule


