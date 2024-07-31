`timescale 1ns/1ps

module Encoder_16B20B#(
    parameter DIN = 16,
    parameter DOUT = 20
)(
    input wire rst,             // Active high reset
    input wire clk,             // Clock to register dataout
    input wire ena,             // To validate datain and register dataout and disparity
    input wire K,               // Control (K) input (active high)
    input wire [DIN-1:0] Din,   // 16 bit input data
    output reg [DOUT-1:0] Dout  // 20 bit encoded output
);

reg [7:0] Din_8B10B_0; 
reg [7:0] Din_8B10B_1;
wire [9:0] Dout_8B10B_0; 
wire [9:0] Dout_8B10B_1;

always @(*) begin
    Din_8B10B_0 = Din[15:8];
    Din_8B10B_1 = Din[7:0]; 
end


Encoder_8B10B#(
    .DIN ( DIN ),
    .DOUT ( DOUT ))
Encoder_8B10B_0(
    .rst ( rst ), .clk ( clk ),
    .ena ( ena ), .K   ( K   ),
    .Din ( Din_8B10B_0 ), .Dout  ( Dout_8B10B_0  ));

Encoder_8B10B#(
    .DIN ( DIN ),
    .DOUT ( DOUT ))
Encoder_8B10B_1(
    .rst ( rst ), .clk ( clk ),
    .ena ( ena ), .K   ( K   ),
    .Din ( Din_8B10B_1 ), .Dout  ( Dout_8B10B_1  ));

always @(posedge clk or posedge rst) begin
    if (rst) begin
        Dout <= 20'd0; 
    end
    else if (ena) begin
        Dout = {Dout_8B10B_0, Dout_8B10B_1};
    end
end

endmodule