`timescale 1ns/1ps

module Decoder_20B16B #(
    parameter DIN = 20,
    parameter DOUT = 16
)(
    input wire rst,                // Active high rst
    input wire clk,                // Clock to register output and disparity
    input wire [DIN-1:0] Din,      // 20bit Encodede data input
    input wire ena,                // Enable registers for output and disparity
    output wire [1:0] ko,          // Active high K indication
    output reg [DOUT-1:0] Dout,    // 16-bit Decoded output
    output wire [1:0] code_err,    // Indication for illegal character
    output wire [1:0] disp_err     // Indication for disparity error
);

reg [9:0] Din_8B10B_0; 
reg [9:0] Din_8B10B_1;
wire [7:0] Dout_8B10B_0; 
wire [7:0] Dout_8B10B_1;

always @(*) begin
    Din_8B10B_0 = Din[19:10];
    Din_8B10B_1 = Din[9:0]; 
end

Decoder_10B8B#(
    .DIN      ( DIN ),
    .DOUT     ( DOUT))
Decoder_10B8B_0(
    .rst      ( rst      ),    .clk      ( clk      ),
    .Din      ( Din_8B10B_0 ), .ena      ( ena      ),
    .ko       ( ko[0]       ), .Dout     ( Dout_8B10B_0 ),
    .code_err ( code_err[0] ),    .disp_err  ( disp_err[0]  ));


Decoder_10B8B#(
    .DIN      ( DIN ),
    .DOUT     ( DOUT))
Decoder_10B8B_1(
    .rst      ( rst      ),    .clk      ( clk      ),
    .Din      ( Din_8B10B_1 ), .ena      ( ena      ),
    .ko       ( ko[1]    ),    .Dout     ( Dout_8B10B_1),
    .code_err ( code_err[1] ),    .disp_err  ( disp_err[1]  ));

always @(posedge clk or posedge rst) begin
    if (rst) begin
        Dout <= 16'd0;
    end
    else if (ena) begin
        Dout <= {Dout_8B10B_0, Dout_8B10B_1}; 
    end
end

endmodule