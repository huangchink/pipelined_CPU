`timescale 1ns/1ps
module fa_cpg (
  din1_i,
  din2_i,
  cin_i,
  sum_o,
  gbar_o,
  pbar_o,
  cbar_o
);

input din1_i, din2_i, cin_i;
output sum_o, pbar_o, gbar_o, cbar_o;

assign sum_o = din1_i ^ din2_i ^ cin_i;
assign pbar_o = ~ (din1_i ^ din2_i);
assign gbar_o = ~ (din1_i & din2_i);
assign cbar_o = ~ ( (din1_i & din2_i) | (din1_i & cin_i) | (din2_i & cin_i) );

endmodule
