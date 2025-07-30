`timescale 1ns / 1ps

module uart_tx #(
    parameter CLK_FREQUENCY = 100000000,
    parameter BAUD_RATE = 9600,
    parameter CLOCKS_PER_BIT = CLK_FREQUENCY / BAUD_RATE
)(
    input clk,
    input reset,
    input tx_dv,
    input [7:0] i_tx_byte,
    
    output reg tx_serial,
    output o_tx_active,
    output o_tx_done
);

parameter S_IDLE = 3'b000;
parameter S_START = 3'b001;
parameter S_DATA = 3'b010;
parameter S_STOP = 3'b011;

reg [2:0] m_state = S_IDLE;
reg [15:0] m_clock_count = 0;
reg [2:0] m_tx_bit_index = 0;
reg [7:0] r_tx_data = 0;

reg m_tx_active = 0;
reg m_tx_done = 0;

assign o_tx_active = m_tx_active;
assign o_tx_done = m_tx_done;

always @(posedge clk) begin
    if (reset) begin
        m_state <= S_IDLE;
        tx_serial <= 1'b1;
        m_clock_count <= 0;
        m_tx_bit_index <= 0;
        r_tx_data <= 0;
        m_tx_active <= 0;
        m_tx_done <= 0;
    end else begin
        m_tx_done <= 0;
        case (m_state)
            S_IDLE: begin
                tx_serial <= 1'b1;
                m_clock_count <= 0;
                m_tx_bit_index <= 0;
                m_tx_active <= 0;
                if (tx_dv) begin
                    r_tx_data <= i_tx_byte;
                    m_tx_active <= 1'b1;
                    m_state <= S_START;
                end
            end
            S_START: begin
                tx_serial <= 1'b0;
                if (m_clock_count < CLOCKS_PER_BIT - 1) begin
                    m_clock_count <= m_clock_count + 1;
                end else begin
                    m_clock_count <= 0;
                    m_state <= S_DATA;
                end
            end
            S_DATA: begin
                tx_serial <= r_tx_data[m_tx_bit_index];
                if (m_clock_count < CLOCKS_PER_BIT - 1) begin
                    m_clock_count <= m_clock_count + 1;
                end else begin
                    m_clock_count <= 0;
                    if (m_tx_bit_index < 7) begin
                        m_tx_bit_index <= m_tx_bit_index + 1;
                    end else begin
                        m_tx_bit_index <= 0;
                        m_state <= S_STOP;
                    end
                end
            end
            S_STOP: begin
                tx_serial <= 1'b1;
                if (m_clock_count < CLOCKS_PER_BIT - 1) begin
                    m_clock_count <= m_clock_count + 1;
                end else begin
                    m_clock_count <= 0;
                    m_tx_active <= 0;
                    m_tx_done <= 1'b1;
                    m_state <= S_IDLE;
                end
            end
            default: begin
                m_state <= S_IDLE;
            end
        endcase
    end
end
endmodule
