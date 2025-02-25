//CPU模块, 不可修改，你的处理器需要在此实例化各个模块
module cpu_top(
	input wire clk,
	input wire rst,

	output wire [31:0] cur_pc_for_simulator
);

wire [31:0]  pc_next;
wire [31:0]  fetch_inst;

wire [ 4:0]  decode_rs1_id;
wire [ 4:0]  decode_rs2_id;
wire [ 4:0]  decode_rd_id;
wire [11:0]  decode_csr_id;
	
wire [9:0]  decode_opcode_info;
wire [9:0]  decode_alu_info;
wire [5:0]  decode_branch_info;
wire [7:0]  decode_load_store_info;
wire [5:0]  decode_csr_info_o;
	
wire [31:0]  regfile_rs1_rdata;
wire [31:0]  regfile_rs2_rdata;

wire         decode_rd_write_en;
wire [31:0]  decode_imm;

wire [31:0]  execute_alu_result;
wire [31:0]  execute_mem_addr;
wire         execute_branch_jump;

wire [31:0]  mem_read_data;

wire         wb_rd_write_en;
wire [ 4:0]  wb_rd_id;
wire [31:0]  wb_rd_write_data;

assign cur_pc_for_simulator = pc_next;

fetch u_fetch(
    .pc_i           (pc_next),
    .fetch_inst_o         (fetch_inst)
);

wire [5:0] decode_csr_info;
wire [11:0] decode_csr_id;

decode u_decode(
	.clk                       (clk),
	.rst                       (rst),
	.fetch_inst_i                    (fetch_inst),
	//from write back stage

	.wb_rd_write_data_i        (wb_rd_write_data),
	
	.decode_rs1_id_o           (decode_rs1_id),
	.decode_rs2_id_o           (decode_rs2_id),
	.decode_rd_id_o            (decode_rd_id),
	.decode_csr_id_o           (decode_csr_id),
	
	.decode_opcode_info_o      (decode_opcode_info),
	.decode_alu_info_o         (decode_alu_info ),
	.decode_branch_info_o      (decode_branch_info ),
	.decode_load_store_info_o  (decode_load_store_info ),
	.decode_csr_info_o         (decode_csr_info),
	
	.regfile_rs1val_o       (regfile_rs1_rdata),
	.regfile_rs2val_o       (regfile_rs2_rdata),
	
	.decode_immval_o              (decode_imm)
);

execute u_execute(
	.decode_opcode_info_i          (decode_opcode_info),
	.decode_alu_info_i             (decode_alu_info),
	.decode_branch_info_i          (decode_branch_info),
	.decode_load_store_info_i      (decode_load_store_info),
	
	.pc_i                   (pc_next),
	.decode_rs1_i    (regfile_rs1_rdata),
	.decode_rs2_i    (regfile_rs2_rdata),
	.decode_imm_i                  (decode_imm),

	.execute_valE_o   (execute_alu_result),
	.execute_mem_addr_o     (execute_mem_addr),
	.execute_branch_jump_o  (execute_branch_jump)
);

memory_access u_memory(
      .clk                (clk),
	  .decode_load_store_info_i  (decode_load_store_info),
	  .execute_mem_addr_i         (execute_mem_addr),	  
	  .execute_write_data_i   (regfile_rs2_rdata),	   
	  .memory_read_data_o    (mem_read_data)
);

write_back u_write_back(
	  .opcode_info_i      (decode_opcode_info),
	  
	  .alu_result_i       (execute_alu_result),
	  .mem_read_data_i    (mem_read_data),
	  
	  .wb_rd_write_data_o (wb_rd_write_data)
);

select_pc u_select_pc(

     .clk                  (clk),
	 .rst                  (rst),	 
	 .inst_i               (fetch_inst),
	 .regfile_rs1_rdata_i  (regfile_rs1_rdata),
	 .imm_i                (decode_imm),
	 .branch_jump_i        (execute_branch_jump),
	 .pc_next_o            (pc_next)
);

endmodule