//`include "def.v"
`timescale 1ns/1ps
module branch_checker (
  input                      branch_i,
  input  [`FUNCT3_WIDTH-1:0] funct3_i,
  input  [`DATA_WIDTH-1:0]   diff_i,
  output reg                 branch_taken_o
);

  wire not_equal     = |diff_i;
  wire equal         = ~not_equal;
  wire less_than     = diff_i[`MSB];
  wire greater_equal = ~less_than;

  always @(*) begin
    if (branch_i) begin
      case (funct3_i)
        `FUNCT3_BEQ: branch_taken_o = equal;
        `FUNCT3_BNE: branch_taken_o = not_equal;
        `FUNCT3_BLT: branch_taken_o = less_than;
        `FUNCT3_BGE: branch_taken_o = greater_equal;
        default: branch_taken_o = 1'bx;
      endcase
    end else begin
      branch_taken_o = 1'b0;
    end
  end
endmodule
