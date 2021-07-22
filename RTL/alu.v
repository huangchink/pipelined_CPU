`timescale 1ns/1ps
`include "def.v" // command this line
//`include "csa_32.v"
//`include "adder_32.v"
`include "cs32_adder.v"
module alu (
  logic_op_i,
  sub_i,
  arithlogic_i,
  slt_sel_i,
  opd1_i,
  opd2_i,
  result_o
);

input sub_i, arithlogic_i, slt_sel_i;
input [`LOGIC_OP_WIDTH-1:0] logic_op_i;
input [`DATA_WIDTH-1:0] opd1_i, opd2_i;
output [`DATA_WIDTH-1:0] result_o;

wire [`DATA_WIDTH-1:0] opd2_xor_sub;
wire [`DATA_WIDTH:0] sum;
wire [`DATA_WIDTH-1:0] arith_result;

reg  [`DATA_WIDTH-1:0] logic_result;

assign result_o = (arithlogic_i)? arith_result[`DATA_WIDTH-1:0]: logic_result[`DATA_WIDTH-1:0];
assign arith_result = (slt_sel_i)? {31'b0, sum[`DATA_WIDTH-1]}: sum[`DATA_WIDTH-1:0];
//assign sum = opd1_i[`DATA_WIDTH-1:0] + opd2_xor_sub[`DATA_WIDTH-1:0] + sub_i;
assign opd2_xor_sub = opd2_i ^ {`DATA_WIDTH{sub_i}};
cs32_adder u0 (
  .din1_i (opd1_i[`DATA_WIDTH-1:0]),
  .din2_i (opd2_xor_sub[`DATA_WIDTH-1:0]),
  .cin_i  (sub_i),
  .cout_o (sum[`DATA_WIDTH]),
  .sum_o  (sum[`DATA_WIDTH-1:0])
);

always@ (*) begin
  case (logic_op_i)
    `LOGIC_AND : logic_result = opd1_i[`DATA_WIDTH-1:0] & opd2_i[`DATA_WIDTH-1:0];
    `LOGIC_OR  : logic_result = opd1_i[`DATA_WIDTH-1:0] | opd2_i[`DATA_WIDTH-1:0];
    `LOGIC_XOR : logic_result = opd1_i[`DATA_WIDTH-1:0] ^ opd2_i[`DATA_WIDTH-1:0];
    `LOGIC_SLL : logic_result = opd1_i[`DATA_WIDTH-1:0] << opd2_i[`SHAMT_WIDTH-1:0];
    `LOGIC_SRL : logic_result = opd1_i[`DATA_WIDTH-1:0] >> opd2_i[`SHAMT_WIDTH-1:0];
    `LOGIC_SRA : logic_result = $signed(opd1_i[`DATA_WIDTH-1:0]) >>> opd2_i[`SHAMT_WIDTH-1:0];
    default    : logic_result = 32'hxxxxxxxx;
  endcase
end

endmodule
