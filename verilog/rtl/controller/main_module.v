`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2021 10:43:06 AM
// Design Name: 
// Module Name: top_module
// Project Name: 
// Target Devices: (* mark_debug = "true" *) 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_module #
(
    parameter WORD_SIZE = 32,
    parameter SIZE_WORD = 3,
    parameter INPUT_DATA_SIZE = 52,
    parameter integer WHISBONE_ADR = 32,
    parameter STATUS_SIGNALS = 6,
    parameter DATA_WIDTH = 8,
    parameter BAUD_RATE = 115200,
    parameter CLOCK_SPEED = 10000000,
    parameter OUTPUTS = 32,
    parameter INPUTS = 32
)
(
    input clk,
    input rtx,
    input rst,
    input [INPUTS-1:0] input_io_ports,
    input  wire [3 : 0] wstrb_i,
    input  wire [WORD_SIZE -1 : 0] wdata_i,
    input  wire [WHISBONE_ADR - 1 : 0] wbs_adr_i,
    input  wire valid_i,
    input  wire wbs_we_i,
    output wire ready_o,
    output wire [WORD_SIZE - 1 : 0] rdata_o,
    output [OUTPUTS-1:0] output_io_ports,
    output trx
    );
    // prescalar reister fix for now
    reg [15:0] preescalar_data_rate = CLOCK_SPEED/(BAUD_RATE*DATA_WIDTH);

    // input IO
    wire [OUTPUTS - 1 : 0]input_io;
    // TMP assigment TODO change
    assign input_io_ports = input_io;

    // TRX triple redundancy
    // uart transtransmision wires
    wire uart_output_signal;
    wire uart_output_signal_inst_1;
    wire uart_output_signal_inst_2;
    wire uart_output_signal_inst_3;
    // asignations
    assign trx = uart_output_signal;
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
    assign nand_1_trx  = ~(uart_output_signal_inst_1 & uart_output_signal_inst_2);
    assign nand_2_trx  = ~(uart_output_signal_inst_2 & uart_output_signal_inst_3);
    assign nand_3_trx  = ~(uart_output_signal_inst_1 & uart_output_signal_inst_3);
    assign uart_output_signal = ~(nand_1_trx & nand_2_trx & nand_3_trx);
    // uart transtransmision wires triple redundant detection
    assign xor_1_trx  = uart_output_signal_inst_1 ^ uart_output_signal_inst_2;
    assign xor_2_trx  = uart_output_signal_inst_2 ^ uart_output_signal_inst_3;
    assign xor_3_trx  = uart_output_signal_inst_1 ^ uart_output_signal_inst_3;
    assign xor_reduce_1_trx =  (xor_1_trx & xor_3_trx);
    assign xor_reduce_2_trx =  (xor_1_trx & xor_2_trx);
    assign xor_reduce_3_trx =  (xor_2_trx & xor_3_trx);
    //end TRX

   

    // output_io triple redundancy
    wire [OUTPUTS - 1 : 0] output_io_signal;
    wire [OUTPUTS - 1 : 0] output_io_signal_inst_1;
    wire [OUTPUTS - 1 : 0] output_io_signal_inst_2;
    wire [OUTPUTS - 1 : 0] output_io_signal_inst_3;
    // asignations
    // TMP assigment TODO change
    assign output_io_ports = output_io_signal;
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
    assign nand_1_out_io  = ~(output_io_signal_inst_1 & output_io_signal_inst_2);
    assign nand_2_out_io  = ~(output_io_signal_inst_2 & output_io_signal_inst_3);
    assign nand_3_out_io  = ~(output_io_signal_inst_1 & output_io_signal_inst_3);
    assign output_io_signal = ~(nand_1_out_io & nand_2_out_io & nand_3_out_io);
    // Output IO wires triple redundant detection
    assign xor_1_out_io  = output_io_signal_inst_1 ^ output_io_signal_inst_2;
    assign xor_2_out_io  = output_io_signal_inst_2 ^ output_io_signal_inst_3;
    assign xor_3_out_io  = output_io_signal_inst_1 ^ output_io_signal_inst_3;
    assign xor_reduce_1_out_io = ((|xor_1_out_io) & (|xor_3_out_io));
    assign xor_reduce_2_out_io = ((|xor_1_out_io) & (|xor_2_out_io));
    assign xor_reduce_3_out_io = ((|xor_2_out_io) & (|xor_3_out_io));
    // end output_io
    wire ready_pmu; // wire to connect to the PMU
    wire ready_pmu_backup; // wire to connect to the PMU
    wire [WORD_SIZE - 1 : 0] rdata_pmu; // wire that carries the data form de pmu 
    wire [WORD_SIZE - 1 : 0] rdata_pmu_backup; // wire that carries the data form de pmu backup

    assign ready_o = ready_pmu | ready_pmu_backup | ready_pmu_backup;
    assign rdata_o = ready_pmu ? rdata_pmu : rdata_pmu_backup;
    
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
        .rtx(rtx),
        .rst(rst),
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
        .rtx(rtx),
        .rst(rst),
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
        .rtx(rtx),
        .rst(rst),
        .preescalar_data_rate(preescalar_data_rate),
        .input_io(input_io),
        .staus_control_module(),
        .trx(uart_output_signal_inst_3),
        .valid_io(),
        .output_io(output_io_signal_inst_3)
    );

    PMU#(
        .WORD_SIZE(WORD_SIZE),
        .OUTPUTS(OUTPUTS),
        .INPUTS(INPUTS),
        .ADDRBASE (20'h3000_0)
    )
    PMU_inst_1(
        .clk(clk),
        .rst(rst),
        .wstrb_i(wstrb_i),
        .wdata_i(wdata_i),
        .output_io_error({xor_reduce_3_out_io,xor_reduce_2_out_io,xor_reduce_1_out_io}),
        .trx_error({xor_reduce_3_trx,xor_reduce_2_trx, xor_reduce_1_trx}),
        .wbs_adr_i(wbs_adr_i),
        .valid_i(valid_i),
        .wbs_we_i(wbs_we_i),
        .ready_o(ready_pmu),
        .rdata_o(rdata_pmu)
    );

    PMU#(
        .WORD_SIZE(WORD_SIZE),
        .OUTPUTS(OUTPUTS),
        .INPUTS(INPUTS),
        .ADDRBASE (20'h3001_0)
    )
    PMU_inst_2(
        .clk(clk),
        .rst(rst),
        .wstrb_i(wstrb_i),
        .output_io_error({xor_reduce_3_out_io,xor_reduce_2_out_io,xor_reduce_1_out_io}),
        .trx_error({xor_reduce_3_trx,xor_reduce_2_trx, xor_reduce_1_trx}),
        .wdata_i(wdata_i),
        .wbs_adr_i(wbs_adr_i),
        .valid_i(valid_i),
        .wbs_we_i(wbs_we_i),
        .ready_o(ready_pmu_backup),
        .rdata_o(rdata_pmu_backup)
    );

endmodule
`default_nettype wire
