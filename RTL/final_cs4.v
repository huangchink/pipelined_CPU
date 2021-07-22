`timescale 1ns/1ps
module final_cs4 (
  din1_i,
  din2_i,
  c28bar_i,
  sum_o,
  c32_o
);

input [3:0] din1_i, din2_i;
input c28bar_i;
output [3:0] sum_o;
output c32_o;

wire g28bar, g29bar, g30bar, g31bar, g2928, g3130, g3128bar,
     p28bar, p29bar, p30bar, p31bar, p2928, p3130, p3128bar,
     c28, c30;

assign c28 = ~c28bar_i;
assign g2928 = ~(g29bar & (g28bar | p29bar));
assign p2928 = ~(p28bar | p29bar);
assign g3130 = ~(g31bar & (g30bar | p31bar));
assign p3130 = ~(p30bar | p31bar);
assign c30 = (g2928 | (c28 & p2928));
assign g3128bar = ~(g3130 | (g2928 & p3130));
assign p3128bar = ~(p3130 & p2928);
assign c32_o = ~(g3128bar & (p3128bar | c28bar_i));

fa_2 u0 (
  .din1_i (din1_i[1:0]),
  .din2_i (din2_i[1:0]),
  .cin_i (c28),
  .sum_o  (sum_o[1:0]),
  .gbar_o ({g29bar,g28bar}),
  .pbar_o ({p29bar,p28bar}) 
);

fa_2 u1 (
  .din1_i (din1_i[3:2]),
  .din2_i (din2_i[3:2]),
  .cin_i (c30),
  .sum_o  (sum_o[3:2]),
  .gbar_o ({g31bar,g30bar}),
  .pbar_o ({p31bar,p30bar}) 
);

endmodule
