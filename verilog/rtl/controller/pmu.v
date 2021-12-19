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
    input  wire [2:0] trx_error,
    input  wire [2:0] output_io_error,
    output reg ready_o,
    output reg [WORD_SIZE - 1 : 0] rdata_o


);

reg [COUNTERSIZE-1:0] total_errors_trx [0:2];
reg [COUNTERSIZE-1:0] total_errors_io  [0:2];
reg [COUNTERSIZE-1:0] total_unrecobable_errors_trx;
reg [COUNTERSIZE-1:0] total_unrecobable_errors_io;

always @(posedge clk) begin
    if(rst) begin
        total_errors_trx[0]    <= {WORD_SIZE {1'b0}};
        total_errors_trx[1]    <= {WORD_SIZE {1'b0}};
        total_errors_trx[2]    <= {WORD_SIZE {1'b0}};
        total_errors_io[0]     <= {WORD_SIZE {1'b0}};
        total_errors_io[1]     <= {WORD_SIZE {1'b0}};
        total_errors_io[2]     <= {WORD_SIZE {1'b0}};

    end
    else begin
        // couting errors 
        if (trx_error != 3'b000) begin
            case (trx_error)
                3'b001:  total_errors_trx[0] <= total_errors_trx[0] + 1;
                3'b010:  total_errors_trx[1] <= total_errors_trx[1] + 1;
                3'b100:  total_errors_trx[2] <= total_errors_trx[2] + 1;
                default: total_unrecobable_errors_trx = total_unrecobable_errors_trx + 1;
            endcase
        end 
        if (output_io_error != 3'b000) begin
            case (trx_error)
                3'b001:  total_errors_io[0] <= total_errors_io[0] + 1;
                3'b010:  total_errors_io[1] <= total_errors_io[1] + 1;
                3'b100:  total_errors_io[2] <= total_errors_io[2] + 1;
                default: total_unrecobable_errors_io = total_unrecobable_errors_io + 1;
            endcase
        end
        
        if (valid_i && wbs_adr_i[31:12] == ADDRBASE) begin
            case (wbs_adr_i[3:0]) 
                4'h0: begin
                    ready_o <= 1'b1;
                    if (wbs_we_i) begin
                        if (wstrb_i[0]) total_errors_trx[wbs_adr_i[5:4]][7:0]   <= wdata_i[7:0];
                        if (wstrb_i[1]) total_errors_trx[wbs_adr_i[5:4]][15:8]  <= wdata_i[15:8];
                        if (wstrb_i[2]) total_errors_trx[wbs_adr_i[5:4]][23:16] <= wdata_i[23:16];
                        if (wstrb_i[3]) total_errors_trx[wbs_adr_i[5:4]][31:24] <= wdata_i[31:24];
                    end
                    else begin
                        rdata_o <= {total_errors_trx[wbs_adr_i[5:4]]};
                    end

                end
                4'h4: begin
                    ready_o <= 1'b1;
                    if (wbs_we_i) begin
                        if (wstrb_i[0]) total_errors_io[wbs_adr_i[5:4]][7:0]   <= wdata_i[7:0];
                        if (wstrb_i[1]) total_errors_io[wbs_adr_i[5:4]][15:8]  <= wdata_i[15:8];
                        if (wstrb_i[2]) total_errors_io[wbs_adr_i[5:4]][23:16] <= wdata_i[23:16];
                        if (wstrb_i[3]) total_errors_io[wbs_adr_i[5:4]][31:24] <= wdata_i[31:24];
                    end
                    else begin
                        rdata_o <= {total_errors_io[wbs_adr_i[5:4]]};
                    end
                end
            endcase
        end
        else begin
            ready_o <= 1'b0;
        end
    end
end

endmodule
`default_nettype wire