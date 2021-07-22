`timescale 1ns/1ps
module fa_2 (
  din1_i,
  din2_i,
  cin_i,
  sum_o,
  pbar_o,
  gbar_o
);

input [1:0] din1_i, din2_i;
input cin_i;
output [1:0] sum_o, pbar_o, gbar_o;

wire c;
wire [1:0] g, p;

assign c = (din1_i & din2_i) | (din1_i & cin_i) | (din2_i & cin_i);
assign sum_o = din1_i ^ din2_i ^ {c, cin_i};

assign pbar_o = ~(din1_i ^ din2_i);
assign gbar_o = ~(din1_i & din2_i);

endmodule
