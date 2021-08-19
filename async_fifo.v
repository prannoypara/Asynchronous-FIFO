`timescale 1ns / 1ps


module async_fifo(data_out, wr_full, rd_empty,
rd_clk, wr_clk, reset);

parameter WIDTH = 8;
parameter POINTER = 4; //pointer has 4 bits, represents fifo depth is 16.
input rd_clk, wr_clk, reset;

output [WIDTH-1 : 0] data_out;
output wr_full, rd_empty;

wire [WIDTH-1 : 0] data_in; //why wire why not as an input? bcoz data_in is a wire between the transmitter 'SEND' and the FIFO.


reg [POINTER : 0] rd_pointer, rd_sync_1, rd_sync_2; //5-bit
reg [POINTER : 0] wr_pointer, wr_sync_1, wr_sync_2;
wire [POINTER:0] rd_pointer_g,wr_pointer_g;   // grey code read & write pointers.
wire [POINTER : 0] rd_pointer_sync;
wire [POINTER: 0] wr_pointer_sync;

parameter DEPTH = 1 << POINTER; ///i.e., 2^4 = 16 i.e., 10000.

reg [WIDTH-1 : 0] memory [DEPTH-1 : 0]; // [7:0]memory[15:0] means you have 8 bits wide, 16 blocks.


reg full,empty; //full =1 if fifo is full. these are later into wr_full, rd_empty
reg [7:0] tr_ptr; //why 8 bit????

//--write logic--//

always @(posedge wr_clk or posedge reset) begin
if (reset) begin
wr_pointer <= 0;
tr_ptr<=0;
end
else if (full == 1'b0) begin
wr_pointer <= wr_pointer + 1;
tr_ptr<=tr_ptr+1;
memory[wr_pointer[POINTER-1 : 0]] <= data_in; //this data_in comes transmitter 'SEND'
end
end

SEND s(tr_ptr,data_in); //tr_ptr and wr_pointer will always point to same value.

//--read pointer synchronizer controlled by write clock--//

always @(posedge wr_clk) begin
rd_sync_1 <= rd_pointer_g; //wire [POINTER:0] rd_pointer_g; it's grey code read pointer
rd_sync_2 <= rd_sync_1;
end

//--read logic--//

always @(posedge rd_clk or posedge reset) begin
if (reset) begin
rd_pointer <= 0;
end
else if (empty == 1'b0) begin
rd_pointer <= rd_pointer + 1;
end
end

//--write pointer synchronizer controlled by read clock--//

always @(posedge rd_clk) begin
wr_sync_1 <= wr_pointer_g; //wire [POINTER:0] wr_pointer_g; 
wr_sync_2 <= wr_sync_1;
end

//setting up the full flags
always @(*)
begin
if({~wr_pointer[POINTER],wr_pointer[POINTER-1:0]}==rd_pointer_sync) //wire [POINTER : 0] rd_pointer_sync;
full = 1;
else
full = 0;
end

//setting up the empty flags
always @(*)
begin
if(wr_pointer_sync==rd_pointer) //wire [POINTER: 0] wr_pointer_sync;
empty = 1;
else
empty = 0;
end

assign data_out = memory[rd_pointer[POINTER-1 : 0]];


//--binary code to gray code--//

assign wr_pointer_g = wr_pointer ^ (wr_pointer >> 1); //1011 in binary is 1110 in gray
assign rd_pointer_g = rd_pointer ^ (rd_pointer >> 1);

//--gray code to binary code--//

assign wr_pointer_sync[4]=wr_sync_2[4];   //doesn't these all run concurrent??
assign wr_pointer_sync[3]=wr_sync_2[3] ^ wr_pointer_sync[4];
assign wr_pointer_sync[2]=wr_sync_2[2] ^ wr_pointer_sync[3];
assign wr_pointer_sync[1]=wr_sync_2[1] ^ wr_pointer_sync[2];
assign wr_pointer_sync[0]=wr_sync_2[0] ^ wr_pointer_sync[1];


assign rd_pointer_sync[4]=rd_sync_2[4];
assign rd_pointer_sync[3]=rd_sync_2[3] ^ rd_pointer_sync[4];
assign rd_pointer_sync[2]=rd_sync_2[2] ^ rd_pointer_sync[3];
assign rd_pointer_sync[1]=rd_sync_2[1] ^ rd_pointer_sync[2];
assign rd_pointer_sync[0]=rd_sync_2[0] ^ rd_pointer_sync[1];

assign wr_full = full;
assign rd_empty = empty;

endmodule



module SEND(wr_ptr,data_out);

output [7:0] data_out;
input [7:0] wr_ptr;
reg [7:0] input_rom [255:0];
integer i;
initial begin

for(i=0;i<255;i=i+1)
input_rom[i] = i+10;
end

assign data_out = input_rom[wr_ptr];

endmodule