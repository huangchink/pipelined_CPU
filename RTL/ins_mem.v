`timescale 1ns/1ps
`include "def.v"
module ins_mem (clk_phase1_i,data_addr_i,read_data_q);

parameter memory_start=32'h0000_0000;//recieve 32 bits but we only need 16 bit mem address
parameter memory_end  =32'h0000_ffff;
parameter data_address  =16;


input                              clk_phase1_i;
input      [`MEM_ADDR_WIDTH-1:0]   data_addr_i; // address bus
output reg [`DATA_WIDTH-1:0]       read_data_q; // output data bus
// Define ROM as a register array
reg        [`DATA_WIDTH-1:0] ins_memory[memory_start:memory_end];


// Read Cycle
always@(*)
begin
read_data_q=ins_memory[data_addr_i[data_address-1:0]];
end



endmodule
