`timescale 1ns/1ps
module mem_wb_reg(clk_i, rst_ni,
                  wb_ctrl_d, read_data_d, result_d, rd_d,
                  wb_ctrl_q, read_data_q, result_q, rd_q);

  input clk_i;
  input rst_ni;

  input [`WB_CTRL_WIDTH - 1:0] wb_ctrl_d;              //from controller(ex/mem
  input [`DATA_WIDTH - 1:0] read_data_d;               //from the output of the memory to the MUX
  input [`DATA_WIDTH - 1:0] result_d;                  //from the result(ex/mem) of the ALU to the MUX
  input [`REG_ADDR_WIDTH - 1:0] rd_d;                  //from instruction RD(ex/mem) to forwarding unit

  output [`WB_CTRL_WIDTH - 1:0] wb_ctrl_q;
  output [`DATA_WIDTH - 1:0] read_data_q;
  output [`DATA_WIDTH - 1:0] result_q;
  output [`REG_ADDR_WIDTH - 1:0] rd_q;

  reg [`WB_CTRL_WIDTH - 1:0] wb_ctrl_q;
  reg [`DATA_WIDTH - 1:0] read_data_q;
  reg [`DATA_WIDTH - 1:0] result_q;
  reg [`REG_ADDR_WIDTH - 1:0] rd_q;

  always@(negedge clk_i or negedge rst_ni)begin
    if(~rst_ni)begin
	  wb_ctrl_q <= 2'b00;
	  read_data_q <= 32'b0;
	  result_q <= 32'b0;
	  rd_q <= 5'b0;
	end
	else begin
	  wb_ctrl_q <= wb_ctrl_d;
	  read_data_q <= read_data_d;
	  result_q <= result_d;
	  rd_q <= rd_d;
	end
  end

 endmodule
