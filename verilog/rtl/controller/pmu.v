`timescale 1ns / 1ps
`default_nettype none


module PMU#
(
    parameter WORD_SIZE = 32,
    parameter OUTPUTS = 32,
    parameter integer WHISBONE_ADR = 32,
    parameter INPUTS = 32,
    parameter integer COUNTERSIZE = 32,
    parameter [19:0]  ADDRBASE     = 20'h3000_0

)
(
    input  wire clk,
    input  wire rst,
    input  wire [3 : 0] wstrb_i,
    input  wire [WORD_SIZE -1 : 0] wdata_i,
    input  wire [WHISBONE_ADR - 1 : 0] wbs_adr_i,
    input  wire valid_i,
    input  wire wbs_we_i,
    output reg ready_o,
    output reg [WORD_SIZE - 1 : 0] rdata_o


);

reg [COUNTERSIZE-1:0] total_clk_pass;

always @(posedge clk) begin
    if(rst) begin
        total_clk_pass    <= {WORD_SIZE {1'b0}};
    end
    else begin
        total_clk_pass <= total_clk_pass + 1;
        if (valid_i && wbs_adr_i[31:12] == ADDRBASE) begin
            ready_o <= 1'b1;
            if (wbs_we_i) begin
                if (wstrb_i[0]) total_clk_pass[7:0]   <= wdata_i[7:0];
                if (wstrb_i[1]) total_clk_pass[15:8]  <= wdata_i[15:8];
                if (wstrb_i[2]) total_clk_pass[23:16] <= wdata_i[23:16];
                if (wstrb_i[3]) total_clk_pass[31:24] <= wdata_i[31:24];
            end
            else begin
                rdata_o <= {total_clk_pass};
            end
        end
        else begin
            ready_o <= 1'b0;
        end
    end
end

endmodule
`default_nettype wire