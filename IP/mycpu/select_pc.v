//select模块，仅供参考，可以随意修改
module select_pc(
    input wire     clk,
	input wire     rst,
	   
	input [31:0]   inst_i,
	   
	//from decode stage - regfile
	input [31:0]   regfile_rs1_rdata_i,
	//
	input [31:0]   imm_i,
	//from execute stage
	input          branch_jump_i,
	   
	output[31:0]   pc_next_o
);

reg [31:0] pc;

wire [6:0] opcode = inst_i[ 6: 0];

wire inst_jal       = (opcode == 7'b11_011_11);
wire inst_jalr      = (opcode == 7'b11_001_11);
wire inst_branch    = (opcode == 7'b11_000_11);

wire inst_jump = (inst_jal | inst_jalr | inst_branch);
wire jump_confirm = inst_jump & (inst_jalr | inst_jal | branch_jump_i);

wire [31:0] jump_pc_op1 = (inst_jal | inst_branch) ? pc :
                           inst_jalr               ? regfile_rs1_rdata_i 
	       				           :  0;
											
wire [31:0] jump_pc_op2 = imm_i;

wire [31:0] pc_add_op1 = jump_confirm ? jump_pc_op1 : pc;
wire [31:0] pc_add_op2 = jump_confirm ? jump_pc_op2 : 4;


assign pc_next_o = pc;

always @(posedge clk) begin
    if(rst) begin
	    pc <= 32'h80000000;    
	end 
    else begin
	    pc <= pc_add_op1 + pc_add_op2;
    end
end



endmodule