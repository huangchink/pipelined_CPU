`timescale 1ns/1ps
module fa_3 (
  din1_i,
  din2_i,
  cin_i,
  sum_o,
  p_o,
  g_o
);

input [2:0] din1_i, din2_i;
input cin_i;
output [2:0] sum_o;
output p_o, g_o;

wire [1:0] c;
wire [2:0] g, p;

assign c = (din1_i[1:0] & din2_i[1:0]) | (din1_i[1:0] & {c[0],cin_i}) | (din2_i[1:0] & {c[0],cin_i});
assign sum_o = din1_i ^ din2_i ^ {c[1:0],cin_i};

assign p = din1_i ^ din2_i;
assign g = din1_i & din2_i;

assign p_o = &p;
assign g_o = g[2] | (g[1] & p[2]) | (g[0] & p[2] & p[1]);

endmodule
