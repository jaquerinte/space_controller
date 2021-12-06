`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2021 11:48:39 AM
// Design Name: 
// Module Name: logic_control
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


module logic_control#
(
    parameter WORD_SIZE = 32,
    parameter SIZE_WORD = 3,
    parameter INPUT_DATA_SIZE = 40,
    parameter STATUS_SIGNALS = 4,
    parameter DATA_WIDTH = 8,
    parameter INSTRUCTION_SIZE = 3,
    parameter SIZE_WORD_REGISTER = 5
)
(
    input clk,
    input rst,
    input [INPUT_DATA_SIZE-1:0] control_value,
    input valid_control_value,
    input busy_sender_data,
    input busy_io_module,
    input result_input_io,
    output [SIZE_WORD-1:0] size_line,
    output [WORD_SIZE-1:0] send_data_register,
    output valid_data,
    output [INSTRUCTION_SIZE-1:0] instrucction,
    output [SIZE_WORD_REGISTER-1:0] register,
    output [WORD_SIZE-1:0] clock_time,
    output valid_instrucction
);


    // fix register with the multiple words
    reg [WORD_SIZE-1:0] data_1 = {8'h0D, 8'h59, 8'h53, 8'h42};
    reg [WORD_SIZE-1:0] data_2 = {8'h0D, 8'h0A, 8'h4B, 8'h4F};
    reg [WORD_SIZE-1:0] data_3 = {8'h0D, 8'h0A, 8'h20, 8'h30};
    reg [WORD_SIZE-1:0] data_4 = {8'h0D, 8'h0A, 8'h20, 8'h31};

    // status of the value to send
    (* mark_debug = "true" *) reg valid_data;
    // fix size for now
    reg [SIZE_WORD-1:0] size_line = 3'h4; 

    // send_data_register
    (* mark_debug = "true" *) reg [WORD_SIZE-1:0] send_data_register;

    // status of the IO module
    (* mark_debug = "true" *) reg [1:0]send_petition_to_io;
    reg valid_instrucction;
    reg [INSTRUCTION_SIZE-1:0] instrucction;
    reg [SIZE_WORD_REGISTER-1:0] register;
    reg [WORD_SIZE-1:0] clock_time;
    
    
    always @(posedge clk or posedge rst) begin
         if (rst) begin
            size_line <= 3'h4;
            send_data_register <= 0;
            valid_data <= 0;
            send_petition_to_io <= 2'b00;
        end
        else begin
            if (busy_io_module == 1'b0 & valid_control_value == 1'b1) begin
                valid_instrucction <= 1'b1;
                instrucction <= control_value[INPUT_DATA_SIZE-1: 37];
                register <= control_value[36: 32];
                clock_time <= control_value[WORD_SIZE -1: 0];
                send_petition_to_io <= 2'b11;
            end
            else if (busy_io_module == 1'b1 & valid_control_value == 1'b1 & busy_sender_data == 1'b0) begin
                    send_data_register <= data_1; valid_data <= 1'b1; size_line <= 3'h4; 
            end
            else if(send_petition_to_io[0] == 1'b1) begin
                // a petition have been send so clean the valid instrucction
                valid_instrucction = 1'b0;
                if (busy_io_module == 1'b0 & send_petition_to_io[1] == 1'b0) begin
                    if (instrucction[INSTRUCTION_SIZE-1] == 1'b0) begin
                        send_petition_to_io<= 2'b00;
                        send_data_register <= data_2; 
                        valid_data <= 1'b1; 
                        size_line <= 3'h4;
                    end
                    else begin
                        send_petition_to_io<= 2'b00;
                        if (result_input_io == 1'b0 ) begin
                            send_data_register <= data_3; 
                            valid_data <= 1'b1; 
                            size_line <= 3'h4;
                        end
                        else begin
                            send_data_register <= data_4; 
                            valid_data <= 1'b1; 
                            size_line <= 3'h4;
                        end

                    end

                end
                else if (busy_io_module == 1'b0) begin
                    send_petition_to_io <= send_petition_to_io >> 1;
                end
            end
            else begin
                valid_instrucction = 1'b0;
                valid_data <= 1'b0;
            end
        end
    end
    /*always @(posedge clk or posedge rst) begin
        if (rst) begin
            size_line <= 3'h4;
            send_data_register <= 0;
            valid_data <= 0;
        end
        else begin
            // main code
            if (busy_sender_data == 1'b0 & valid_control_value == 1'b1) begin
                // new valid data available
                 case(control_value)
                        40'h1000000000: begin send_data_register <= data_1; valid_data <= 1'b1; size_line <= 3'h4; end
                        40'h2000000000: begin send_data_register <= data_2; valid_data <= 1'b1; size_line <= 3'h4; end
                        40'h3000000000: begin send_data_register <= data_3; valid_data <= 1'b1; size_line <= 3'h4; end
                        default: valid_data <= 0;
                endcase
            end
            else begin
                valid_data <= 1'b0;
            end
        end
    end*/

endmodule
