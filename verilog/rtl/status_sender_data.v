`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2021 08:13:36 AM
// Design Name: 
// Module Name: status_sender_data
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


module status_sender_data #
(
    parameter WORD_SIZE = 32,
    parameter INPUT_DATA_SIZE = 52,
    parameter SIZE_WORD = 3,
    parameter STATUS_SIGNALS = 6,
    parameter STATUS_SIGNALS_UART = 4,
    parameter DATA_WIDTH = 8,
    parameter SYMBOL_WITH = 4,
    parameter [8:0]ESCAPE_CHARCTER = 8'h0D,
    parameter [8:0]CLEAN_CHARCTER = 8'h20
    
)
(
    input clk,
    input rxd, 
    input rst,
    input [SIZE_WORD-1:0] size_of_data,
    input [WORD_SIZE-1:0] data_to_send,
    input [15:0] preescalar_value,
    input valid_data,
    output reg [INPUT_DATA_SIZE-1:0] control_value,
    output reg valid_control_value,
    output busy,
    output [STATUS_SIGNALS_UART-1:0]control_uart,
    output txd
    );

    // prescalar reister fix for now
    //reg [15:0] preescalar_data_rate = CLOCK_SPEED/(BAUD_RATE*DATA_WIDTH);

    // create register for the input and output of the data
    (* mark_debug = "true" *) reg [DATA_WIDTH-1:0] uart_tx_axis_tdata;
    (* mark_debug = "true" *) reg uart_tx_axis_tvalid;
    (* mark_debug = "true" *) wire uart_tx_axis_tready;

    //(* mark_debug = "true" *) 
    (* mark_debug = "true" *) wire [DATA_WIDTH-1:0] uart_rx_axis_tdata;
    (* mark_debug = "true" *) wire uart_rx_axis_tvalid;
    (* mark_debug = "true" *) reg uart_rx_axis_tready;

    // create the register for control to remember last value send
    (* mark_debug = "true" *) reg [INPUT_DATA_SIZE-1:0] output_value;
    // create the register for store the data to be send
    reg [WORD_SIZE-1:0] send_data_register;
    // register to now if is sending data
    (* mark_debug = "true" *) reg sending_data;
    // regsiter to store the actual size
    reg [SIZE_WORD-1:0] data_size_actual;


    // assings
    assign busy = sending_data;


    // uart module
    uart #(
        .DATA_WIDTH(DATA_WIDTH)
    )
    uart_inst(
        .clk(clk),
        .rst(rst),
        .prescale (preescalar_value),
        .s_axis_tdata(uart_tx_axis_tdata),
        .s_axis_tvalid(uart_tx_axis_tvalid),
        .s_axis_tready(uart_tx_axis_tready),
        // AXI output
        .m_axis_tdata(uart_rx_axis_tdata),
        .m_axis_tvalid(uart_rx_axis_tvalid),
        .m_axis_tready(uart_rx_axis_tready),
        .rxd(rxd),
        .txd(txd),
        .tx_busy(control_uart[0]),
        .rx_busy(control_uart[1]),
        .rx_overrun_error(control_uart[2]),
        .rx_frame_error(control_uart[3])
    );


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            uart_tx_axis_tdata <= 0;
            uart_rx_axis_tready <= 0;
            uart_tx_axis_tvalid <= 0;
            data_size_actual <= 0;
            output_value <= 0;   
            send_data_register <= 0;
            sending_data <= 0;
            control_value <= 1'b0;
            valid_control_value <= 1'b0;
        end
        else begin
            // main code part
            if (uart_tx_axis_tvalid) begin
                // attempting to transmit a byte
                // so can't receive one at the moment
                uart_rx_axis_tready <= 0;
                // if it has been received, then clear the valid flag
                if (uart_tx_axis_tready) begin
                    uart_tx_axis_tvalid <= 0;
                end
            end
            // process if we are sending data
            else if (sending_data) begin
                // now the control value is not valid
                valid_control_value <= 1'b0;
                if (data_size_actual == 3'b000)begin
                    // end sending words
                    send_data_register <= 0;
                    sending_data <= 0;
                    uart_tx_axis_tvalid <= 0;
                end
                else begin
                    // reduce by one the size
                    data_size_actual <= data_size_actual - 1'b1;
                    // transmit enable
                    uart_tx_axis_tvalid <= 1'b1;
                    // data to be send
                    uart_tx_axis_tdata <= send_data_register[DATA_WIDTH-1: 0];
                    // shift the value
                    send_data_register <= send_data_register >> DATA_WIDTH;
                end
            end
            // if a signal to send a word has been recibed
            if (valid_data) begin
                // now the control value is not valid
                valid_control_value <= 1'b0;
                // set all of the variables
                sending_data <= 1'b1;
                // set the value of the data to be send
                uart_tx_axis_tvalid <= 0;
                send_data_register <= data_to_send;
                data_size_actual <= size_of_data;
            end
            else begin
                // ready to receive byte
                uart_rx_axis_tready <= 1;
                valid_control_value <= 1'b0;
                if (uart_rx_axis_tvalid) begin
                    // got one, so make sure it gets the correct ready signal
                    // (either clear it if it was set or set it if we just got a
                    // byte out of waiting for the transmitter to send one)
                    uart_rx_axis_tready <= ~uart_rx_axis_tready;
                    // move the shift register 
                    output_value <= output_value << SYMBOL_WITH;
                    output_value [SYMBOL_WITH-1: 0] <= uart_rx_axis_tdata[SYMBOL_WITH-1:0];
                    // if if wnd code recibed 
                    if ( uart_rx_axis_tdata == ESCAPE_CHARCTER)
                    begin
                        control_value <= output_value;
                        valid_control_value <= 1'b1;
                        output_value <= 0;
                    end
                    else if ( uart_rx_axis_tdata == CLEAN_CHARCTER) begin
                        output_value <= 0;
                    end
                    else begin
                        valid_control_value <= 1'b0;
                    end
                    
                end
            end

        end
    end
endmodule
