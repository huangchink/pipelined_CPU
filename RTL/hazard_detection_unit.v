`timescale 1ns/1ps
module hazard_detection_unit(id_rs1_i, id_rs2_i, ex_rd_i, ex_reg_write_i, mem_rd_i, ex_mem_read_i, mem_reg_write_i, trust_o,
                             pc_keep_o, if_id_keep_o, id_ex_zero_o);

  input [`REG_ADDR_WIDTH - 1:0] id_rs1_i;          //from instruction(if/id)
  input [`REG_ADDR_WIDTH - 1:0] id_rs2_i;          //from instruction(if/id)
  input [`REG_ADDR_WIDTH - 1:0] ex_rd_i;           //from instruction(id/ex)
  input [`REG_ADDR_WIDTH - 1:0] mem_rd_i;           //from instruction(ex/mem)
  input                         ex_mem_read_i;      //from controller(id/ex)
  input                         ex_reg_write_i;
  input                         mem_reg_write_i;
  output pc_keep_o;                                   //if 1, kepp the value
  output if_id_keep_o;                                //if 1, kepp the value
  output id_ex_zero_o;                                //if 1, selsct zero to ID/EX reg
  output trust_o;

  reg pc_keep_o;
  reg if_id_keep_o;
  reg id_ex_zero_o;
  reg trust_o;

  always@(*)begin
    //load-use hazard is detected
    if(ex_mem_read_i && ((ex_rd_i==id_rs1_i) || (ex_rd_i==id_rs2_i)))begin
	  pc_keep_o = 1'b1;
	  if_id_keep_o = 1'b1;
	  id_ex_zero_o = 1'b1;
	end
	//no load-use hazard is detected
	else begin
	  pc_keep_o = 1'b0;
	  if_id_keep_o = 1'b0;
	  id_ex_zero_o = 1'b0;
	end

    if ((ex_reg_write_i && ((ex_rd_i == id_rs1_i) || (ex_rd_i == id_rs2_i))) ||
        (mem_reg_write_i && ((mem_rd_i == id_rs1_i) || (mem_rd_i == id_rs2_i)))) begin
      trust_o = 1'b0;
    end else begin
      trust_o = 1'b1;
    end
  end

endmodule
