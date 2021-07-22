`timescale 1ns/1ps
`include"first_cs4.v"
`include"cs6.v"
`include"cs18.v"
`include"final_cs4.v"
`include"fa_3.v"
`include "fa_cbar.v"
`include "fa_0pg.v"
`include "fa_cpg.v"
`include "fa_2.v"
module cs32_adder (
  din1_i,
  din2_i,
  cin_i,
  cout_o,
  sum_o
);

input [31:0] din1_i, din2_i;
input cin_i;
output cout_o;
output [31:0] sum_o;

first_cs4 u0(
  .din1_i (din1_i[3:0]),
  .din2_i (din2_i[3:0]),
  .cin_i  (cin_i),
  .cbar_o (c4bar),
  .sum_o  (sum_o[3:0])
);

cs6 u1(
  .din1_i (din1_i[9:4]),
  .din2_i (din2_i[9:4]),
  .c4bar_i  (c4bar),
  .c10_o (c10),
  .sum_o  (sum_o[9:4])
);

cs18 u2(
  .din1_i (din1_i[27:10]),
  .din2_i (din2_i[27:10]),
  .c10_i  (c10),
  .c28bar_o (c28bar),
  .sum_o  (sum_o[27:10])
);

final_cs4 u3(
  .din1_i (din1_i[31:28]),
  .din2_i (din2_i[31:28]),
  .c28bar_i  (c28bar),
  .c32_o (cout_o),
  .sum_o  (sum_o[31:28])
);

endmodule

