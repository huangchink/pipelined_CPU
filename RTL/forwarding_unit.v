`timescale 1ns/1ps
module forwarding_unit(mem_rd_i, wb_rd_i, ex_rs1_i, ex_rs2_i, mem_reg_write_i, wb_reg_write_i, forwardingA_o, forwardingB_o);

  input [`REG_ADDR_WIDTH - 1:0] mem_rd_i;            //from instruction RD(ex/mem)
  input [`REG_ADDR_WIDTH - 1:0] wb_rd_i;            //from instruction RD(mem/wb)
  input [`REG_ADDR_WIDTH - 1:0] ex_rs1_i;                  //from instruction RS1(id/ex)
  input [`REG_ADDR_WIDTH - 1:0] ex_rs2_i;                  //from instruction RS2(id/ex)
  input mem_reg_write_i;                              //from controller(ex/mem)
  input wb_reg_write_i;                              //from controller(mem/wb)

  output [1:0] forwardingA_o;
  output [1:0] forwardingB_o;

  reg [1:0] forwardingA_o;
  reg [1:0] forwardingB_o;

  always@(*)begin
    //ex hazard
    if(mem_reg_write_i && mem_rd_i!=5'b0 && (ex_rs1_i==mem_rd_i))
      forwardingA_o = 2'b10;
      //mem hazard without ex hazard
    else if(wb_reg_write_i && wb_rd_i!=5'b0 && (ex_rs1_i==wb_rd_i))
      forwardingA_o = 2'b01;
    //no hazard
    else
      forwardingA_o = 2'b00;
    //ex hazard

    if(mem_reg_write_i && mem_rd_i!=5'b0 && (ex_rs2_i==mem_rd_i))
      forwardingB_o = 2'b10;
    //mem hazard without ex hazard
    else if(wb_reg_write_i && wb_rd_i!=5'b0 && (ex_rs2_i==wb_rd_i))
      forwardingB_o = 2'b01;
    //no hazard
    else
      forwardingB_o = 2'b00;
  end

endmodule
