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
    parameter SIZE_WORD = 5,
    parameter WORD_SIZE = 32,
    parameter INSTRUCTION_SIZE = 3,
    parameter OUTPUTS = 32,
    parameter INPUTS = 32,
    parameter ONE_SECOND_CLOCK = 32'h07735940
)
(
    input clk,
    input rst,
    (* mark_debug = "true" *)input [INSTRUCTION_SIZE-1:0] instrucction,
    (* mark_debug = "true" *)input [SIZE_WORD-1:0] register,
    (* mark_debug = "true" *)input [WORD_SIZE-1:0] clock_time,
    input valid_instrucction,
    input [INPUTS-1:0] input_io,
    output busy,
    output valid_io,
    output result_input_io, 
    output [OUTPUTS-1:0] output_io
    );
        reg busy;
        (* mark_debug = "true" *) reg result_input_io;
        (* mark_debug = "true" *) reg [OUTPUTS-1:0]output_io;
        (* mark_debug = "true" *) reg valid_io;
        (* mark_debug = "true" *) reg [WORD_SIZE-1:0] curent_clock;
        (* mark_debug = "true" *) reg delay_maintained;


    always @(posedge clk or posedge rst) begin

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
                    if (instrucction[2:1] == 2'b00) begin
                        output_io[register] <= 1'b0;
                        busy <= 0;
                    end
                    else if (instrucction == 3'b010) begin
                        //output_io[register] <= 1'b0;
                        //busy <= 0;
                        // TODO
                    end
                    else if (instrucction == 3'b011) begin
                        if (delay_maintained == 1'b0) begin
                            busy <= 0;
                            output_io[register] <= 1'b0;
                        end
                        else begin
                            output_io[register] <= 1'b1;
                            curent_clock <= clock_time;
                            busy <= 1;
                            delay_maintained <= 1'b0;
                        end
                        
                    end
                    else if (instrucction[2:1] == 2'b10) begin
                        valid_io <= 1;
                        busy <= 0;
                        result_input_io <= input_io[register];
                    end
                    end
                    else if (instrucction == 3'b110) begin
                        //output_io[register] <= 1'b0;
                        //busy <= 0;
                        // TODO
                    end
                    else if (instrucction == 3'b111) begin
                        if (delay_maintained == 1'b0) begin
                            busy <= 0;
                            result_input_io <= input_io[register];
                        end
                        else begin
                            result_input_io <= input_io[register];
                            curent_clock <= clock_time;
                            busy <= 1;
                            delay_maintained <= 1'b0;
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
                        curent_clock <= ONE_SECOND_CLOCK;
                        output_io[register] <= 1'b1;
                        valid_io <= 1'b1;
                        busy <= 1;
                    end
                    else if (instrucction == 3'b001) begin
                        curent_clock <= clock_time;
                        output_io[register] <= 1'b1;
                        valid_io <= 1'b1;
                        busy <= 1;
                    end
                    else if (instrucction == 3'b010) begin
                        // TODO
                        output_io[register] <= 1'b0;
                        valid_io <= 1'b1;
                        busy <= 1;
                    end
                    else if (instrucction == 3'b011) begin
                        curent_clock <= clock_time;
                        delay_maintained <= 1'b1;
                        valid_io <= 1'b0;
                        busy <= 1;        
                    end
                    else if (instrucction == 3'b100) begin
                        curent_clock <= 0;
                        busy <= 1;
                        valid_io <= 1'b0;      
                    end
                    else if (instrucction == 3'b101) begin
                        curent_clock <= clock_time;
                        busy <= 1;
                        valid_io <= 1'b0;       
                    end
                    else if (instrucction == 3'b110) begin
                        // TODO       
                    end
                    else if (instrucction == 3'b111) begin
                        delay_maintained <= 1'b1; 
                        curent_clock <= clock_time;
                        busy <= 1;
                        valid_io <= 1'b0;         
                    end
                end
            end
        end
        

    
    end





endmodule
