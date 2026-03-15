`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 12:59:25
// Design Name: 
// Module Name: fifo_top
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


module fifo_top #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wr_clk,
    input rd_clk,
    input rst,

    input wr_en,
    input rd_en,

    input [DATA_WIDTH-1:0] din,
    output [DATA_WIDTH-1:0] dout,

    output full,
    output empty
);

wire [ADDR_WIDTH:0] wptr_bin;
wire [ADDR_WIDTH:0] rptr_bin;

wire [ADDR_WIDTH:0] wptr_gray;
wire [ADDR_WIDTH:0] rptr_gray;

wire [ADDR_WIDTH-1:0] waddr;
wire [ADDR_WIDTH-1:0] raddr;

write_pointer #(
    .ADDR_WIDTH(ADDR_WIDTH)
) wp (
    .clk(wr_clk),
    .rst(rst),
    .wr_en(wr_en),
    .rptr_gray_sync(rptr_gray),
    .wptr_bin(wptr_bin),
    .wptr_gray(wptr_gray),
    .waddr(waddr),
    .full(full)
);

read_pointer #(
    .ADDR_WIDTH(ADDR_WIDTH)
) rp (
    .clk(rd_clk),
    .rst(rst),
    .rd_en(rd_en),
    .wptr_gray_sync(wptr_gray),
    .rptr_bin(rptr_bin),
    .rptr_gray(rptr_gray),
    .raddr(raddr),
    .empty(empty)
);

fifo_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) mem (
    .wr_clk(wr_clk),
    .wr_en(wr_en & ~full),
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .dout(dout)
);

endmodule
