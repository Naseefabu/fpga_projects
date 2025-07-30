`timescale 1ns / 1ps

module top (
    input clk,
    output uart_tx
);

    wire reset = 1'b0;  // Tie low if not using button (comment out if connecting to H5)

    reg tx_start = 0;
    wire tx_done;
    wire tx_active;
    wire tx_serial;
    reg [23:0] rate_limit = 0;  // Slow down to ~10 'A's per sec (adjust if needed)

    uart_tx uart_inst (
        .clk(clk),
        .reset(reset),
        .tx_dv(tx_start),
        .i_tx_byte(8'h41),  // 'A'
        .tx_serial(tx_serial),
        .o_tx_active(tx_active),
        .o_tx_done(tx_done)
    );

    assign uart_tx = tx_serial;

    always @(posedge clk) begin
        tx_start <= 0;
        if (rate_limit > 0) begin
            rate_limit <= rate_limit - 1;
        end else if (!tx_active && tx_done) begin
            tx_start <= 1'b1;
            rate_limit <= 10_000_000;  // ~0.1 sec delay at 100 MHz
        end
    end
endmodule