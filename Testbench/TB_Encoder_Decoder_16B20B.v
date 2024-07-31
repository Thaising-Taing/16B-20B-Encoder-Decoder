`timescale 1ns/1ps

module TB_Encoder_Decoder_16B20B();

parameter DINOUT = 16;
parameter ENCODE = 20;
parameter DECODE = 20;

reg clk, rst;
reg ena;  
reg [DINOUT-1:0] Input_Data;
reg [DINOUT-1:0] Encoder_Input;
reg K;  
wire [DINOUT-1:0] Decoder_Output;
reg [DINOUT-1:0] Output_Data; 
wire [1:0] ko;        
wire [1:0] code_err;    
wire [1:0] disp_err;     

reg [DINOUT-1:0]mem[0:2000]; 
reg [7:0] addr; 

initial begin
    clk = 0; 
    forever begin
        #5 clk = ~clk; 
    end
end

initial begin
    rst <= 1; ena <= 0;
    // Transmission Data
    $readmemb("Test_Data.mem", mem); 

    #10 rst <= 0; ena <= 1; 
end

// Counter 
always @(posedge clk or posedge rst) begin
    if (rst) begin
        addr <= 0; 
    end
    else begin
        if (addr <= 100) begin
            addr <= addr + 1; 
        end
        else begin
            addr <= addr; 
        end
    end
end

always @(*) begin
    if (rst) begin
        Input_Data <= 0; 
    end
    else begin
        Input_Data <= mem[addr]; 
    end
end

always @(*) begin
    if (rst) begin
        K <= 0; 
    end
    else begin
        if ((addr >= 0 && addr <= 20) || (addr >= 50 && addr <= 80)) begin
            K <= 1;
        end
        else begin
            K <= 0; 
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        Encoder_Input <= 0;  
        Output_Data <= 0; 
    end
    else if (ena) begin
        Encoder_Input <= Input_Data; 
        Output_Data <= Decoder_Output;
    end
end

TOP_Encoder_Decoder_16B20B#(
    .DINOUT      ( DINOUT ),
    .ENCODE      ( ENCODE ),
    .DECODE      ( DECODE ))
TOP_Encoder_Decoder_16B20B(
    .clk         ( clk              ),
    .rst         ( rst              ),
    .ena         ( ena              ),
    .Input_Data  ( Encoder_Input    ),
    .K           ( K                ),
    .Output_Data ( Decoder_Output   ),
    .ko          ( ko               ),
    .code_err    ( code_err         ),
    .disp_err    ( disp_err         ));

endmodule