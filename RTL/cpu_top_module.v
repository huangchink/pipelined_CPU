`timescale 1ns/1ps
`include "def.v"
`include "pc.v"
`include "reg_file.v"
`include "branch_checker.v"
`include "bit_extension.v"
`include "hazard_detection_unit.v"
`include "controller.v"
`include "forwarding_unit.v"
`include "alu_controller.v"
`include "alu.v"
`include "if_id_reg.v"
`include "id_ex_reg.v"
`include "ex_mem_reg.v"
`include "mem_wb_reg.v"

module cpu_top_module (
  input  wire clk_i,
  input  wire rst_ni,

  // ports connected to system bus to instruction memory (ROM)
  // for reading
  input  wire [`DATA_WIDTH-1:0]     ins_mem_read_data_i,
  output wire [`MEM_ADDR_WIDTH-1:0] ins_mem_addr_o,

  // ports connected to system bus to data memory
  // for reading
  input  wire [`DATA_WIDTH-1:0]     data_mem_read_data_i,
  output wire                       data_mem_read_o,
  // for writing
  output wire [`DATA_WIDTH-1:0]     data_mem_write_data_o,
  output wire                       data_mem_write_o,
  output wire [`MEM_ADDR_WIDTH-1:0] data_mem_addr_o
);

  // IF stage wires
  wire [`DATA_WIDTH-1:0]     ins_if;
  wire [`MEM_ADDR_WIDTH-1:0] ins_addr_plus1_if;
  wire [`MEM_ADDR_WIDTH-1:0] ins_addr;
  wire [`MEM_ADDR_WIDTH-1:0] ins_addr_next;

  // ID stage wires
  wire [`DATA_WIDTH-1:0]     ins_id;
  wire [`MEM_ADDR_WIDTH-1:0] ins_addr_plus1_id, branch_addr_id;
  wire [`DATA_WIDTH-1:0]     extended_id;
  wire [`DATA_WIDTH-1:0]     data1_id, data2_id;
  wire [`EX_CTRL_WIDTH-1:0]  ex_ctrl_id;
  wire [`MEM_CTRL_WIDTH-1:0] mem_ctrl_id;
  wire [`WB_CTRL_WIDTH-1:0]  wb_ctrl_id;
  wire [`DATA_WIDTH-1:0]     diff;
  wire branch_id, branch_taken_id, untrusted_branch_taken_id;
  wire flush_pipeline;  // for flush

  // EX stage wires
  wire [`DATA_WIDTH-1:0]     extended_ex;  // extended data of imm, offset or shamt
  wire [`DATA_WIDTH-1:0]     data1_ex, data2_ex;
  wire [`DATA_WIDTH-1:0]     src_ex, result_ex;
  wire [`DATA_WIDTH-1:0]     opd1, opd2;
  wire [`REG_ADDR_WIDTH-1:0] rs1_ex, rs2_ex, rd_ex;
  wire [`EX_CTRL_WIDTH-1:0]  ex_ctrl_ex;
  wire [`MEM_CTRL_WIDTH-1:0] mem_ctrl_ex;
  wire [`WB_CTRL_WIDTH-1:0]  wb_ctrl_ex;
  wire [`MEM_ADDR_WIDTH-1:0] branch_addr_ex;
  wire [`FUNCT3_WIDTH-1:0]   funct3_ex;
  wire [`ALU_OP_WIDTH-1:0]   alu_op;        // pipelined control signals
  wire alu_src, mem_read_ex, reg_write_ex, alu_slt;  // pipelined control signals
  wire branch_ex, branch_taken_ex;

  // MEM stage wires
  wire [`DATA_WIDTH-1:0]     src_mem, result_mem;
  wire [`DATA_WIDTH-1:0]     read_data_mem;
  wire [`REG_ADDR_WIDTH-1:0] rd_mem;
  wire [`MEM_CTRL_WIDTH-1:0] mem_ctrl_mem;
  wire [`WB_CTRL_WIDTH-1:0]  wb_ctrl_mem;
  wire mem_read_mem, mem_write_mem, reg_write_mem;  // pipeined control signals

  // WB stage wires
  wire [`DATA_WIDTH-1:0]     result_wb;
  wire [`DATA_WIDTH-1:0]     read_data_wb;
  wire [`DATA_WIDTH-1:0]     wb_data;
  wire [`REG_ADDR_WIDTH-1:0] rd_wb;
  wire [`WB_CTRL_WIDTH-1:0]  wb_ctrl_wb;
  wire reg_write_wb, mem2reg;  // pipelined control signals

  // alu controller output wires
  wire [`LOGIC_OP_WIDTH-1:0] logic_op;
  wire sub, arithlogic;

  // hazard detection unit output wires
  wire pc_keep;
  wire if_id_keep;
  wire id_ex_zero;
  wire trust;

  // controller output wires
  wire [`EX_CTRL_WIDTH-1:0]  ex_ctrl;
  wire [`MEM_CTRL_WIDTH-1:0] mem_ctrl;
  wire [`WB_CTRL_WIDTH-1:0]  wb_ctrl;
  wire [1:0]                 imm_sel;
  wire if_flush, id_flush, ex_flush;
  wire branch_c;

  // forwarding unit outputs wires
  wire [1:0] forwardingA, forwardingB;

  /**
   * :: global control units ::
   */
  hazard_detection_unit hazard_detection_unit (
    .id_rs1_i       (ins_id[`RS1]),
    .id_rs2_i       (ins_id[`RS2]),
    .ex_rd_i        (rd_ex),
    .mem_rd_i       (rd_mem),
    .ex_mem_read_i  (mem_read_ex),
    .ex_reg_write_i (reg_write_ex),
    .mem_reg_write_i(reg_write_mem),

    .pc_keep_o      (pc_keep),     // keep the data when high
    .if_id_keep_o   (if_id_keep),  // keep the data when high
    .id_ex_zero_o   (id_ex_zero),  // choose 0 when high
    .trust_o        (trust)
  );

  controller controller (
    .opcode_i         (ins_id[`OPCODE]),
    .funct3_i         (ins_id[`FUNCT3]),
    .funct7_i         (ins_id[`FUNCT7]),

    .branch_taken_id_i(branch_taken_id),
    .branch_taken_ex_i(branch_taken_ex),

    .imm_sel_o        (imm_sel),

    // flush signals
    .if_flush_o       (if_flush),
    .id_flush_o       (id_flush),
    .ex_flush_o       (ex_flush),

    .branch_o         (branch_c),        // to determine if it is a branch ins

    // pipelined control signals
    .ex_ctrl_o        (ex_ctrl),
    .mem_ctrl_o       (mem_ctrl),
    .wb_ctrl_o        (wb_ctrl)
  );

  forwarding_unit forwarding_unit (
    .mem_rd_i       (rd_mem),
    .wb_rd_i        (rd_wb),
    .ex_rs1_i       (rs1_ex),         // from ex stage
    .ex_rs2_i       (rs2_ex),         // from ex stage
    .mem_reg_write_i(reg_write_mem),
    .wb_reg_write_i (reg_write_wb),
    .forwardingA_o  (forwardingA),    // to select opd1 for alu
    .forwardingB_o  (forwardingB)     // to select opd2 for alu
  );

  /**
   * :: IF stage ::
   */
  pc pc (
    // a clk_i triggered register that stores current instruction of if stage
    // and take the signal of ins_addr_next as the input of the register
    // the signal of ins_addr_next goes into the register
    // only when pc_keep is low (controllsed by hazard detection unit)
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),         // active low
    .pc_keep_i (pc_keep),        // from hazard detection unit

    .ins_addr_d(ins_addr_next),  // from internal mux
    .ins_addr_q(ins_addr)        // to ins_mem
  );

  // to communicate with the instruction memory via output ports
  assign ins_if         = ins_mem_read_data_i;
  assign ins_mem_addr_o = ins_addr;

  assign ins_addr_plus1_if = ins_addr + 32'd1;

  // the mux to select the next address
  assign ins_addr_next = ({branch_taken_id, branch_taken_ex} == 2'b00)? ins_addr_plus1_if:
                         ({branch_taken_id, branch_taken_ex} == 2'b01)? branch_addr_ex:
                         ({branch_taken_id, branch_taken_ex} == 2'b10)? branch_addr_id:branch_addr_ex;

  if_id_reg if_id_reg (
    // the clk triggered register between if stage and id stage
    // that passes addr_plus1 and ins to next stage
    // and the data will be kept for 1 cycle when if_id_keep
    // from the hazard detection unit is HIGH
    // and be reset when controller gives if_flush signal
    .clk_i           (clk_i),
    .rst_ni          (rst_ni),

    .if_id_keep_i    (if_id_keep),         // from hazard detection unit
    .if_flush_i      (if_flush),           // from controller

    // the address of the next instruction & the instruction itself
    .ins_addr_plus1_d(ins_addr_plus1_if),  // from internal adder
    .ins_d           (ins_if),             // from ins_mem

    .ins_addr_plus1_q(ins_addr_plus1_id),
    .ins_q           (ins_id)              // the instruction is determined here
  );

  /**
   * :: ID stage ::
   */
  reg_file reg_file (
    // literally the register file
    // for reading data from it
    // data1_id will be given by the data in the entry of read_reg1
    // data2_id will be given by the data in the entry of read_reg2
    // for writing data to it
    // as clk_i comes, write_data goes into the entries of
    // write_reg when reg_write_wb is HIGH
    .clk_i       (clk_i),
    .rst_ni      (rst_ni),

    // read from register
    .read_reg1_i (ins_id[`RS1]),  // from instruction
    .read_reg2_i (ins_id[`RS2]),  // from instruction
    .data1_q     (data1_id),      // data in source register 1
    .data2_q     (data2_id),      // data in source register 2

    // write to register
    .reg_write_i (reg_write_wb),  // enable write
    .write_reg_i (rd_wb),         // address of destination register
    .write_data_d(wb_data)        // from wb stage (instruction)
  );

  bit_extension bit_extension (
    // combinational ckt for bit extension
    // that takes the unextended data as input,
    // calculates the signed (for imm & offset)
    // or unsigned extended value (for shamt)
    // and decides which one to output based on
    // imm_sel signal (controlled by controller)
    // 0 for imm; 1 for offset; 2 for shamt
    .imm_i     (ins_id[`IMM]),
    .shamt_i   (ins_id[`SHAMT]),
    .offset_i  ({ins_id[`OFFSET_H], ins_id[`OFFSET_L]}),
    .imm_sel_i (imm_sel),
    .extended_o(extended_id)
  );

  // adder that calculates the differance of two data
  assign diff = data1_id - data2_id;

  branch_checker id_branch (
    // ID stage branch condition checker
    // that exams the result of the comparison
    // and determine if branch is taken
    .branch_i      (branch_c),  // from controller output
    .funct3_i      (ins_id[`FUNCT3]),
    .diff_i        (diff),
    .branch_taken_o(untrusted_branch_taken_id)  // the result is untrusted
  );

  // confirmation from hazard detection unit
  assign branch_taken_id = untrusted_branch_taken_id & trust;

  // adder that calculates the branch address
  assign branch_addr_id = ins_addr_plus1_id + extended_id;

  // muxes to choose pipelined control signal or bubble
  assign flush_pipeline = (id_flush | id_ex_zero);
  assign ex_ctrl_id     = (flush_pipeline)? `EX_CTRL_WIDTH'd0 :ex_ctrl;
  assign mem_ctrl_id    = (flush_pipeline)? `MEM_CTRL_WIDTH'd0:mem_ctrl;
  assign wb_ctrl_id     = (flush_pipeline)? `WB_CTRL_WIDTH'd0 :wb_ctrl;
  assign branch_id      = ((trust & branch_c) | flush_pipeline)? 1'b0:branch_c;

  id_ex_reg id_ex_reg (
    // the clk_i triggered register between ID stage and EX stage
    // that passes various pipelined control signals
    // and partitions of instruction decoded at ID stage
    // to the next stage
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),

    // pipelined control signals
    .wb_ctrl_d    (wb_ctrl_id),
    .mem_ctrl_d   (mem_ctrl_id),
    .ex_ctrl_d    (ex_ctrl_id),

    .wb_ctrl_q    (wb_ctrl_ex),
    .mem_ctrl_q   (mem_ctrl_ex),
    .ex_ctrl_q    (ex_ctrl_ex),

    // decoded data & partitions of instruction
    .data1_d      (data1_id),
    .data2_d      (data2_id),
    .extended_d   (extended_id),
    .rs1_d        (ins_id[`RS1]),
    .rs2_d        (ins_id[`RS2]),
    .rd_d         (ins_id[`RD]),
    .funct3_d     (ins_id[`FUNCT3]),
    .branch_addr_d(branch_addr_id),
    .branch_d     (branch_id),

    .data1_q      (data1_ex),
    .data2_q      (data2_ex),
    .extended_q   (extended_ex),
    .rs1_q        (rs1_ex),
    .rs2_q        (rs2_ex),
    .rd_q         (rd_ex),
    .funct3_q     (funct3_ex),
    .branch_addr_q(branch_addr_ex),
    .branch_q     (branch_ex)
  );

  /**
   * :: EX stage ::
   */
  // extract EX stage control signals from the pipelined control signals
  assign alu_src = ex_ctrl_ex[`ALU_SRC];
  assign alu_slt = ex_ctrl_ex[`ALU_SLT];
  assign alu_op  = ex_ctrl_ex[`ALU_OP];

  // extract MEM stage control signals from the pipelined control signals
  assign mem_read_ex = mem_ctrl_ex[`MEM_READ];
  // extract WB stage control signals from the pipelined control signals
  assign reg_write_ex = wb_ctrl_ex[`REG_WRITE];

  // muxes that select the operand feed into alu
  assign opd1   = (forwardingA == 2'b00)? data1_ex:
                  (forwardingA == 2'b01)? wb_data:
                  (forwardingA == 2'b10)? result_mem: `DATA_WIDTH'd0;
  assign src_ex = (forwardingB == 2'b00)? data2_ex:
                  (forwardingB == 2'b01)? wb_data:
                  (forwardingB == 2'b10)? result_mem: `DATA_WIDTH'd0;
  assign opd2   = (alu_src)? extended_ex:src_ex;  // (imm / shamt):(reg type)

  alu_controller alu_controller (
    // alu opertion from controller for alu_controller to decode
    .alu_op_i    (alu_op),

    // all control signals to alu
    .logic_op_o  (logic_op),
    .sub_o       (sub),
    .arithlogic_o(arithlogic)
  );

  alu alu (
    // control signals decoded from alu_controller
    .logic_op_i  (logic_op),
    .sub_i       (sub),
    .arithlogic_i(arithlogic),
    .slt_sel_i   (alu_slt),

    // operands
    .opd1_i      (opd1),
    .opd2_i      (opd2),

    // the computation result
    .result_o    (result_ex)
  );

  branch_checker ex_branch (
    // EX stage branch condition checker
    // that exams the result of the comparison
    // and determine if branch is taken
    .branch_i      (branch_ex),
    .funct3_i      (funct3_ex),
    .diff_i        (result_ex),
    .branch_taken_o(branch_taken_ex)
  );

  ex_mem_reg ex_mem_reg (
    // the clk_i triggered register between EX stage and MEM stage
    // that passes remaining pipelined control signals
    // and the src or result from execution
    // to the next stage
    .clk_i       (clk_i),
    .rst_ni      (rst_ni),

    // pipelined control signals
    .wb_ctrl_d   ((ex_flush)? `WB_CTRL_WIDTH'd0:wb_ctrl_ex),
    .mem_ctrl_d  ((ex_flush)? `MEM_CTRL_WIDTH'd0:mem_ctrl_ex),

    .wb_ctrl_q   (wb_ctrl_mem),
    .mem_ctrl_q  (mem_ctrl_mem),

    // alu results & imm data
    .result_d    (result_ex),
    .src_d       (src_ex),
    .rd_d        (rd_ex),

    .result_q    (result_mem),
    .src_q       (src_mem),
    .rd_q        (rd_mem)
  );

  /**
   * :: MEM stage ::
   */
  // extract MEM stage control signals from pipelined control signals
  assign mem_read_mem  = mem_ctrl_mem[`MEM_READ];
  assign mem_write_mem = mem_ctrl_mem[`MEM_WRITE];

  // extract WB stage control signals from pipelined control signals
  assign reg_write_mem = wb_ctrl_mem[`REG_WRITE];

  // signals connected to output ports to talk to main memory
  // for reading
  assign read_data_mem   = data_mem_read_data_i;  // obtained data from data memory
  assign data_mem_addr_o = result_mem;
  // for writing
  assign data_mem_read_o       = mem_read_mem;
  assign data_mem_write_o      = mem_write_mem; // enable write siganl
  assign data_mem_write_data_o = src_mem;

  mem_wb_reg mem_wb_reg (
    // the clk_i triggered register between MEM stage and WB stage
    // that passes remaining pipelined control signals
    // and the result or mem data from memory access
    // to the next stage
    .clk_i       (clk_i),
    .rst_ni      (rst_ni),

    // pipelined control signals
    .wb_ctrl_d   (wb_ctrl_mem),

    .wb_ctrl_q   (wb_ctrl_wb),

    // alu results & mem read data
    .result_d    (result_mem),
    .read_data_d (read_data_mem),
    .rd_d        (rd_mem),

    .result_q    (result_wb),
    .read_data_q (read_data_wb),
    .rd_q        (rd_wb)
  );

  /**
   * :: WB stage ::
   */
  // extract WB stage control signals from pipelined control signals
  assign reg_write_wb = wb_ctrl_wb[`REG_WRITE];
  assign mem2reg      = wb_ctrl_wb[`MEM2REG];

  // mux to select the source for write back data (alu result or mem data)
  assign wb_data = (mem2reg)? read_data_wb:result_wb;
endmodule
