`timescale 1ns/1ps
module cs6 (
  din1_i,
  din2_i,
  c4bar_i,
  c10_o,
  sum_o
);

input [5:0] din1_i, din2_i;
input c4bar_i;
output [5:0] sum_o;
output c10_o;

wire g64, g97, g94bar, p64, p97, p94bar, c4, c7, c7bar;

assign c4 = ~c4bar_i;
assign c7 = ~c7bar;
assign g94bar = ~(g97 | (p97 & g64));
assign p94bar = ~(p97 & p64);
assign c7bar =  ~(g64 | (p64 & c4));
assign c10_o = ~(g94bar & (p94bar | c4bar_i));

fa_3 u0 (
  .din1_i (din1_i[2:0]),
  .din2_i (din2_i[2:0]),
  .cin_i  (c4),
  .sum_o  (sum_o[2:0]),
  .p_o    (p64),
  .g_o    (g64)
);

fa_3 u1 (
  .din1_i (din1_i[5:3]),
  .din2_i (din2_i[5:3]),
  .cin_i  (c7),
  .sum_o  (sum_o[5:3]),
  .p_o    (p97),
  .g_o    (g97)
);

endmodule
