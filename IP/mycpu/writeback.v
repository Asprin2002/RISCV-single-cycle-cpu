module write_back
#(WIDTH = 32)
(      
       input [9 : 0]   opcode_info_i, 
       input [WIDTH-1 : 0]  alu_result_i,
       input [WIDTH-1 : 0]  mem_read_data_i,

       output[WIDTH-1 : 0]  wb_rd_write_data_o  
);


wire    op_load = opcode_info_i[4];

assign  wb_rd_write_data_o = op_load ? mem_read_data_i : alu_result_i;


endmodule
