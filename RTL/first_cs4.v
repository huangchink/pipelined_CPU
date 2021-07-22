`timescale 1ns/1ps
module first_cs4 (
  din1_i, 
  din2_i,
  cin_i,
  cbar_o,
  sum_o
);

input [3:0] din1_i, din2_i;
input cin_i;
output [3:0] sum_o;
output cbar_o;

wire c1bar, g1bar, g2bar, g3bar, p1bar, p2bar, p3bar, c3bar; 

assign c2 = ~((p1bar | c1bar) & g1bar);
assign g32 = ~(g3bar & (p3bar | g2bar));
assign p32 = ~(p3bar | p2bar);
assign cbar_o = ~(g32 | (p32 & c2));

fa_cbar u0 (
  .din1_i (din1_i[0]), 
  .din2_i (din2_i[0]),
  .cin_i  (cin_i),
  .cbar_o (c1bar),
  .sum_o  (sum_o[0])
);

fa_0pg u1 (
  .din1_i (din1_i[1]),
  .din2_i (din2_i[1]),
  .cbarin_i (c1bar),
  .sum_o  (sum_o[1]),
  .gbar_o (g1bar),
  .pbar_o (p1bar) 
);

fa_cpg u2 (
  .din1_i (din1_i[2]),
  .din2_i (din2_i[2]),
  .cin_i  (c2),
  .sum_o  (sum_o[2]),
  .gbar_o (g2bar),
  .pbar_o (p2bar),
  .cbar_o (c3bar)
);

fa_0pg u3 (
  .din1_i (din1_i[3]),
  .din2_i (din2_i[3]),
  .cbarin_i (c3bar),
  .sum_o  (sum_o[3]),
  .gbar_o (g3bar),
  .pbar_o (p3bar) 
);

endmodule
