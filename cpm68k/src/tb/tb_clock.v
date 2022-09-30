// Copyright 2011-2018 Frederic Requin
//
// This file is part of the MCC216 project
//
// The J68 core:
// -------------
// Simple re-implementation of the MC68000 CPU
// The core has the following characteristics:
//  - Tested on a Cyclone III (90 MHz) and a Stratix II (180 MHz)
//  - from 1500 (~70 MHz) to 1900 LEs (~90 MHz) on Cyclone III
//  - 2048 x 20-bit microcode ROM
//  - 256 x 28-bit decode ROM
//  - 2 x block RAM for the data and instruction stacks
//  - stack based CPU with forth-like microcode
//  - not cycle-exact : needs a frequency ~3 x higher
//  - all 68000 instructions are implemented
//  - almost all 68000 exceptions are implemented (only bus error missing)
//  - only auto-vector interrupts supported

`timescale 1 ns / 1 ps

module tb_clock
(
    output rst_100,
    `ifdef _VLINT_
    output clk_100
    `else
    output clk_100 /* verilator clocker */
    `endif
);

`ifdef _VCP
    // ========================================================================
    // Timing based simulation
    // ========================================================================
    
    reg       r_clk_100;
    
     // 100 MHz clock
    always begin
        r_clk_100 = 1'b1;
        forever #5.000 r_clk_100 = ~r_clk_100;
    end
    
`else
`ifdef verilator3
    // ========================================================================
    // State based simulation
    // ========================================================================
    
    // Done in main.cpp
    reg       r_clk_100 /* verilator public */;
    
`else
    // ========================================================================
    // Altium compile
    // ========================================================================
    
    reg       r_clk_100;
    
    always@(*) begin
        r_clk_100 = 1'b0;
    end

`endif /* verilator3 */
`endif /* _VCP */

    assign clk_100 = r_clk_100;

    // ========================================================================
    // Reset generation
    // ========================================================================
    
    reg [13:0] r_rst_100_ctr;
    
    initial begin
        r_rst_100_ctr = 14'd8192;
    end
    
    always@(posedge clk_100) begin : RESET_100M
    
        if (r_rst_100_ctr[13]) begin
            r_rst_100_ctr <= r_rst_100_ctr + 14'd1;
        end
    end

    assign rst_100 = r_rst_100_ctr[13];

endmodule
