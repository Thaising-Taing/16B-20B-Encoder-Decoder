`timescale 1ns/1ps

module Encoder_8B10B #(
    parameter DIN = 8,
    parameter DOUT = 10
)(
    input wire rst,             // Active high reset
    input wire clk,             // Clock to register dataout
    input wire ena,             // To validate datain and register dataout and disparity
    input wire K,               // Control (K) input (active high)
    input wire [DIN-1:0] Din,   // 8 bit input data
    output reg [DOUT-1:0] Dout  // 10 bit encoded output
);

    reg aeqb, ceqd, l22, l40, l04, l13, l31;
    reg pd1s6, nd1s6, ndos6, pdos6;
    reg alt7;
    reg nd1s4, pd1s4, ndos4, pdos4;
    reg compls6, disp6, compls4;
    reg A, B, C, D, E, F, G, H;
    reg a, b, c, d, e, i, f, g, h, j;
    reg dispin, dispout;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            dispin <= 0;
            Dout <= 10'b0000000000;
        end 
        else if (ena) begin
            dispin <= dispout;
            Dout <= {a ^ compls6, b ^ compls6, c ^ compls6, d ^ compls6,
                    e ^ compls6, i ^ compls6, f ^ compls4, g ^ compls4,
                    h ^ compls4, j ^ compls4};
        end
    end

    // Input assignments
    always @(*) begin
        A = Din[0];
        B = Din[1];
        C = Din[2];
        D = Din[3];
        E = Din[4];
        F = Din[5];
        G = Din[6];
        H = Din[7];
    end

    // Combinational logic
    always @(*) begin
        aeqb = (A & B) | (~A & ~B);
        ceqd = (C & D) | (~C & ~D);
        l22 = (A & B & ~C & ~D) | (C & D & ~A & ~B) | (~aeqb & ~ceqd);
        l40 = A & B & C & D;
        l04 = ~A & ~B & ~C & ~D;
        l13 = (~aeqb & ~C & ~D) | (~ceqd & ~A & ~B);
        l31 = (~aeqb & C & D) | (~ceqd & A & B);

        // 5B/6B Encoding
        a = A;
        b = (B & ~l40) | l04;
        c = l04 | C | (E & D & ~C & ~B & ~A);
        d = D & ~(A & B & C);
        e = (E | l13) & ~(E & D & ~C & ~B & ~A);
        i = (l22 & ~E) |
             (E & ~D & ~C & ~(A & B)) |
             (E & l40) |
             (K & E & D & C & ~B & ~A) |
             (E & ~D & C & ~B & ~A);

        // pd1s6 and nd1s6
        pd1s6 = (E & D & ~C & ~B & ~A) | (~E & ~l22 & ~l31);
        nd1s6 = K | (E & ~l22 & ~l13) | (~E & ~D & C & B & A);

        // ndos6 and pdos6
        ndos6 = pd1s6;
        pdos6 = K | (E & ~l22 & ~l13);

        // Alt7 encoDng
        if (dispin) begin
            alt7 = ~E & D & l31;
        end 
        else begin
            alt7 = E & ~D & l13;
        end
        alt7 = F & G & H & (K | alt7);

        // 4B/5B Encoding
        f = F & ~alt7;
        g = G | (~F & ~G & ~H);
        h = H;
        j = (~H & (G ^ F)) | alt7;

        // pd1s4 and nd1s4
        nd1s4 = F & G;
        pd1s4 = (~F & ~G) | (K & ((F & ~G) | (~F & G)));

        // ndos4 and pdos4
        ndos4 = ~F & ~G;
        pdos4 = F & G & H;

        // Complementing Logic
        compls6 = (pd1s6 & ~dispin) | (nd1s6 & dispin);
        disp6 = dispin ^ (ndos6 | pdos6);
        compls4 = (pd1s4 & ~disp6) | (nd1s4 & disp6);
        dispout = disp6 ^ (ndos4 | pdos4);
    end
endmodule
