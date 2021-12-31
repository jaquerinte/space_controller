`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2021 09:32:45 AM
// Design Name: 
// Module Name: io_module
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


module io_module #
(
    parameter SIZE_WORD = 3,
    parameter WORD_SIZE = 32,
    parameter INSTRUCTION_SIZE = 3,
    parameter IO_OUTPUT_SIZE = 8,
    parameter AUXILIAR_SIZE = 44,
    parameter OUTPUTS = 32,
    parameter INPUTS = 32, 
    parameter ONE_SECOND_CLOCK = 44'h00005F5E100
)
(
    input clk,
    input rst,
    input [INSTRUCTION_SIZE-1:0] instrucction,
    input [SIZE_WORD-1:0] register,
    input [AUXILIAR_SIZE-1:0] auxiliar_register,
    input valid_instrucction,
    input [INPUTS-1:0] input_io,
    output busy,
    output valid_io,
    output [IO_OUTPUT_SIZE-1:0] result_input_io, 
    output [OUTPUTS-1:0] output_io
);
        reg busy;
        reg [IO_OUTPUT_SIZE-1:0] result_input_io;
        reg [OUTPUTS-1:0]output_io;
        reg valid_io;
        reg [AUXILIAR_SIZE-1:0] curent_clock;
        reg delay_maintained;


    always @(posedge clk) begin

        if (rst) begin
            busy <= 0;
            valid_io <= 0;
            output_io <= 0;
            curent_clock <= 0;
            delay_maintained <= 0;
        end
        else begin
            if (busy == 1) begin
                if (curent_clock == 0) begin
                    // MANTENINED 
                    if (instrucction == 3'b000) begin
                        output_io[register] <= 1'b0;
                        busy <= 0;
                    end
                    // DELAYDED TWO TIMES READ AND DELAED 1 SEC AND MANTEINED 
                    else if (instrucction == 3'b010 || instrucction == 3'b001) begin
                        if (delay_maintained == 1'b0) begin
                            busy <= 0;
                            output_io[register] <= 1'b0;
                        end
                        else begin
                            output_io[register] <= 1'b1;
                            curent_clock <= auxiliar_register;
                            busy <= 1;
                            delay_maintained <= 1'b0;
                        end 
                    end
                    else if (instrucction == 3'b011) begin
                        busy <= 0;
                        valid_io <= 0;
                        // stop the writes
                        output_io[register]                 <= 1'b0;
                        // register 6
                        output_io[auxiliar_register[43:39]] <= 1'b0;
                        // register 5
                        output_io[auxiliar_register[38:34]] <= 1'b0;
                        // register 4
                        output_io[auxiliar_register[33:29]] <= 1'b0;
                        // register 3
                        output_io[auxiliar_register[28:24]] <= 1'b0;
                        // register 2
                        output_io[auxiliar_register[23:19]] <= 1'b0;
                        // register 1
                        output_io[auxiliar_register[18:14]] <= 1'b0;
                        // register 0
                        output_io[auxiliar_register[13:9]]  <= 1'b0;
                    end
                    // END WRITES
                    else if (instrucction[2:1] == 2'b10) begin
                        valid_io <= 1;
                        busy <= 0;
                        result_input_io[0] <= input_io[register];
                    end
                    else if (instrucction == 3'b110) begin
                        valid_io <= 1;
                        busy <= 0;
                        // register 7
                        result_input_io[7] <= input_io[register];
                        // register 6
                        result_input_io[6] <= input_io[auxiliar_register[43:39]];
                        // register 5
                        result_input_io[5] <= input_io[auxiliar_register[38:34]];
                        // register 4
                        result_input_io[4] <= input_io[auxiliar_register[33:29]];
                        // register 3
                        result_input_io[3] <= input_io[auxiliar_register[28:24]];
                        // register 2
                        result_input_io[2] <= input_io[auxiliar_register[23:19]];
                        // register 1
                        result_input_io[1] <= input_io[auxiliar_register[18:14]];
                        // register 0
                        result_input_io[0] <= input_io[auxiliar_register[13:9]];
                    end
                    else if (instrucction == 3'b111) begin
                        if (delay_maintained == 1'b0) begin
                            busy <= 0;
                            valid_io <= 0;
                            // stop the writes
                            output_io[register]                 <= 1'b0;
                            // register 6
                            output_io[auxiliar_register[43:39]] <= 1'b0;
                            // register 5
                            output_io[auxiliar_register[38:34]] <= 1'b0;
                            // register 4
                            output_io[auxiliar_register[33:29]] <= 1'b0;
                            // register 3
                            output_io[auxiliar_register[28:24]] <= 1'b0;
                            // register 2
                            output_io[auxiliar_register[23:19]] <= 1'b0;
                            // register 1
                            output_io[auxiliar_register[18:14]] <= 1'b0;
                            // register 0
                            output_io[auxiliar_register[13:9]]  <= 1'b0;
                        end
                        else begin
                            curent_clock <= ONE_SECOND_CLOCK;
                            busy <= 1;
                            delay_maintained <= 1'b0;
                            // start the writes
                            // register 7
                            output_io[register]                 <= auxiliar_register[7];
                            // register 6
                            output_io[auxiliar_register[43:39]] <= auxiliar_register[6];
                            // register 5
                            output_io[auxiliar_register[38:34]] <= auxiliar_register[5];
                            // register 4
                            output_io[auxiliar_register[33:29]] <= auxiliar_register[4];
                            // register 3
                            output_io[auxiliar_register[28:24]] <= auxiliar_register[3];
                            // register 2
                            output_io[auxiliar_register[23:19]] <= auxiliar_register[2];
                            // register 1
                            output_io[auxiliar_register[18:14]] <= auxiliar_register[1];
                            // register 0
                            output_io[auxiliar_register[13:9]] <= auxiliar_register[0];
                        end 
                        
                    end
                end
                else begin
                   curent_clock <= curent_clock - 1'b1;
                end
            end
            else begin
                valid_io <= 1'b0;
                if (valid_instrucction == 1'b1)begin
                    if (instrucction == 3'b000) begin
                        curent_clock <= auxiliar_register;
                        output_io[register] <= 1'b1;
                        valid_io <= 1'b1;
                        busy <= 1;
                    end
                    else if (instrucction == 3'b001) begin
                        curent_clock <= ONE_SECOND_CLOCK;
                        output_io[register] <= 1'b1;
                        delay_maintained <= 1'b1;
                        valid_io <= 1'b1;
                        busy <= 1;
                    end
                    else if (instrucction == 3'b010) begin
                        curent_clock <= auxiliar_register;
                        delay_maintained <= 1'b1;
                        valid_io <= 1'b0;
                        busy <= 1;        
                    end
                    else if (instrucction == 3'b011) begin
                        curent_clock <= 0;
                        valid_io <= 1'b1;
                        busy <= 1;
                        // start the writes
                        // register 7
                        output_io[register]                 <= auxiliar_register[7];
                        // register 6
                        output_io[auxiliar_register[43:39]] <= auxiliar_register[6];
                        // register 5
                        output_io[auxiliar_register[38:34]] <= auxiliar_register[5];
                        // register 4
                        output_io[auxiliar_register[33:29]] <= auxiliar_register[4];
                        // register 3
                        output_io[auxiliar_register[28:24]] <= auxiliar_register[3];
                        // register 2
                        output_io[auxiliar_register[23:19]] <= auxiliar_register[2];
                        // register 1
                        output_io[auxiliar_register[18:14]] <= auxiliar_register[1];
                        // register 0
                        output_io[auxiliar_register[13:9]] <= auxiliar_register[0];
                    end
                    else if (instrucction == 3'b100) begin
                        curent_clock <= auxiliar_register;
                        busy <= 1;
                        valid_io <= 1'b0;      
                    end
                    else if (instrucction == 3'b101) begin
                        curent_clock <= auxiliar_register;
                        busy <= 1;
                        valid_io <= 1'b0;       
                    end
                    else if (instrucction == 3'b110) begin
                        curent_clock <= 0;
                        busy <= 1;
                        valid_io <= 1'b0;       
                    end
                    else if (instrucction == 3'b111) begin
                        curent_clock <= ONE_SECOND_CLOCK;
                        delay_maintained <= 1'b1;
                        busy <= 1;
                        valid_io <= 1'b0;       
                    end
                end
            end
        end
        

    
    end





endmodule
