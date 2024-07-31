`timescale 1ns / 1ps

module TB_Encoder_8B10B();

    // Testbench signals
    reg rst;
    reg clk;
    reg ena;
    reg K;
    reg [7:0] Din;
    wire [9:0] Dout;

    // Instantiate the Unit Under Test (UUT)
    Encoder_8B10B Encoder(
        .rst ( rst ), .clk ( clk ),
        .ena ( ena ), .K   ( K   ),
        .Din ( Din ), .Dout  ( Dout )
    );

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk; // 100 MHz clock
        end
    end

    // rst and test stimulus generation
    initial begin
        // Initialize signals
        rst = 1;
        ena = 0;
        K = 0;
        Din = 8'b00000000;
        
        // Wait for a few clock cycles
        #20;
        
        // Release rst
        rst = 0;
        #10;

        // Enable the encoder
        ena = 1;

        // Apply test vectors
        Din = 8'b11000011; K = 1; #10;
        Din = 8'b00000010; K = 0; #10;
        Din = 8'b00000100; K = 0; #10;
        Din = 8'b00001000; K = 0; #10;
        Din = 8'b00010000; K = 0; #10;
        Din = 8'b00100000; K = 0; #10;
        Din = 8'b01000000; K = 0; #10;
        Din = 8'b10000000; K = 0; #10;

        // Apply some K codes
        Din = 8'b00000000; K = 1; #10;
        Din = 8'b11111111; K = 1; #10;

        // Deactivate encoder
        ena = 0;
        Din = 8'b00000000; K = 0; #10;

        // Apply more test vectors while encoder is deactivated
        Din = 8'b01010101; K = 0; #10;
        Din = 8'b10101010; K = 0; #10;

        // Apply rst again
        rst = 1; #10;
        rst = 0; #10;

        // End of test
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0t | rst: %b | ENA: %b | K: %b | Din: %b | Dout: %b", 
                 $time, rst, ena, K, Din, Dout);
    end

endmodule
