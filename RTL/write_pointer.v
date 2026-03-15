`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 12:56:55
// Design Name: 
// Module Name: write_pointer
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


module write_pointer #(parameter ADDR_WIDTH = 4)
(
    input clk,
    input rst,
    input wr_en,

    input [ADDR_WIDTH:0] rptr_gray_sync,

    output reg [ADDR_WIDTH:0] wptr_bin,
    output [ADDR_WIDTH:0] wptr_gray,
    output [ADDR_WIDTH-1:0] waddr,

    output full
);

wire [ADDR_WIDTH:0] wptr_bin_next;
wire [ADDR_WIDTH:0] wptr_gray_next;

assign waddr = wptr_bin[ADDR_WIDTH-1:0];

assign wptr_bin_next = wptr_bin + (wr_en & ~full);

assign wptr_gray_next = (wptr_bin_next >> 1) ^ wptr_bin_next;

assign wptr_gray = (wptr_bin >> 1) ^ wptr_bin;

assign full = (wptr_gray_next ==
               {~rptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
                rptr_gray_sync[ADDR_WIDTH-2:0]});

always @(posedge clk or posedge rst)
begin
    if(rst)
        wptr_bin <= 0;
    else
        wptr_bin <= wptr_bin_next;
end

endmodule
