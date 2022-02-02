// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
        parameter WORD_SIZE = 32,
        parameter SIZE_WORD = 3,
        parameter INPUT_DATA_SIZE = 52,
        parameter STATUS_SIGNALS = 6,
        parameter DATA_WIDTH = 8,
        parameter BAUD_RATE = 115200,
        parameter CLOCK_SPEED = 10000000,
        parameter OUTPUTS = 32,
        parameter INPUTS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,
    // seconday clk
    input user_clock2,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,
    /* 
    *---------------------------------------------------------------------
    * If the chip is configured for output with the oeb control
    * register = 1, then the oeb line is controlled by the additional
    * signal from the management SoC.  If the oeb control register = 0,
    * then the output is disabled completely.  The "io" line is input
    * only in this module.
    *
    *---------------------------------------------------------------------
    */

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;
    wire [15:0] io_port_out;
    wire [15:0] io_port_in;
    wire [15:0] la_out_value;
    wire rtx;
    wire trx;
    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [31:0] rdata; 
    wire [31:0] wdata;

    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;

    // IO
    // IO MODE IO port connected to the 16 last 
    assign io_out = {12'b0,io_port_out,1'b0,trx,8'b0};
    assign io_in = {12'b0,io_port_in,rtx,1'b0,8'b0};
    assign io_oeb = {(`MPRJ_IO_PADS-1){1'b0}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(127-15){1'b0}}, la_out_value};
    // Assuming LA probes [63:32] are for controlling the count register  
    //assign la_write = ~la_oenb[63:32] & ~{WORD_SIZE{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    //assign clk = wb_clk_i;
    //assign rst = wb_rst_i;
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

   main_module #(
        .WORD_SIZE (WORD_SIZE),
        .SIZE_WORD (SIZE_WORD),
        .INPUT_DATA_SIZE (INPUT_DATA_SIZE),
        .STATUS_SIGNALS (STATUS_SIGNALS),
        .DATA_WIDTH (DATA_WIDTH),
        .BAUD_RATE (BAUD_RATE),
        .CLOCK_SPEED (CLOCK_SPEED),
        .OUTPUTS (OUTPUTS),
        .INPUTS (INPUTS)
   )
   main_module(
       .clk(clk),
       .rtx(rtx),
       .rst(rst),
       .input_io_ports({la_data_in[15:0],io_port_in}),
       .output_io_ports({la_out_value,io_port_out}),
       .trx(trx),
       .wstrb_i(wstrb),
       .wdata_i(wdata),
       .wbs_adr_i(wbs_adr_i),
       .valid_i(valid),
       .wbs_we_i(wbs_we_i),
       .ready_o(wbs_ack_o),
       .rdata_o(rdata)
   );

endmodule

`default_nettype wire
