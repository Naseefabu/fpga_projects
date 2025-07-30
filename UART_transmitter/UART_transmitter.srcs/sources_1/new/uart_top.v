`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.07.2025 15:28:04
// Design Name: 
// Module Name: uart_top
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

module top (
    input clk,         // 100 MHz clock (pin E3 on Arty A7)
    input reset,       // Reset (e.g., connect to a button)
    output uart_tx     // UART TX pin (pin A9 on Arty A7)
);

    localparam MSG_LEN = 13;  // "hello world\r\n" = 13 chars
    
    reg [7:0] message [0:MSG_LEN-1];
    initial begin
        message[0]  = 8'h68;  // h
        message[1]  = 8'h65;  // e
        message[2]  = 8'h6C;  // l
        message[3]  = 8'h6C;  // l
        message[4]  = 8'h6F;  // o
        message[5]  = 8'h20;  // space
        message[6]  = 8'h77;  // w
        message[7]  = 8'h6F;  // o
        message[8]  = 8'h72;  // r
        message[9]  = 8'h6C;  // l
        message[10] = 8'h64;  // d
        message[11] = 8'h0D;  // \r
        message[12] = 8'h0A;  // \n
    end
    
    reg [3:0] char_index = 0;   // 0 to 12
    reg [31:0] delay_counter = 0;  // For delays
    reg tx_start = 0;           // Pulse for tx_dv
    
    wire tx_done;
    wire tx_active;
    wire tx_serial;
    
    uart_tx uart_inst (
        .clk(clk),
        .reset(reset),
        .tx_dv(tx_start),
        .i_tx_byte(message[char_index]),
        .tx_serial(tx_serial),
        .o_tx_active(tx_active),
        .o_tx_done(tx_done)
    );
    
    assign uart_tx = tx_serial;
    
    always @(posedge clk) begin
        if (reset) begin
            char_index <= 0;
            delay_counter <= 0;
            tx_start <= 0;
        end else begin
            tx_start <= 0;  // Default low
            if (delay_counter > 0) begin
                delay_counter <= delay_counter - 1;
            end else if (!tx_active && !tx_start) begin  // Ready for next char
                tx_start <= 1'b1;  // Pulse to start
                if (char_index < MSG_LEN - 1) begin
                    char_index <= char_index + 1;
                    delay_counter <= 100_000;  // Small delay between chars (~1 ms at 100 MHz; set to 0 if unwanted)
                end else begin
                    char_index <= 0;
                    delay_counter <= 100_000_000;  // 1 sec delay before repeat
                end
            end
        end
    end

endmodule