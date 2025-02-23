//fetch模块，仅供参考，可以随意修改

module fetch
#(WIDTH=32)
(
	input wire  [WIDTH - 1:0] pc_i,
	output wire [WIDTH - 1:0] fetch_inst_o
);
import "DPI-C" function int  dpi_mem_read 	(input int addr  , input int len);
import "DPI-C" function void dpi_ebreak		(input int pc);

assign fetch_inst_o = dpi_mem_read(pc_i, 4);

always @(*) begin
	if(fetch_inst_o == 32'h00100073) begin
		dpi_ebreak(pc_i);
	end
end
endmodule