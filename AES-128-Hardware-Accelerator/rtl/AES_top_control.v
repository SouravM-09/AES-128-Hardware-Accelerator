`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2026 02:22:54 PM
// Design Name: 
// Module Name: AES_top_control
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


module AES_top_control(
    input clk,
    input reset,
    input start,
    input stop,
    input data_in_valid,
    input [31:0] data_in,
    input [127:0] key,
    input key_valid,

    output [31:0] data_out,
    output out_valid,
    output done,
    output busy,
    output idle
);

    // =========================
    // FSM states
    // =========================
    localparam IDLE = 2'd0;
    localparam BUSY = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state;

    // =========================
    // Key register
    // update only when idle
    // =========================
    reg [127:0] key_reg;

    // =========================
    // Wrapper interface
    // =========================
    wire [31:0] wrapper_data_out;
    wire wrapper_out_valid;
    wire wrapper_in_valid;

    assign wrapper_in_valid = (state == BUSY) ? data_in_valid : 1'b0;

    AES_wrapper_32bit WRAP (
        .clk(clk),
        .reset(reset),
        .in_valid(wrapper_in_valid),
        .data_in(data_in),
        .key(key_reg),
        .data_out(wrapper_data_out),
        .out_valid(wrapper_out_valid)
    );

    assign data_out  = wrapper_data_out;
    assign out_valid = wrapper_out_valid;

    // =========================
    // Status signals
    // =========================
    assign busy = (state == BUSY);
    assign idle = (state == IDLE);

    // done is a 1-cycle pulse
    reg done_reg;
    assign done = done_reg;

    // =========================
    // Count output words
    // one AES block = 4 x 32-bit output words
    // =========================
    reg [1:0] out_word_count;

    // =========================
    // Control FSM
    // =========================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state          <= IDLE;
            key_reg        <= 128'd0;
            done_reg       <= 1'b0;
            out_word_count <= 2'd0;
        end
        else begin
            // default: done is only a one-cycle pulse
            done_reg <= 1'b0;

            // safe key update only in IDLE
            if ((state == IDLE) && key_valid) begin
                key_reg <= key;
            end

            case (state)

                IDLE: begin
                    out_word_count <= 2'd0;

                    // start processing one block transaction
                    if (start) begin
                        state <= BUSY;
                    end
                end

                BUSY: begin
                    // optional stop support
                    if (stop) begin
                        state <= IDLE;
                        out_word_count <= 2'd0;
                    end
                    else begin
                        // count 32-bit output words from wrapper
                        if (wrapper_out_valid) begin
                            if (out_word_count == 2'd3) begin
                                out_word_count <= 2'd0;
                                done_reg <= 1'b1;
                                state <= DONE;
                            end
                            else begin
                                out_word_count <= out_word_count + 2'd1;
                            end
                        end
                    end
                end

                DONE: begin
                    // done pulse already asserted in previous cycle
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                    out_word_count <= 2'd0;
                end

            endcase
        end
    end

endmodule