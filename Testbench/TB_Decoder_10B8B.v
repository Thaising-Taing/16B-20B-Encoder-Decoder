`timescale 1ns / 1ps

module TB_Decoder_8B10B();

    parameter DIN = 10;
    parameter DOUT = 8;

    // Testbench signals
    reg rst;
    reg clk;
    reg ena;
    reg [DIN-1:0] Din;              // 10-Bit Encoded
    wire ko;
    wire [DOUT-1:0] Dout;           // 8-Bit Decoded
    wire code_err;
    wire disp_err;

    // Instantiate the Decoder_8B10B module
    Decoder_10B8B Decoder(
        .rst      ( rst      ), .clk      ( clk      ),
        .Din      ( Din      ), .ena      ( ena      ),
        .ko       ( ko       ), .Dout     ( Dout     ),
        .code_err ( code_err ), .disp_err ( disp_err ));



    // Clock generation
    always begin
        #5 clk = ~clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        ena = 0;
        Din = 10'b0000000000;

        // Apply rst
        #10;
        rst = 0;
        #10;

        // Enable the decoder
        ena = 1;

        // Test case 1: Valid input pattern 1
        Din = 10'b1000000000; // Example 10b input pattern
        #10;

        // Test case 2: Valid input pattern 2
        Din = 10'b0110000000; // Example 10b input pattern
        #10;

        // Test case 3: Invalid input pattern (for code error detection)
        Din = 10'b1111111111; // Example 10b input pattern
        #10;

        // Test case 4: Another valid input pattern
        Din = 10'b0011001100; // Example 10b input pattern
        #10;

        // Test case 5: rst during operation
        rst = 1;
        #10;
        rst = 0;
        #10;

        // Test case 6: Edge case with all zeros
        Din = 10'b0000000000;
        #10;

        // Test case 7: Edge case with all ones
        Din = 10'b1111111111;
        #10;

        // Test case 8: Random pattern
        Din = 10'b0101010101;
        #10;

        // Disable the decoder
        ena = 0;
        #10;

        // Finish the simulation
        $finish;
    end

    // Monitor changes and print values to console
    initial begin
        $monitor("Time: %0t | rst: %b | ena: %b | Din: %b | ko: %b | Dout: %b | code_err: %b | disp_err: %b",
                  $time, rst, ena, Din, ko, Dout, code_err, disp_err);
    end

endmodule
