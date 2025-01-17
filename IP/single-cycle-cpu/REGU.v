`include "define.v"
module REGU
#(WIDTH = 32, REG_WIDTH=5)
(
	input wire  [31:0]                      pc_for_debug,
	input wire  [31:0]						inst_for_debug,
	input wire 								clk,
	input wire 								rst,
	input wire 	[REG_WIDTH - 1	:0]			IDU_i_rs1,
	input wire 	[REG_WIDTH - 1	:0]			IDU_i_rs2,
	input wire 								IDU_i_reg_wen,
	input wire 	[REG_WIDTH - 1	:0]			IDU_i_rd,
	input wire  [WIDTH - 1		:0] 		IDU_i_valW,
	output wire [WIDTH - 1		:0] 		REGU_o_valA,
	output wire [WIDTH - 1		:0] 		REGU_o_valB,

	output wire    [31:0]REGU_o_regfile[31:0]
);	
reg [31:0] regfile[31:0];
assign REGU_o_valA = regfile[IDU_i_rs1];
assign REGU_o_valB = regfile[IDU_i_rs2];
import "DPI-C" function void dpi_ebreak		(input int pc);

always @(posedge clk) begin
	if(rst) begin
		regfile[0] <= 32'h0;
	end
	else if(IDU_i_reg_wen == `reg_wen_w && IDU_i_rd != 0) begin
		regfile[IDU_i_rd] <= IDU_i_valW;
	end
end

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : gen_regfile
        assign REGU_o_regfile[i] = regfile[i];
    end
endgenerate

endmodule //
