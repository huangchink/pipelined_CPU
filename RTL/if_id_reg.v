`timescale 1ns/1ps
module if_id_reg (
  input clk_i,
  input rst_ni,
  input if_id_keep_i,  // from hazard detection unit
  input if_flush_i,     // from controller
  
  input      [`DATA_WIDTH-1:0] ins_addr_plus1_d,   // from internal adder
  output reg [`DATA_WIDTH-1:0] ins_addr_plus1_q,

  input      [`DATA_WIDTH-1:0] ins_d,  // from ins_mem
  output reg [`DATA_WIDTH-1:0] ins_q   // the instruction is determined here
);

always @ (negedge clk_i or negedge rst_ni) begin
  
  if (~rst_ni) begin
    ins_addr_plus1_q <= 32'd0;
    ins_q <= 32'd0; // stall
  end else begin
    if (if_id_keep_i) begin
      // hazard, value set to zero, address remains 
      ins_addr_plus1_q <= ins_addr_plus1_q;
      ins_q <= ins_q;
    end else if (if_flush_i) begin
      // flush, all set to zero
      ins_addr_plus1_q <= 32'd0;
      ins_q <= 32'd0; 
    end else begin
      // ins = ins + 1
      ins_addr_plus1_q <= ins_addr_plus1_d;
      ins_q <= ins_d;
    end
  end

end

endmodule
