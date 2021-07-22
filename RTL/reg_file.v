`timescale 1ns/1ps
module reg_file (
  input clk_i,
  input rst_ni,

  // read from register
  input [`REG_ADDR_WIDTH - 1:0] read_reg1_i,    // from instruction
  input [`REG_ADDR_WIDTH - 1:0] read_reg2_i,    // from instruction
  output reg [`DATA_WIDTH - 1:0] data1_q,           // source register 1
  output reg [`DATA_WIDTH - 1:0] data2_q,           // source register 2

  // write to register
  input reg_write_i,                            // enable write
  input [`REG_ADDR_WIDTH - 1:0] write_reg_i,    // position
  input [`DATA_WIDTH - 1:0] write_data_d
);

reg [`DATA_WIDTH-1:0] r_file[`REG_SIZE - 1:0];
integer i;

always @ (posedge clk_i or negedge rst_ni) begin
  
  if (~rst_ni) begin
    r_file[0] <= 32'd0;
  end else begin
      // write condition
    r_file[write_reg_i] <= ((reg_write_i)? write_data_d : r_file[write_reg_i]);
  end
  
end


always @(*) begin
  data1_q = r_file[read_reg1_i];
  data2_q = r_file[read_reg2_i];
end

endmodule
