`timescale 1ns/1ps
module ex_mem_reg(clk_i, rst_ni,mem_ctrl_d,wb_ctrl_d,result_d,src_d,rd_d,wb_ctrl_q,mem_ctrl_q,result_q,src_q,rd_q);

  input clk_i;
  input rst_ni;

  input [`MEM_CTRL_WIDTH-1:0]mem_ctrl_d;				//from controller(ex/mem) to data_memory
  input [`WB_CTRL_WIDTH-1:0]wb_ctrl_d;                             //from controller(ex/mem) to registerfile

  input [`MEM_ADDR_WIDTH - 1:0] result_d;      //from the output of the alu to data_memory
  input [`DATA_WIDTH - 1:0]     src_d;    //from the output of mux to be written to data_memory
  input [`REG_ADDR_WIDTH - 1:0] rd_d;    //from instruction RD(ex/mem) to forwarding unit

  output reg [`MEM_CTRL_WIDTH-1:0]mem_ctrl_q;
  output reg [`WB_CTRL_WIDTH-1:0]wb_ctrl_q;


  output reg [`MEM_ADDR_WIDTH - 1:0] result_q;
  output reg [`DATA_WIDTH - 1:0]     src_q;
  output reg [`REG_ADDR_WIDTH - 1:0] rd_q;
  
 
  
  always@(negedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
	  wb_ctrl_q   <= 2'b0;
	  mem_ctrl_q  <= 2'b0;

          result_q   <= 32'b0;
	  src_q <= 32'b0;
	  rd_q <= 5'b0;
	end
	else begin
  	  wb_ctrl_q   <= wb_ctrl_d;
	  mem_ctrl_q  <= mem_ctrl_d;

	  result_q   <= result_d;
	  src_q <= src_d;
	  rd_q <= rd_d;
	end
  end
  
 endmodule
