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
    parameter INPUT_DATA_SIZE = 52,
    parameter STATUS_SIGNALS = 6,
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

    // input IO
    wire [OUTPUTS - 1 : 0]input_io;
    // TMP assigment TODO change
    assign sw = input_io[3:0];

    // TRX triple redundancy
    // uart transtransmision wires
    wire uart_output_signal;
    wire uart_output_signal_inst_1;
    wire uart_output_signal_inst_2;
    wire uart_output_signal_inst_3;
    // asignations
    assign jc_2 = uart_output_signal;
    // auxiliar wires
    wire nand_1_trx;
    wire nand_2_trx;
    wire nand_3_trx;
    wire xor_1_trx;
    wire xor_2_trx;
    wire xor_3_trx;
    wire xor_reduce_1_trx;
    wire xor_reduce_2_trx;
    wire xor_reduce_3_trx;
    // uart transtransmision wires triple redundant
    (* mark_debug = "true" *) assign nand_1_trx  = ~(uart_output_signal_inst_1 & uart_output_signal_inst_2);
    (* mark_debug = "true" *) assign nand_2_trx  = ~(uart_output_signal_inst_2 & uart_output_signal_inst_3);
    (* mark_debug = "true" *) assign nand_3_trx  = ~(uart_output_signal_inst_1 & uart_output_signal_inst_3);
    (* mark_debug = "true" *) assign uart_output_signal = ~(nand_1_trx & nand_2_trx & nand_3_trx);
    // uart transtransmision wires triple redundant detection
    assign xor_1_trx  = uart_output_signal_inst_1 ^ uart_output_signal_inst_2;
    assign xor_2_trx  = uart_output_signal_inst_2 ^ uart_output_signal_inst_3;
    assign xor_3_trx  = uart_output_signal_inst_1 ^ uart_output_signal_inst_3;
    assign xor_reduce_1_trx = |xor_1_trx;
    assign xor_reduce_2_trx = |xor_2_trx;
    assign xor_reduce_3_trx = |xor_3_trx;
    //end TRX
    
    // output_io triple redundancy
    wire [OUTPUTS - 1 : 0] output_io_signal;
    wire [OUTPUTS - 1 : 0] output_io_signal_inst_1;
    wire [OUTPUTS - 1 : 0] output_io_signal_inst_2;
    wire [OUTPUTS - 1 : 0] output_io_signal_inst_3;
    // asignations
    // TMP assigment TODO change
    assign led = output_io_signal[3:0];
    // auxiliar wires
    wire [OUTPUTS - 1 : 0] nand_1_out_io;
    wire [OUTPUTS - 1 : 0] nand_2_out_io;
    wire [OUTPUTS - 1 : 0] nand_3_out_io;
    wire [OUTPUTS - 1 : 0] xor_1_out_io;
    wire [OUTPUTS - 1 : 0] xor_2_out_io;
    wire [OUTPUTS - 1 : 0] xor_3_out_io;
    wire xor_reduce_1_out_io;
    wire xor_reduce_2_out_io;
    wire xor_reduce_3_out_io;

    // Output IO  wires triple redundant
    (* mark_debug = "true" *) assign nand_1_out_io  = ~(output_io_signal_inst_1 & output_io_signal_inst_2);
    (* mark_debug = "true" *) assign nand_2_out_io  = ~(output_io_signal_inst_2 & output_io_signal_inst_3);
    (* mark_debug = "true" *) assign nand_3_out_io  = ~(output_io_signal_inst_1 & output_io_signal_inst_3);
    (* mark_debug = "true" *) assign output_io_signal = ~(nand_1_out_io & nand_2_out_io & nand_3_out_io);
    // Output IO wires triple redundant detection
    assign xor_1_out_io  = output_io_signal_inst_1 ^ output_io_signal_inst_2;
    assign xor_2_out_io  = output_io_signal_inst_2 ^ output_io_signal_inst_3;
    assign xor_3_out_io  = output_io_signal_inst_1 ^ output_io_signal_inst_3;
    assign xor_reduce_1_out_io = |xor_1_out_io;
    assign xor_reduce_2_out_io = |xor_2_out_io;
    assign xor_reduce_3_out_io = |xor_3_out_io;
    // end output_io
    


    //redundat_validation_o[0] <= (xor_reduce_1 ^ xor_reduce_2) | (xor_reduce_2 ^ xor_reduce_3);
    //redundat_validation_o[1] <= xor_reduce_1 & xor_reduce_2 & xor_reduce_3 ;
    //store_data_o <= ~(nand_1 & nand_2 & nand_3)};

    control_module #(
        .WORD_SIZE(WORD_SIZE),
        .SIZE_WORD(SIZE_WORD),
        .STATUS_SIGNALS(STATUS_SIGNALS),
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_DATA_SIZE(INPUT_DATA_SIZE),
        .OUTPUTS(OUTPUTS),
        .INPUTS(INPUTS)
    )
    control_module_inst_1(
        .clk(clk),
        .rtx(jc_1),
        .rst(btn),
        .preescalar_data_rate(preescalar_data_rate),
        .input_io(input_io),
        .staus_control_module(),
        .trx(uart_output_signal_inst_1),
        .valid_io(),
        .output_io(output_io_signal_inst_1)
    );

    control_module #(
        .WORD_SIZE(WORD_SIZE),
        .SIZE_WORD(SIZE_WORD),
        .STATUS_SIGNALS(STATUS_SIGNALS),
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_DATA_SIZE(INPUT_DATA_SIZE),
        .OUTPUTS(OUTPUTS),
        .INPUTS(INPUTS)
    )
    control_module_inst_2(
        .clk(clk),
        .rtx(jc_1),
        .rst(btn),
        .preescalar_data_rate(preescalar_data_rate),
        .input_io(input_io),
        .staus_control_module(),
        .trx(uart_output_signal_inst_2),
        .valid_io(),
        .output_io(output_io_signal_inst_2)
    );

    control_module #(
        .WORD_SIZE(WORD_SIZE),
        .SIZE_WORD(SIZE_WORD),
        .STATUS_SIGNALS(STATUS_SIGNALS),
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_DATA_SIZE(INPUT_DATA_SIZE),
        .OUTPUTS(OUTPUTS),
        .INPUTS(INPUTS)
    )
    control_module_inst_3(
        .clk(clk),
        .rtx(jc_1),
        .rst(btn),
        .preescalar_data_rate(preescalar_data_rate),
        .input_io(input_io),
        .staus_control_module(),
        .trx(uart_output_signal_inst_3),
        .valid_io(),
        .output_io(output_io_signal_inst_3)
    );

endmodule
