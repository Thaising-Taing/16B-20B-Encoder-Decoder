# Verilog Implementation of 16B/20B Encoder-Decoder
Encoding the 16-Bits Input Data into 20-Bits Output Data, and Decoding 20-Bits Input Data into 16-Bits Output Data. This Encoder is combined with Two 8B/10B-Encoders and Two 8B/10B-Decoders. 
## Encoder
- clk: Clock to Register Dout
- rst: Active High Reset
- ena: To validate datain and register dataout and disparity
- K: Control (K) input (active high)
- Din: 16-bits input data
- Dout: 20 bit encoded output
## Decoder
- clk: Clock to register output and disparity
- rst: Active High Reset
- ena: Enable registers for output and disparity
- ko: Active high K indication
- Din: 20-bits Encodede data input
- Dout: 16-bits Decoded output
# FPGA Ultilization
The Ultilization was measure for Xilinx ZCU104 FPGA as follows: 
## Encoder and Decoder (16B/20B)
| Modules    | LUTs | FFs     |
|---------|-----|----------------|
| Encoder   | 31  | 42|
| Decoder     | 58  | 40  |
# References
- [8b10b_VHDL](https://github.com/fransschreuder/8b10b_VHDL): Details of the Verilog Design of 8B/10B Encoder/Decoder in VHDL.
