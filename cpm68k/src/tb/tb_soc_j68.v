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

module tb_soc_j68
(
    input  UART0_RX, // RX load port
    output UART0_TX, // TX load port
    input  UART1_RX, // RX terminal
    output UART1_TX  // TX terminal
);
    // ========================================================================
    // Reset and clock generation
    // ========================================================================
    
    wire  rst;
    wire  clk;

    tb_clock U_tb_clock
    (
        .rst_100     (rst),
        .clk_100     (clk)
    );
    
    // ========================================================================
    // 68000-based system-on-a-chip
    // ========================================================================
    
    soc_j68 DUT_soc_j68
    (
        .rst         (rst),
        .clk         (clk),
        .clk_ena     (1'b1),
        // UART #0
        .uart0_rxd   (UART0_RX),
        .uart0_cts_n (1'b0),
        .uart0_dcd_n (1'b0),
        .uart0_txd   (UART0_TX),
        .uart0_rts_n (/* open */),
        // UART #1
        .uart1_rxd   (UART1_RX),
        .uart1_cts_n (1'b0),
        .uart1_dcd_n (1'b0),
        .uart1_txd   (UART1_TX),
        .uart1_rts_n (/* open */)
    );

endmodule
