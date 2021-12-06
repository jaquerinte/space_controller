`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2021 10:43:06 AM
// Design Name: 
// Module Name: top_module
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


module top_module #
(
    parameter WORD_SIZE = 32,
    parameter SIZE_WORD = 3,
    parameter INPUT_DATA_SIZE = 40,
    parameter STATUS_SIGNALS = 4,
    parameter DATA_WIDTH = 8,
    parameter BAUD_RATE = 115200,
    parameter CLOCK_SPEED = 125000000,
    parameter OUTPUTS = 32,
    parameter INPUTS = 32
)
(
    input clk,
    input jc_1,
    input btn,
    input [3:0]sw,
    output [3:0]led,
    output jc_2
    );
    // prescalar reister fix for now
    reg [15:0] preescalar_data_rate = CLOCK_SPEED/(BAUD_RATE*DATA_WIDTH);
    // id of the control module
    reg [2:0] id = 2'b00;

    control_module #(
        .WORD_SIZE(WORD_SIZE),
        .SIZE_WORD(SIZE_WORD),
        .STATUS_SIGNALS(STATUS_SIGNALS),
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_DATA_SIZE(INPUT_DATA_SIZE),
        .OUTPUTS(OUTPUTS),
        .INPUTS(INPUTS)
    )
    control_module_inst(
        .clk(clk),
        .rtx(jc_1),
        .rst(btn),
        .preescalar_data_rate(preescalar_data_rate),
        .id(id),
        .input_io({28'b00000000000000000000000000,sw}),
        .staus_control_module(),
        .trx(jc_2),
        .valid_io(),
        .output_io({28'b00000000000000000000000000,led})
    );

endmodule
