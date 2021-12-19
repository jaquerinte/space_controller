`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2021 12:00:45 PM
// Design Name: 
// Module Name: control_module
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


module control_module#
(
    parameter WORD_SIZE = 32,
    parameter SIZE_WORD = 3,
    parameter AUXILIAR_SIZE = 44,
    parameter IO_OUTPUT_SIZE = 8,
    parameter INPUT_DATA_SIZE = 52,
    parameter STATUS_SIGNALS = 6,
    parameter DATA_WIDTH = 8,
    parameter OUTPUTS = 32,
    parameter INPUTS = 32,
    parameter INSTRUCTION_SIZE = 3,
    parameter SIZE_WORD_REGISTER = 3

)
(
    input clk,
    input rtx,
    input rst,
    input [15:0] preescalar_data_rate,
    input [INPUTS-1:0] input_io,
    output [STATUS_SIGNALS-1:0]staus_control_module, // TODO possible expansion of that
    output trx,
    output valid_io, 
    output [OUTPUTS-1:0] output_io 

);

    
   
    // connection wires
    wire busy_io_module;
    wire busy_sender_data;
    wire [INSTRUCTION_SIZE-1:0] instrucction;
    wire [SIZE_WORD_REGISTER-1:0] register;
    wire [AUXILIAR_SIZE-1:0] auxiliar_register;
    wire valid_instrucction;
    wire valid_control_value;
    // control value
    wire [INPUT_DATA_SIZE-1:0] control_value;
    wire [WORD_SIZE-1:0] send_data_register;
    wire valid_data;
    wire [SIZE_WORD-1:0] size_line;
    wire [IO_OUTPUT_SIZE-1:0] result_input_io;
 
    // assigments 
    assign staus_control_module[4] = busy_io_module;
    assign staus_control_module[5] = busy_sender_data;

    // status sender module
    status_sender_data #(
        .WORD_SIZE(WORD_SIZE),
        .SIZE_WORD(SIZE_WORD),
        .STATUS_SIGNALS(STATUS_SIGNALS),
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_DATA_SIZE(INPUT_DATA_SIZE)
    )
    status_sender_data_inst(
        .clk(clk),
        .rst(rst),
        .rxd(rtx),
        .size_of_data(size_line),
        .data_to_send(send_data_register),
        .preescalar_value (preescalar_data_rate),
        .valid_data(valid_data),
        .valid_control_value(valid_control_value),
        .control_value(control_value),
        .busy(busy_sender_data),
        .control_uart(staus_control_module[3:0]),
        .txd(trx)
    );

    io_module #(
        .SIZE_WORD(SIZE_WORD),
        .WORD_SIZE(WORD_SIZE),
        .INSTRUCTION_SIZE(INSTRUCTION_SIZE),
        .OUTPUTS(OUTPUTS),
        .INPUTS(INPUTS),
        .IO_OUTPUT_SIZE(IO_OUTPUT_SIZE)
    )
    io_module_inst (
        .clk(clk),
        .rst(rst),
        .busy(busy_io_module),
        .instrucction(instrucction),
        .register(register),
        .auxiliar_register(auxiliar_register),
        .valid_instrucction(valid_instrucction),
        .input_io(input_io),
        .valid_io(valid_io),
        .output_io(output_io),
        .result_input_io(result_input_io)
    );

    logic_control #(
        .WORD_SIZE(WORD_SIZE),
        .SIZE_WORD(SIZE_WORD),
        .INPUT_DATA_SIZE(INPUT_DATA_SIZE),
        .STATUS_SIGNALS(STATUS_SIGNALS),
        .DATA_WIDTH(DATA_WIDTH)
    )
    logic_control_inst (
        .clk(clk),
        .rst(rst),
        .valid_data(valid_data),
        .result_input_io(result_input_io),
        .valid_control_value(valid_control_value),
        .control_value(control_value),
        .busy_sender_data(busy_sender_data),
        .busy_io_module(busy_io_module),
        .size_line(size_line),
        .send_data_register(send_data_register),
        .instrucction(instrucction),
        .register(register),
        .auxiliar_register(auxiliar_register),
        .valid_instrucction(valid_instrucction)
    );
 
endmodule
`default_nettype wire