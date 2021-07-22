`timescale 1ns/1ps
`include "def.v"
module data_mem (clk_phase1_i,mem_read_i,mem_write_i,data_addr_i,write_data_i,read_data_q);

parameter memory_start=32'h0000_0000;//recieve 32 bits but we only need 16 bit mem address
parameter memory_end  =32'h0000_ffff;
parameter data_address  =16;


input                              clk_phase1_i,mem_read_i,mem_write_i;
input      [`MEM_ADDR_WIDTH-1:0]   data_addr_i; // address bus
input      [`DATA_WIDTH-1:0]       write_data_i; // input data bus
output reg [`DATA_WIDTH-1:0]       read_data_q; // output data bus
// Define RAM as a register array
reg        [`DATA_WIDTH-1:0] data_memory[memory_start:memory_end];


// Read Cycle
always@(*)
begin

if(mem_read_i)
read_data_q=data_memory[data_addr_i[data_address-1:0]];
else begin
read_data_q=32'bz;
end


end




// Write cycle
always @(posedge clk_phase1_i)
begin
if(mem_write_i)begin
data_memory[data_addr_i[data_address-1:0]] <=write_data_i;
end

else
data_memory[data_addr_i[data_address-1:0]] <=data_memory[data_addr_i[data_address-1:0]];

end

endmodule
