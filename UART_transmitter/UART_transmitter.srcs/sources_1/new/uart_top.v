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
    input clk,         // 100 MHz clock 
    input reset,       // Reset (connect to a button)
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

endmodule
