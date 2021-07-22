`include "ins_mem.v"
`include "data_mem.v"

`ifdef syn
`include "cpu_top_module_syn.v"
`include "tsmc18.v"
`else
`include "cpu_top_module.v"
`endif

`timescale 1ns/1ps

module cpu_tb;

  reg  clk;
  reg  rst_n;
  wire [`DATA_WIDTH-1:0]     ins_mem_read_data;
  wire [`DATA_WIDTH-1:0]     data_mem_read_data;

  wire [`MEM_ADDR_WIDTH-1:0] ins_mem_addr;
  wire                       data_mem_read;
  wire [`DATA_WIDTH-1:0]     data_mem_write_data;
  wire                       data_mem_write;
  wire [`MEM_ADDR_WIDTH-1:0] data_mem_addr;

  parameter HalfPeriod = 15;

  cpu_top_module cpu (
    .clk_i                (clk),
    .rst_ni               (rst_n),

    .ins_mem_read_data_i  (ins_mem_read_data),
    .ins_mem_addr_o       (ins_mem_addr),

    .data_mem_read_data_i (data_mem_read_data),
    .data_mem_read_o      (data_mem_read),
    .data_mem_write_data_o(data_mem_write_data),
    .data_mem_write_o     (data_mem_write),
    .data_mem_addr_o      (data_mem_addr)
  );

  ins_mem ins_mem (
    .clk_phase1_i(clk),
    .data_addr_i (ins_mem_addr),
    .read_data_q (ins_mem_read_data)
  );

  data_mem data_mem (
    .clk_phase1_i(clk),
    .mem_read_i  (data_mem_read),
    .mem_write_i (data_mem_write),
    .data_addr_i (data_mem_addr),
    .write_data_i(data_mem_write_data),
    .read_data_q (data_mem_read_data)
  );

  initial begin		
   $readmemb("sisc.prog", ins_mem.ins_memory);
  end

  initial begin
    clk = 0;
    rst_n = 0;
    #(8.7*HalfPeriod);
    rst_n = 1;
    #50000
    $finish;

  end
	
	`ifdef syn
		initial $sdf_annotate("cpu_top_module_syn.sdf", cpu);
	`endif
	
  initial begin
    $fsdbDumpfile("cpu.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA;
  end
  always begin
    #HalfPeriod clk = ~clk;
  end

 endmodule
