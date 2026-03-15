`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 13:01:23
// Design Name: 
// Module Name: fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module fifo_tb;

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 4;

reg wr_clk = 0;
reg rd_clk = 0;
reg rst;

reg wr_en;
reg rd_en;

reg [DATA_WIDTH-1:0] din;
wire [DATA_WIDTH-1:0] dout;

wire full;
wire empty;

fifo_top #(DATA_WIDTH,ADDR_WIDTH) DUT (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty)
);

always #5 wr_clk = ~wr_clk;     // 100 MHz
always #7 rd_clk = ~rd_clk;     // different clock

integer i;

initial begin

rst = 1;
wr_en = 0;
rd_en = 0;

#20 rst = 0;

for(i=0;i<10;i=i+1)
begin
    @(posedge wr_clk);
    wr_en = 1;
    din = i;
end

wr_en = 0;

#50;

for(i=0;i<10;i=i+1)
begin
    @(posedge rd_clk);
    rd_en = 1;
end

rd_en = 0;

#100 $finish;

end

endmodule
