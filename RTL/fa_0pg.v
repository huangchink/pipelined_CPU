`timescale 1ns/1ps
module fa_0pg (
  din1_i,
  din2_i,
  cbarin_i,
  sum_o,
  gbar_o,
  pbar_o
);

input din1_i, din2_i, cbarin_i;
output sum_o, pbar_o, gbar_o;

assign sum_o = din1_i ^ din2_i ^ ~cbarin_i;
assign pbar_o = ~ (din1_i ^ din2_i);
assign gbar_o = ~ (din1_i & din2_i);

endmodule
