`timescale 1ns/1ps
module id_ex_reg (
  clk_i,
  rst_ni,
  wb_ctrl_d,
  mem_ctrl_d,
  ex_ctrl_d,

  wb_ctrl_q ,
  mem_ctrl_q,
  ex_ctrl_q,

  data1_d,
  data2_d,
  extended_d,
  rs1_d,
  rs2_d,
  rd_d,
  funct3_d,
  branch_addr_d,
  branch_d,

  data1_q,
  data2_q,
  extended_q,
  rs1_q,
  rs2_q,
  rd_q,
  funct3_q,
  branch_addr_q,
  branch_q
);

input clk_i, rst_ni;
input [`WB_CTRL_WIDTH-1:0] wb_ctrl_d;
input [`MEM_CTRL_WIDTH-1:0] mem_ctrl_d;
input [`EX_CTRL_WIDTH-1:0] ex_ctrl_d;
input [`DATA_WIDTH-1:0] data1_d, data2_d, extended_d;
input [`REG_ADDR_WIDTH-1:0] rs1_d, rs2_d, rd_d;
input [`FUNCT3_WIDTH-1:0] funct3_d;
input [`MEM_ADDR_WIDTH-1:0] branch_addr_d;
input branch_d;

output reg [`WB_CTRL_WIDTH-1:0] wb_ctrl_q;
output reg [`MEM_CTRL_WIDTH-1:0] mem_ctrl_q;
output reg [`EX_CTRL_WIDTH-1:0] ex_ctrl_q;
output reg [`DATA_WIDTH-1:0] data1_q, data2_q, extended_q;
output reg [`REG_ADDR_WIDTH-1:0] rs1_q, rs2_q, rd_q;
output reg [`FUNCT3_WIDTH-1:0] funct3_q;
output reg [`MEM_ADDR_WIDTH-1:0] branch_addr_q;
output reg branch_q;

always@(negedge clk_i or negedge rst_ni) begin
  if (~rst_ni) begin
    wb_ctrl_q  <= 2'b0;
    mem_ctrl_q <= 2'b0;
    ex_ctrl_q  <= 5'b0;
    data1_q    <= 32'b0;
    data2_q    <= 32'b0;
    extended_q <= 32'b0;
    rs1_q      <= 5'b0;
    rs2_q      <= 5'b0;
    rd_q       <= 5'b0;
    funct3_q   <= 3'b0;
    branch_addr_q <= 32'b0;
    branch_q   <= 1'b0;
  end
  else begin
    wb_ctrl_q  <= wb_ctrl_d;
    mem_ctrl_q <= mem_ctrl_d;
    ex_ctrl_q  <= ex_ctrl_d;
    data1_q    <= data1_d;
    data2_q    <= data2_d;
    extended_q <= extended_d;
    rs1_q      <= rs1_d;
    rs2_q      <= rs2_d;
    rd_q       <= rd_d;
    funct3_q   <= funct3_d;
    branch_addr_q <= branch_addr_d;
    branch_q   <= branch_d;
  end
end

endmodule
