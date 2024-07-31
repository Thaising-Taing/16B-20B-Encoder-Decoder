`timescale 1ns/1ps

module Decoder_10B8B #(
    parameter DIN = 10,
    parameter DOUT = 8
)(
    input wire rst,                // Active high rst
    input wire clk,                // Clock to register output and disparity
    input wire [DIN-1:0] Din,      // 10b data input
    input wire ena,                // Enable registers for output and disparity
    output reg ko,                 // Active high K indication
    output reg [DOUT-1:0] Dout,    // Decoded output
    output reg code_err,           // Indication for illegal character
    output reg disp_err            // Indication for disparity error
);

    // Internal signals
    reg dispin;
    wire dispout;
    wire a, b, c, d, e, i, f, g, h, j;
    wire aeqb, ceqd;
    wire p22, p13, p31;
    wire disp6a, disp6a2, disp6a0, disp6b;
    wire p22bceeqi, p22bncneeqi, p13in, p31i, p13dei;
    wire p22aceeqi, p22ancneeqi, p13en, anbnenin, abei;
    wire cndnenin, compa, compb, compc, compd, compe;
    wire A, B, C, D, E;
    wire feqg, heqj, fghj22, fghjp13, fghjp31;
    wire ko_s, k28p;
    wire F, G, H;
    wire disp6p, disp6n, disp4p, disp4n;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dispin <= 1'b0;
            disp_err <= 1'b0;
            Dout <= 8'h00;
            ko <= 1'b0;
            code_err <= 1'b0;
        end 
        else if (ena) begin
            // Calculate code_err
            code_err <= ((a & b & c & d) || (~(a || b || c || d))) ||
                        (p13 & ~e & ~i) ||
                        (p31 & e & i) ||
                        ((f & g & h & j) || (~(f || g || h || j))) ||
                        ((e & i & f & g & h) || (~(e || i || f || g || h))) ||
                        (((~i) & e & g & h & j) || (~((~i) || e || g || h || j))) ||
                        ((((~e) & (~i) & g & h & j) || (~((~e) || (~i) || g || h || j))) &&
                         ~(c & d & e) || ~(c || d || e)) ||
                        (~p31 & e & ~i & ~g & ~h & ~j) ||
                        (~p13 & ~e & i & g & h & j);

            // Calculate disp_err
            disp_err <= ((dispin & disp6p) || (disp6n & ~dispin) ||
                         (dispin & ~disp6n & f & g) ||
                         (dispin & a & b & c) ||
                         (dispin & ~disp6n & disp4p) ||
                         (~dispin & ~disp6p & ~f & ~g) ||
                         (~dispin & ~a & ~b & ~c) ||
                         (~dispin & ~disp6p & disp4n) ||
                         (disp6p & disp4p) || (disp6n & disp4n));

            dispin <= dispout;
            Dout <= {H, G, F, E, D, C, B, A};
            ko <= ko_s;
        end
    end

    // Intermediate calculations
    assign a = Din[9];
    assign b = Din[8];
    assign c = Din[7];
    assign d = Din[6];
    assign e = Din[5];
    assign i = Din[4];
    assign f = Din[3];
    assign g = Din[2];
    assign h = Din[1];
    assign j = Din[0];

    assign aeqb = (a & b) || (~a & ~b);
    assign ceqd = (c & d) || (~c & ~d);
    assign p22 = (a & b & ~c & ~d) ||
                (c & d & ~a & ~b) ||
                (~aeqb & ~ceqd);
    assign p13 = (~aeqb & ~c & ~d) ||
                (~ceqd & ~a & ~b);
    assign p31 = (~aeqb & c & d) ||
                (~ceqd & a & b);

    assign disp6a = p31 || (p22 && dispin);
    assign disp6a2 = p31 && dispin;
    assign disp6a0 = p13 && ~dispin;
    assign disp6b = (((e & i & ~disp6a0) || (disp6a && (e || i)) || disp6a2 ||
                     (e & i & d)) && (e || i || d));

    // 5B/6B Decoding special cases
    assign p22bceeqi = p22 && b && c && ~(e ^ i);
    assign p22bncneeqi = p22 && ~b && ~c && ~(e ^ i);
    assign p13in = p13 && ~i;
    assign p31i = p31 && i;
    assign p13dei = p13 && d && e && i;
    assign p22aceeqi = p22 && a && c && ~(e ^ i);
    assign p22ancneeqi = p22 && ~a && ~c && ~(e ^ i);
    assign p13en = p13 && ~e;
    assign anbnenin = ~a && ~b && ~e && ~i;
    assign abei = a && b && e && i;
    assign cndnenin = ~c && ~d && ~e && ~i;

    assign compa = p22bncneeqi || p31i || p13dei || p22ancneeqi ||
                   p13en || abei || cndnenin;
    assign compb = p22bceeqi || p31i || p13dei || p22aceeqi ||
                   p13en || abei || cndnenin;
    assign compc = p22bceeqi || p31i || p13dei || p22ancneeqi ||
                   p13en || anbnenin || cndnenin;
    assign compd = p22bncneeqi || p31i || p13dei || p22aceeqi ||
                   p13en || abei || cndnenin;
    assign compe = p22bncneeqi || p13in || p13dei || p22ancneeqi ||
                   p13en || anbnenin || cndnenin;

    assign A = a ^ compa;
    assign B = b ^ compb;
    assign C = c ^ compc;
    assign D = d ^ compd;
    assign E = e ^ compe;

    assign feqg = (f && g) || (~f && ~g);
    assign heqj = (h && j) || (~h && ~j);
    assign fghj22 = (f && g && ~h && ~j) ||
                    (~f && ~g && h && j) ||
                    (~feqg && ~heqj);
    assign fghjp13 = (~feqg && ~h && ~j) ||
                     (~heqj && ~f && ~g);
    assign fghjp31 = (~feqg && h && j) ||
                     (~heqj && f && g);

    assign dispout = (fghjp31 || (disp6b && fghj22) || (h && j)) &&
                     (h || j);

    assign ko_s = ((c && d && e && i) ||
                   (~c && ~d && ~e && ~i) ||
                   (p13 && ~e && i && g && h && j) ||
                   (p31 && e && ~i && ~g && ~h && ~j));

    assign k28p = ~(c || d || e || i);
    assign F = (j && ~f && (h || ~g || k28p)) ||
                (f && ~j && (~h || g || ~k28p)) ||
                (k28p && g && h) ||
                (~k28p && ~g && ~h);
    assign G = (j && ~f && (h || ~g || ~k28p)) ||
                (f && ~j && (~h || g || k28p)) ||
                (~k28p && g && h) ||
                (k28p && ~g && ~h);
    assign H = ((j ^ h) && ~(~f && g && ~h && j && ~k28p ||
                                ~f && g && h && ~j && k28p ||
                                f && ~g && ~h && j && ~k28p ||
                                f && ~g && h && ~j && k28p)) ||
                (~f && g && h && j) ||
                (f && ~g && ~h && ~j);

    assign disp6p = (p31 && (e || i)) || (p22 && e && i);
    assign disp6n = (p13 && ~(e && i)) || (p22 && ~e && ~i);
    assign disp4p = fghjp31;
    assign disp4n = fghjp13;

endmodule
