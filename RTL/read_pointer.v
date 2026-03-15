`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 12:57:47
// Design Name: 
// Module Name: read_pointer
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


module read_pointer #(parameter ADDR_WIDTH = 4)
(
    input clk,
    input rst,
    input rd_en,

    input [ADDR_WIDTH:0] wptr_gray_sync,

    output reg [ADDR_WIDTH:0] rptr_bin,
    output [ADDR_WIDTH:0] rptr_gray,
    output [ADDR_WIDTH-1:0] raddr,

    output empty
);

wire [ADDR_WIDTH:0] rptr_bin_next;
wire [ADDR_WIDTH:0] rptr_gray_next;

assign raddr = rptr_bin[ADDR_WIDTH-1:0];

assign rptr_bin_next = rptr_bin + (rd_en & ~empty);

assign rptr_gray_next = (rptr_bin_next >> 1) ^ rptr_bin_next;

assign rptr_gray = (rptr_bin >> 1) ^ rptr_bin;

assign empty = (rptr_gray == wptr_gray_sync);

always @(posedge clk or posedge rst)
begin
    if(rst)
        rptr_bin <= 0;
    else
        rptr_bin <= rptr_bin_next;
end

endmodule
