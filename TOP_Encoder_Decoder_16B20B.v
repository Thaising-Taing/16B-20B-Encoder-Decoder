`timescale 1ns/1ps

module TOP_Encoder_Decoder_16B20B#(
    parameter DINOUT = 16,
    parameter ENCODE = 20,
    parameter DECODE = 20
)(
    input clk, rst,
    input ena, 
    input [DINOUT-1:0] Input_Data,
    input K,  
    output wire [DINOUT-1:0] Output_Data,
    output wire [1:0] ko,          // Active high K indication
    output wire [1:0] code_err,    // Indication for illegal character
    output wire [1:0] disp_err     // Indication for disparity error 
);

reg ena_decode; 
wire [ENCODE-1:0] Encoder_Output;

Encoder_16B20B#(
    .DIN ( DINOUT ),
    .DOUT ( ENCODE ))
Encoder_16B20B (
    .rst ( rst ), .clk ( clk ),
    .ena ( ena ), .K   ( K   ),
    .Din ( Input_Data ), .Dout  ( Encoder_Output  ));

always @(*) begin
    if (Encoder_Output != 0) begin
        ena_decode <= 1; 
    end
    else begin
        ena_decode <= 0; 
    end
end

Decoder_20B16B#(
    .DIN      ( DECODE ),
    .DOUT     ( DINOUT ))
Decoder_20B16B(
    .rst      ( rst      ),     .clk      ( clk      ),
    .Din      ( Encoder_Output),.ena      ( ena_decode ),
    .ko       ( ko       ),     .Dout     ( Output_Data ),
    .code_err ( code_err ),     .disp_err ( disp_err  ));

endmodule