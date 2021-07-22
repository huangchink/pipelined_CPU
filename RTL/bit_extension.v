`timescale 1ns/1ps
module bit_extension (
  input  [`IMM_WIDTH-1:0] imm_i,
  input  [`SHAMT_WIDTH-1:0] shamt_i,
  input  [`OFFSET_WIDTH-1:0] offset_i,
  input  [1:0] imm_sel_i,
  output [`DATA_WIDTH - 1:0] extended_o
);

reg [`DATA_WIDTH - 1:0] sht_extend, off_extend, imm_extend; // function code concatenate with op code

always @ (*) begin
  imm_extend = signed_extend(imm_i);
  sht_extend = unsinged_extend(shamt_i);
  off_extend = signed_extend(offset_i);
end

assign extended_o = (imm_sel_i == 2'd0)? imm_extend:
                    (imm_sel_i == 2'd1)? sht_extend:
                    (imm_sel_i == 2'd2)? off_extend: 32'd0;

function [`DATA_WIDTH - 1:0] unsinged_extend;
  input [4:0] shamt;
  begin
      unsinged_extend[`DATA_WIDTH - 1:0] = { {(`DATA_WIDTH-`SHAMT_WIDTH){1'b0}}, shamt[`SHAMT_WIDTH - 1:0]};
  end
endfunction

function [`DATA_WIDTH - 1:0] signed_extend;
  input [11:0] to_extend;
  begin
      signed_extend[`DATA_WIDTH - 1:0] = { {(`DATA_WIDTH-`IMM_WIDTH){to_extend[`IMM_WIDTH - 1]}}, to_extend[`IMM_WIDTH - 1:0]};
  end
endfunction

endmodule
