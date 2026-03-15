`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 12:55:27
// Design Name: 
// Module Name: gray_counter
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


module gray_counter #(parameter WIDTH = 4)
(
    input  [WIDTH:0] bin,
    output [WIDTH:0] gray
);

assign gray = (bin >> 1) ^ bin;

endmodule
