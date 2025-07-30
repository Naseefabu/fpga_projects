`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Naseef
// 
// Create Date: 30.07.2025 11:13:28
// Design Name: 
// Module Name: uart_tx
// Project Name: UART transmitter
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


module uart_tx #(
    parameter CLK_FREQUENCY = 100000000, // 100MHZ
    parameter BAUD_RATE = 9600,
    parameter CLOCKS_PER_BIT = CLK_FREQUENCY / BAUD_RATE
)(
    input clk,
    input reset,
    input tx_dv,
    input [7:0] i_tx_byte,
    
    output reg tx_serial
    );

parameter S_IDLE = 3'b000; // waiting something to happen
parameter S_START = 3'b001; // already happened (high to low signal)
parameter S_DATA = 3'b010; // transfer 8 bit data
parameter S_STOP = 3'b011; // signal to stop

reg [2:0] m_state = S_IDLE;
reg [15:0] m_clock_count = 0;

reg [2:0] m_tx_bit_index = 0;
reg [7:0] r_tx_data = 0; // shift register for the byte  



always @(posedge clk)
begin
    if (reset)
    begin
        m_state <= S_IDLE;
    end else
    begin
        case (m_state)
            S_IDLE:
                begin
                    tx_serial <= 1'b1;
                    m_clock_count <= 0;
                    
                    if (tx_dv)
                    begin
                       r_tx_data <= i_tx_byte;
                       m_state <= S_START;                                                                                                 
                    end
                end
            S_START:
                begin
                    tx_serial <= 1'b0; // start bit 0 (low signal -> signals reader to read)
                    if (m_clock_count < CLOCKS_PER_BIT -1)
                    begin
                        m_clock_count <= m_clock_count + 1;
                        m_state <= S_START;
                    end else
                    begin 
                        m_clock_count <= 0;
                        m_state <= S_DATA;
                    end
                end
            S_DATA:
                begin
                tx_serial = r_tx_data[m_tx_bit_index]; // enable this signal output until next CLOCKS_PER_BIT done!
                if (m_clock_count < CLOCKS_PER_BIT -1)
                    begin
                        m_clock_count <= m_clock_count + 1;
                        m_state <= S_DATA;
                    end else
                    begin
                        m_clock_count <= 0;
                        m_tx_bit_index <= m_tx_bit_index + 1;
                    end
                end
            S_STOP:
                begin
                
                end        
            default:
                begin
                
                end
        endcase
    end 
end
endmodule
