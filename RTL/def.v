// size specification (use the word "size" for number of entries)
`define MEM_SIZE (1<<`MEM_ADDR_WIDTH)
`define REG_SIZE 32

// bit width specification (use the word "width" for number of bit)
`define DATA_WIDTH     32  // 32 bit ISA
`define MEM_ADDR_WIDTH 32  // there are 2^16 (65536) entries of memory
`define REG_ADDR_WIDTH 5   // there are 2^5 (32) entries of register
`define OPCODE_WIDTH   7
`define FUNCT3_WIDTH   3
`define FUNCT7_WIDTH   7
`define IMM_WIDTH      12
`define OFFSET_WIDTH   12
`define OFFSET_H_WIDTH 7
`define OFFSET_L_WIDTH 5
`define SHAMT_WIDTH    5
`define EX_CTRL_WIDTH  5
`define MEM_CTRL_WIDTH 2
`define WB_CTRL_WIDTH  2
`define ALU_OP_WIDTH   3
`define LOGIC_OP_WIDTH 3

// partitions of data
`define MSB 31
`define LSB 0

// partitions of instruction
`define OPCODE   6:0
`define RD       11:7
`define RS1      19:15
`define RS2      24:20
`define FUNCT3   14:12
`define FUNCT7   31:25
`define IMM      31:20
`define OFFSET_H 31:25
`define OFFSET_L 11:7
`define SHAMT    24:20

// adder32 control signals definitions
`define ADDER32_ADD 1'b0
`define ADDER32_SUB 1'b1

// opcode definitions
`define OP_IMM 7'b0000000
`define OP_REG 7'b0000001
`define OP_BRN 7'b0000010
`define OP_LW  7'b1000000
`define OP_SW  7'b1000001

// I-type funct3 definitions
`define FUNCT3_ADDI 3'b000
`define FUNCT3_SLTI 3'b001
`define FUNCT3_ANDI 3'b100
`define FUNCT3_ORI  3'b101
`define FUNCT3_XORI 3'b110
`define FUNCT3_SLLI 3'b010
`define FUNCT3_SRLI 3'b011
`define FUNCT3_SRAI 3'b011

// R-type funct3 definitions
`define FUNCT3_ADD 3'b000
`define FUNCT3_SLT 3'b001
`define FUNCT3_AND 3'b100
`define FUNCT3_OR  3'b101
`define FUNCT3_XOR 3'b110
`define FUNCT3_SLL 3'b010
`define FUNCT3_SRL 3'b011
`define FUNCT3_SUB 3'b001
`define FUNCT3_SRA 3'b011

// Branch funct3 definitions
`define FUNCT3_BEQ 3'b111
`define FUNCT3_BNE 3'b101
`define FUNCT3_BLT 3'b001
`define FUNCT3_BGE 3'b011

// ALU_OP definitions
`define ALU_OP_ADD 3'b000
`define ALU_OP_SUB 3'b001
`define ALU_OP_AND 3'b100
`define ALU_OP_OR  3'b101
`define ALU_OP_XOR 3'b110
`define ALU_OP_SLL 3'b010
`define ALU_OP_SRL 3'b011
`define ALU_OP_SRA 3'b111

// LOGIC_OP definitions
`define LOGIC_AND 3'b000
`define LOGIC_OR  3'b001
`define LOGIC_XOR 3'b010
`define LOGIC_SLL 3'b011
`define LOGIC_SRL 3'b100
`define LOGIC_SRA 3'b101

// Memory access funct3 definitions
`define FUNCT3_LW 3'b000
`define FUNCT3_SW 3'b000

// funct7 definitions
`define FUNCT7_TYPE0 7'b0000000
`define FUNCT7_TYPE1 7'b0100000

// partitions of pipelined ex control signal
`define ALU_SRC 4
`define ALU_SLT 3
`define ALU_OP  2:0

// partitions of pipelined mem control siganl
`define MEM_READ  1
`define MEM_WRITE 0

// partitions of pipelined wb control signal
`define REG_WRITE 1
`define MEM2REG   0
