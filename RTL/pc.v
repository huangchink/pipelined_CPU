`timescale 1ns/1ps
module pc (
  clk_i,
  rst_ni,
  pc_keep_i,       // from hazard detection unit
  ins_addr_d,      // from internal mux
  ins_addr_q	   // to ins_mem
);
  input clk_i,rst_ni,pc_keep_i;
  input [`DATA_WIDTH-1:0]ins_addr_d;
  output[`DATA_WIDTH-1:0]ins_addr_q;

  reg [`DATA_WIDTH-1:0]ins_addr_q;
  always@(negedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni)
      ins_addr_q<=`DATA_WIDTH'b0;
    else if(pc_keep_i==1'b1)
      ins_addr_q<=ins_addr_q;
    else
      ins_addr_q<=ins_addr_d;
  end
endmodule

