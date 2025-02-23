
//****************************************VSCODE PLUG-IN**********************************//
//----------------------------------------------------------------------------------------
// IDE :                   VSCODE     
// VSCODE plug-in version: Verilog-Hdl-Format-3.3.20250120
// VSCODE plug-in author : Jiang Percy
//----------------------------------------------------------------------------------------
//****************************************Copyright (c)***********************************//
// Copyright(C)            Please Write Company name
// All rights reserved     
// File name:              
// Last modified Date:     2025/02/14 22:34:19
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              execute.v
// PATH:                   ~/single-cycle-cpu/IP/mycpu/execute.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module execute
#(WIDTH = 32, REG_WIDTH=5)
(

	input wire[9 : 0]  decode_opcode_info_i,
	input wire[9 : 0]  decode_alu_info_i,
	input wire[5 : 0]  decode_branch_info_i,
	input wire[7 : 0]  decode_load_store_info_i,
    
    input wire[WIDTH-1 : 0]      decode_rs1_i,
    input wire[WIDTH-1 : 0]      decode_rs2_i,
    input wire[WIDTH-1 : 0]      decode_imm_i,
    input wire[WIDTH-1 : 0] 	 pc_i,

    output wire[WIDTH-1 : 0]     execute_valE_o,
	output wire[WIDTH-1 : 0]     execute_mem_addr_o,
	output wire                  execute_branch_jump_o


);

alu alu_module(
	.opcode_info_i     (decode_opcode_info_i    ),
	.alu_info_i        (decode_alu_info_i       ),
	.branch_info_i     (decode_branch_info_i    ),
	.load_store_info_i (decode_load_store_info_i),

	.pc_i              (pc_i               ),
	.rs1_data_i        (decode_rs1_i),
	.rs2_data_i        (decode_rs2_i),
	.imm_i             (decode_imm_i              ),
	
	.alu_result_o      (execute_valE_o ),
	.mem_addr_o        (execute_mem_addr_o   ),
	.alu_branch_jump_o (execute_branch_jump_o)
);

                                                                   
                                                                   
endmodule

