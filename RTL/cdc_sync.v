`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 12:58:41
// Design Name: 
// Module Name: cdc_syn
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


module cdc_sync #(parameter WIDTH = 5) (
    input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);
    reg [WIDTH-1:0] sync_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_reg <= 0;
            data_out <= 0;
        end else begin
            sync_reg <= data_in;
            data_out <= sync_reg;
        end
    end
endmodule
