`timescale 1ns/1ps
module fa_cbar (
  din1_i, 
  din2_i,
  cin_i,
  cbar_o,
  sum_o,
);

input din1_i, din2_i, cin_i;
output cbar_o, sum_o;

assign sum_o = din1_i ^ din2_i ^ cin_i;
assign cbar_o = ~ ( (din1_i & din2_i) | (din1_i & cin_i) | (din2_i & cin_i) );

endmodule
