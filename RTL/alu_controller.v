//`include "def.v" //command this line 
module alu_controller (
  alu_op_i, 
  logic_op_o,
  sub_o, 
  arithlogic_o
//  slt_sel_o	
);

input [`ALU_OP] alu_op_i;

output [`LOGIC_OP_WIDTH-1:0] logic_op_o;
output sub_o;
output arithlogic_o;
// output slt_sel_o;

reg [`LOGIC_OP_WIDTH-1:0] logic_op_o;

parameter Arithmetic = 1'b1,	//ADD, SUB
	  Logic	     = 1'b0;	//AND, OR, XOR, SLL, SRL, SRA

assign sub_o = alu_op_i[0];
assign arithlogic_o = ( alu_op_i[`ALU_OP_WIDTH-1:1] == 2'b00 )? Arithmetic: Logic;
// assign slt_sel_o = alu_op_i[0] & ~alu_op_i[`ALU_OP_WIDTH-1] & ~alu_op_i[`ALU_BRN];

always@(*) begin
  case(alu_op_i) 
    `ALU_OP_AND : logic_op_o = `LOGIC_AND;
    `ALU_OP_OR  : logic_op_o = `LOGIC_OR;
    `ALU_OP_XOR : logic_op_o = `LOGIC_XOR;
    `ALU_OP_SLL : logic_op_o = `LOGIC_SLL;
    `ALU_OP_SRL : logic_op_o = `LOGIC_SRL;
    `ALU_OP_SRA : logic_op_o = `LOGIC_SRA;		
    default     : logic_op_o = 3'bxxx;
  endcase
end

endmodule
