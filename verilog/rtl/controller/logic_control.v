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
    parameter AUXILIAR_SIZE = 44,
    parameter SIZE_WORD = 3,
    parameter IO_OUTPUT_SIZE = 8,
    parameter INPUT_DATA_SIZE = 52,
    parameter STATUS_SIGNALS = 6,
    parameter DATA_WIDTH = 8,
    parameter INSTRUCTION_SIZE = 3,
    parameter SIZE_WORD_REGISTER = 3,
    parameter INSTRUCCION_INPUT_START = INPUT_DATA_SIZE - 1 , //51 
    parameter INSTRUCCION_INPUT_END = INSTRUCCION_INPUT_START - (INSTRUCTION_SIZE - 1), // 49
    parameter REGISTER_INPUT_START = INSTRUCCION_INPUT_END -1, // 48 
    parameter REGISTER_INPUT_END = REGISTER_INPUT_START - (SIZE_WORD_REGISTER - 1), // 44
    parameter AUXILIAR_INPUT_START = REGISTER_INPUT_END - 1,
    parameter AUXILIAR_INPUT_END = 0

)
(
    input clk,
    input rst,
    input [INPUT_DATA_SIZE-1:0] control_value,
    input valid_control_value,
    input busy_sender_data,
    input busy_io_module,
    input [IO_OUTPUT_SIZE-1:0] result_input_io,
    output [SIZE_WORD-1:0] size_line,
    output [WORD_SIZE-1:0] send_data_register,
    output valid_data,
    output [INSTRUCTION_SIZE-1:0] instrucction,
    output [SIZE_WORD_REGISTER-1:0] register,
    output [AUXILIAR_SIZE-1:0] auxiliar_register,
    output valid_instrucction
);

    // fix register with the multiple words
    reg [WORD_SIZE-1:0] data_1 = {8'h0D, 8'h59, 8'h53, 8'h42};
    reg [WORD_SIZE-1:0] data_2 = {8'h0D, 8'h0A, 8'h4B, 8'h4F};
    reg [WORD_SIZE-1:0] data_3 = {8'h0D, 8'h0A, 8'h20, 8'h30};
    reg [WORD_SIZE-1:0] data_4 = {8'h0D, 8'h0A, 8'h20, 8'h31};

    // status of the value to send
    reg valid_data;
    // fix size for now
    reg [SIZE_WORD-1:0] size_line = 3'h4; 

    // send_data_register
    reg [WORD_SIZE-1:0] send_data_register;

    // status of the IO module
    reg [1:0]send_petition_to_io;
    reg valid_instrucction;
    reg [INSTRUCTION_SIZE-1:0] instrucction;
    reg [SIZE_WORD_REGISTER-1:0] register;
    reg [AUXILIAR_SIZE-1:0] auxiliar_register;
    
    
    always @(posedge clk) begin
         if (rst) begin
            size_line <= 3'h4;
            send_data_register <= 0;
            valid_data <= 0;
            send_petition_to_io <= 2'b00;
        end
        else begin
            if (busy_io_module == 1'b0 & valid_control_value == 1'b1) begin
                valid_instrucction <= 1'b1;
                instrucction <= control_value[INSTRUCCION_INPUT_START: INSTRUCCION_INPUT_END];
                register <= control_value[REGISTER_INPUT_START : REGISTER_INPUT_END];
                auxiliar_register <= control_value[AUXILIAR_INPUT_START: AUXILIAR_INPUT_END];
                send_petition_to_io <= 2'b11;
            end
            else if (busy_io_module == 1'b1 & valid_control_value == 1'b1 & busy_sender_data == 1'b0) begin
                    send_data_register <= data_1; valid_data <= 1'b1; size_line <= 3'h4; 
            end
            else if(send_petition_to_io[0] == 1'b1) begin
                // a petition have been send so clean the valid instrucction
                valid_instrucction = 1'b0;
                if (busy_io_module == 1'b0 & send_petition_to_io[1] == 1'b0) begin
                    if (instrucction[INSTRUCTION_SIZE-1] == 1'b0 || instrucction == 3'b111) begin
                        send_petition_to_io<= 2'b00;
                        send_data_register <= data_2; 
                        valid_data <= 1'b1; 
                        size_line <= 3'h4;
                    end
                    else if (instrucction == 3'b110) begin
                        send_petition_to_io<= 2'b00;
                        valid_data <= 1'b1; 
                        size_line <= 3'h4;
                        send_data_register[31:16] <= 16'h0D0A;
                        // conversion from binary to hex
                        case (result_input_io[7:4])
                            4'h0 : send_data_register[7:0] <= 8'h30;
                            4'h1 : send_data_register[7:0] <= 8'h31;
                            4'h2 : send_data_register[7:0] <= 8'h32;
                            4'h3 : send_data_register[7:0] <= 8'h33;
                            4'h4 : send_data_register[7:0] <= 8'h34;
                            4'h5 : send_data_register[7:0] <= 8'h35;
                            4'h6 : send_data_register[7:0] <= 8'h36;
                            4'h7 : send_data_register[7:0] <= 8'h37;
                            4'h8 : send_data_register[7:0] <= 8'h38;
                            4'h9 : send_data_register[7:0] <= 8'h39;
                            4'hA : send_data_register[7:0] <= 8'h41;
                            4'hB : send_data_register[7:0] <= 8'h42;
                            4'hC : send_data_register[7:0] <= 8'h43;
                            4'hD : send_data_register[7:0] <= 8'h44;
                            4'hE : send_data_register[7:0] <= 8'h45;
                            4'hF : send_data_register[7:0] <= 8'h46;
                            default: send_data_register[7:0] <= 8'h00;
                        endcase
                        case (result_input_io[3:0])
                            4'h0 : send_data_register[15:8] <= 8'h30;
                            4'h1 : send_data_register[15:8] <= 8'h31;
                            4'h2 : send_data_register[15:8] <= 8'h32;
                            4'h3 : send_data_register[15:8] <= 8'h33;
                            4'h4 : send_data_register[15:8] <= 8'h34;
                            4'h5 : send_data_register[15:8] <= 8'h35;
                            4'h6 : send_data_register[15:8] <= 8'h36;
                            4'h7 : send_data_register[15:8] <= 8'h37;
                            4'h8 : send_data_register[15:8] <= 8'h38;
                            4'h9 : send_data_register[15:8] <= 8'h39;
                            4'hA : send_data_register[15:8] <= 8'h41;
                            4'hB : send_data_register[15:8] <= 8'h42;
                            4'hC : send_data_register[15:8] <= 8'h43;
                            4'hD : send_data_register[15:8] <= 8'h44;
                            4'hE : send_data_register[15:8] <= 8'h45;
                            4'hF : send_data_register[15:8] <= 8'h46;
                            default: send_data_register[15:8] <= 8'h00;
                        endcase
                    end
                    else begin
                        send_petition_to_io<= 2'b00;
                        if (result_input_io[0] == 1'b0 ) begin
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

endmodule
