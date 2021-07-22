`timescale 1ns/1ps
module cs18 (
  din1_i,
  din2_i,
  c10_i,
  sum_o,
  c28bar_o
);

input [17:0] din1_i, din2_i;
input c10_i;
output [17:0] sum_o;
output c28bar_o;

wire g1210, g1513, g1816, g2119, g2422, g2725, g1810bar, g2719bar, g2710,
     p1210, p1513, p1816, p2119, p2422, p2725, p1810bar, p2719bar, p2710,
     c13, c16, c19, c22, c25;

assign c13 = ~(~(g1210 | c10_i & p1210));
assign c16 = g1513 | (g1210 & p1513) | (p1513 & p1210 & c10_i);
assign g1810bar = ~(g1816 | (g1513 & p1816) | (g1210 & p1816 & p1513));
assign p1810bar = ~(p1816 & p1513 & p1210);
assign c10bar = ~c10_i;
assign c19 = ~(g1810bar & (p1810bar | c10bar));
 
assign c22 = ~(~(g2119 |( c19 & p2119)));
assign c25 = g2422 | (g2119 & p2422) | (p2422 & p2119 & c19);
assign g2719bar = ~(g2725 | (g2422 & p2725) | (g2119 & p2725 & p2422));
assign p2719bar = ~(p2725 & p2422 & p2119);
assign g2710 = ~(g2719bar & (g1810bar | p2719bar));
assign p2710 = ~(p2719bar | p1810bar);
assign c28bar_o = ~(g2710 | (p2710 & c10_i));

fa_3 u0 (
  .din1_i (din1_i[2:0]),
  .din2_i (din2_i[2:0]),
  .cin_i  (c10_i),
  .sum_o  (sum_o[2:0]),
  .p_o    (p1210),
  .g_o    (g1210)
);

fa_3 u1 (
  .din1_i (din1_i[5:3]),
  .din2_i (din2_i[5:3]),
  .cin_i  (c13),
  .sum_o  (sum_o[5:3]),
  .p_o    (p1513),
  .g_o    (g1513)
);

fa_3 u2 (
  .din1_i (din1_i[8:6]),
  .din2_i (din2_i[8:6]),
  .cin_i  (c16),
  .sum_o  (sum_o[8:6]),
  .p_o    (p1816),
  .g_o    (g1816)
);

fa_3 u3 (
  .din1_i (din1_i[11:9]),
  .din2_i (din2_i[11:9]),
  .cin_i  (c19),
  .sum_o  (sum_o[11:9]),
  .p_o    (p2119),
  .g_o    (g2119)
);

fa_3 u4 (
  .din1_i (din1_i[14:12]),
  .din2_i (din2_i[14:12]),
  .cin_i  (c22),
  .sum_o  (sum_o[14:12]),
  .p_o    (p2422),
  .g_o    (g2422)
);

fa_3 u5 (
  .din1_i (din1_i[17:15]),
  .din2_i (din2_i[17:15]),
  .cin_i  (c25),
  .sum_o  (sum_o[17:15]),
  .p_o    (p2725),
  .g_o    (g2725)
);

endmodule
