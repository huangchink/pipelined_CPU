//`include "def.v"
`timescale 1ns/1ps
module controller (
  input [`OPCODE_WIDTH-1:0] opcode_i,
  input [`FUNCT3_WIDTH-1:0] funct3_i,
  input [`FUNCT7_WIDTH-1:0] funct7_i,

  // ID stage branch condition peek
  input branch_taken_id_i,
  input branch_taken_ex_i,

  output reg [1:0] imm_sel_o,

  // flush signals
  output if_flush_o,
  output id_flush_o,
  output ex_flush_o,

  output branch_o,

  // pipelined control signals
  output reg [`EX_CTRL_WIDTH-1:0]  ex_ctrl_o,
  output reg [`MEM_CTRL_WIDTH-1:0] mem_ctrl_o,
  output reg [`WB_CTRL_WIDTH-1:0]  wb_ctrl_o
);

assign if_flush_o = branch_taken_id_i | branch_taken_ex_i;
assign id_flush_o = branch_taken_ex_i | branch_taken_id_i;
assign ex_flush_o = 1'b0;

assign branch_o = (opcode_i == `OP_BRN);

always @(*) begin : immediate_data_selecting
  case (opcode_i)
    `OP_IMM: begin
      if (funct3_i == `FUNCT3_SLLI ||
          funct3_i == `FUNCT3_SRLI ||
          funct3_i == `FUNCT3_SRAI) begin
        // shift-type immediate instructions
        imm_sel_o = 2'b01;
      end else begin
        // other immediate instructions
        imm_sel_o = 2'b00;
      end
    end
    `OP_BRN: begin
      imm_sel_o = 2'b10;
    end
    `OP_LW: begin
      imm_sel_o = 2'b00;
    end
    `OP_SW: begin
      imm_sel_o = 2'b10;
    end
    default: imm_sel_o = 2'bxx;
  endcase
end

always @(*) begin : slt_signals
  ex_ctrl_o[`ALU_SLT] = (opcode_i == `OP_IMM)? (funct3_i == `FUNCT3_SLTI):
                        (opcode_i == `OP_REG)? (funct3_i == `FUNCT3_SLT && funct7_i == `FUNCT7_TYPE0): 1'b0;
end

always @(*) begin : ex_pipelined_control_signals
  case (opcode_i)
    `OP_REG: begin
      ex_ctrl_o[`ALU_SRC] = 1'b0;  // choose reg-type data
      if (funct7_i == `FUNCT7_TYPE0) begin
        case (funct3_i)
          `FUNCT3_ADD: ex_ctrl_o[`ALU_OP] = `ALU_OP_ADD;
          `FUNCT3_SLT: ex_ctrl_o[`ALU_OP] = `ALU_OP_SUB;
          `FUNCT3_AND: ex_ctrl_o[`ALU_OP] = `ALU_OP_AND;
          `FUNCT3_OR:  ex_ctrl_o[`ALU_OP] = `ALU_OP_OR;
          `FUNCT3_XOR: ex_ctrl_o[`ALU_OP] = `ALU_OP_XOR;
          `FUNCT3_SLL: ex_ctrl_o[`ALU_OP] = `ALU_OP_SLL;
          `FUNCT3_SRL: ex_ctrl_o[`ALU_OP] = `ALU_OP_SRL;
          default:     ex_ctrl_o[`ALU_OP] = `ALU_OP_WIDTH'bxxx;
        endcase
      end else if (funct7_i == `FUNCT7_TYPE1) begin
        case (funct3_i)
          `FUNCT3_SUB: ex_ctrl_o[`ALU_OP] = `ALU_OP_SUB;
          `FUNCT3_SRA: ex_ctrl_o[`ALU_OP] = `ALU_OP_SRA;
          default:     ex_ctrl_o[`ALU_OP] = `ALU_OP_WIDTH'bxxx;
        endcase
      end else begin
          ex_ctrl_o[`ALU_OP] = `ALU_OP_WIDTH'd0;
      end
    end
    `OP_BRN: begin
      ex_ctrl_o[`ALU_SRC] = 1'b0;
      ex_ctrl_o[`ALU_OP] = `ALU_OP_SUB;
    end
    `OP_IMM: begin
      ex_ctrl_o[`ALU_SRC] = 1'b1;  // choose imm-type data
      case (funct3_i)
        `FUNCT3_ADDI: ex_ctrl_o[`ALU_OP] = `ALU_OP_ADD;
        `FUNCT3_SLTI: ex_ctrl_o[`ALU_OP] = `ALU_OP_SUB;
        `FUNCT3_ANDI: ex_ctrl_o[`ALU_OP] = `ALU_OP_AND;
        `FUNCT3_ORI:  ex_ctrl_o[`ALU_OP] = `ALU_OP_OR;
        `FUNCT3_XORI: ex_ctrl_o[`ALU_OP] = `ALU_OP_XOR;
        `FUNCT3_SLLI: ex_ctrl_o[`ALU_OP] = `ALU_OP_SLL;
        default: begin
          if (funct7_i == `FUNCT7_TYPE0 && funct3_i == `FUNCT3_SRLI) begin
            ex_ctrl_o[`ALU_OP] = `ALU_OP_SRL;
          end else if (funct7_i == `FUNCT7_TYPE1 && funct3_i == `FUNCT3_SRAI) begin
            ex_ctrl_o[`ALU_OP] = `ALU_OP_SRA;
          end else begin
            ex_ctrl_o[`ALU_OP] = `ALU_OP_WIDTH'bxxx;
          end
        end
      endcase
    end
    `OP_LW:  begin
      ex_ctrl_o[`ALU_SRC] = 1'b1;
      ex_ctrl_o[`ALU_OP] = `ALU_OP_ADD;
    end
    `OP_SW:  begin
      ex_ctrl_o[`ALU_SRC] = 1'b1;
      ex_ctrl_o[`ALU_OP] = `ALU_OP_ADD;
    end
    default: begin
      ex_ctrl_o[`ALU_SRC] = 1'bx;
      ex_ctrl_o[`ALU_OP] = `ALU_OP_WIDTH'bxxx;
    end
  endcase
end

always @(*) begin : mem_pipelined_control_signals
  mem_ctrl_o[`MEM_WRITE] = opcode_i == `OP_SW;
  mem_ctrl_o[`MEM_READ]  = opcode_i == `OP_LW;
end

always @(*) begin : wb_pipelined_control_signals
  wb_ctrl_o[`REG_WRITE] = (opcode_i == `OP_IMM) |
                          (opcode_i == `OP_REG) |
                          (opcode_i == `OP_LW);
  wb_ctrl_o[`MEM2REG]   = opcode_i == `OP_LW;
end

endmodule
