// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

`timescale 1ns / 1ps
//`define Use32K

module NES_TN9(
        input 			clk27M,
        //input CLK100MHZ, input CPU_RESET, 
        //input [15:0] SW, output [7:0] SSEG_CA, output [7:0] SSEG_AN, output [5:0] gpio,
        // VGA output vga_vo, output vga_ho, output vga_ro, output vga_go, output vga_bo,
        // HDMI
        output       	tmds_clk_n,
        output       	tmds_clk_p,
        output [2:0] 	tmds_d_n,
        output [2:0] 	tmds_d_p,
        // Sound board
        //output AUD_MCLK, output AUD_LRCK, output AUD_SCK, output AUD_SDIN,
        output          DACout,
        // PSRAM(Internal connection)
		output wire [1:0] 	O_psram_ck,
		output wire [1:0] 	O_psram_ck_n,
		inout  wire [1:0] 	IO_psram_rwds,
		inout  wire [15:0]	IO_psram_dq,
		output wire [1:0] 	O_psram_reset_n,
		output wire [1:0] 	O_psram_cs_n,
        // Debug.I/O
        input 			UART_RXD,
        output 			UART_TXD,
        input  [1:0]	BTN,
        output [5:0]	LED
        );

  assign LED = ~{load_mode, 2'b00,load_resct};
  assign cga_ho = vga_h;
  assign vga_vo = vga_v;
  assign vag_ro = vga_r[3];
  assign vag_go = vga_g[3];
  assign vag_bo = vga_b[3];

  wire breset = ~BTN[1];
  wire [15:0] SW = 16'b1111111111111111;
  wire [7:0] SSEG_CA;
  wire [7:0] SSEG_AN;

  wire pll_lock1,pll_lock2;
  wire pll_lock = pll_lock1 && pll_lock2;
  wire clk_25, clk_126, clk_126b, clk_252;	// p5:125.875  p:25.175
  wire clk;	// 21.477M(ORG) -> 21.6M
  wire clk_pixel = clk_25;
  wire clk_ps = clk_126b;

  Gowin_rPLL  cpuclk( .clkin(clk27M), .clkout(), .clkoutd(clk), .lock(pll_lock1) );
  Gowin_rPLL1 memclk( .clkin(clk27M), .clkout(clk_252), .clkoutd(clk_126), .lock(pll_lock2) );
  Gowin_CLKDIV2 u_div_2( .clkout(clk_126b), .hclkin(clk_252), .resetn(pll_lock) );
  Gowin_CLKDIV  u_div_5( .clkout(clk_25),   .hclkin(clk_126), .resetn(pll_lock) );

	//wire [5:0] rout = {vga_r[3:0],2'b00};
	//wire [5:0] gout = {vga_g[3:0],2'b00};
	//wire [5:0] bout = {vga_b[3:0],2'b00};
    wire [3:0] vga_r, vga_g, vga_b;
	wire vdma_tvalid;
	wire vdma_tready;
	wire [24-1:0] vdma_tdata;	// SVO_BITS_PER_PIXEL = 24
	wire [0:0] vdma_tuser;
	wire [3:0] enc_tuser;
	wire hsync_ns,vsync_ns;
	wire hblnk;

svo_hdmi_out u_hdmi (
	.resetn(~breset),
	.clk_pixel(clk_25),
	.clk_5x_pixel(clk_126),
	.locked(pll_lock),
	// input VGA
	.rout(vga_r),
	.gout(vga_g),
	.bout(vga_b),
	.hsync_n(~vga_h),
	.vsync_n(~vga_v),
	.hblnk_n(hblnk || vblnk),
	// output signals
	.tmds_clk_n(tmds_clk_n),
	.tmds_clk_p(tmds_clk_p),
	.tmds_d_n(tmds_d_n),
	.tmds_d_p(tmds_d_p),
	.tmds_ts()
);

  // UART(ROM.Load & Debug)
  wire [7:0] uart_data;
  wire [7:0] uart_addr;
  wire       uart_write;
  wire       uart_error;
  UartDemux uart_demux(clk, 1'b0, UART_RXD, uart_data, uart_addr, uart_write, uart_error);

  // load
  wire [7:0] load_input = uart_data;
  wire       load_clk   = (uart_addr == 8'h37) && uart_write;
  reg  [7:0] load_conf;
  reg  [7:0] load_btn, load_btn_2;
  always @(posedge clk) begin
    if (load_res)                load_conf  <= 0;
    else  
    if (uart_addr == 8'h35 && uart_write) load_conf  <= uart_data;
    if (uart_addr == 8'h40 && uart_write) load_btn   <= uart_data;
    if (uart_addr == 8'h41 && uart_write) load_btn_2 <= uart_data;
  end

  wire [21:0] load_addr;
  wire [7:0] load_write_data;
  wire [1:0] load_state;
  wire load_reset = load_conf[0] || load_res;
  wire load_write;
  wire [31:0] mapper_flags;
  wire load_done, load_fail;
  Gameload load(clk, load_reset, load_input, load_clk,
           load_addr, load_write_data, load_write,
           mapper_flags, load_done, load_state, load_fail);

  // NES Palette -> RGB332 conversion
  //reg [14:0] pallut[0:63];
  //initial $readmemh("nes_palette.txt", pallut);
  reg [0:63][14:0] pallut = {	
	15'h3def,15'h7c00,15'h5c00,15'h5ca8,15'h4012,15'h1015,15'h0055,15'h0051,15'h00ca,15'h01e0,15'h01a0,15'h0160,15'h2d00,15'h0000,15'h0000,15'h0000,
	15'h5ef7,15'h7de0,15'h7d60,15'h7d0d,15'h641b,15'h2c1c,15'h00ff,15'h097c,15'h01f5,15'h02e0,15'h02a0,15'h22a0,15'h4620,15'h0000,15'h0000,15'h0000,
	15'h7fff,15'h7ee7,15'h7e2d,15'h7df3,15'h7dff,15'h4d7f,15'h2dff,15'h229f,15'h02ff,15'h0ff7,15'h2b6b,15'h4feb,15'h6fa0,15'h3def,15'h0000,15'h0000,
	15'h7fff,15'h7f94,15'h7ef7,15'h7efb,15'h7eff,15'h629f,15'h5b5e,15'h579f,15'h3f7f,15'h3ffb,15'h5ff7,15'h6ff7,15'h7fe0,15'h7f7f,15'h0000,15'h0000};

  // LED Display
  reg [31:0] led_value;
  reg [7:0] led_enable;
  LedDriver led_driver(clk, led_value, led_enable, SSEG_CA, SSEG_AN);

  wire [8:0] cycle;
  wire [8:0] scanline;
  wire [15:0] sample;
  wire [5:0] color;
  wire joypad_strobe;
  wire [1:0] joypad_clock;
  wire [21:0] nes_memaddr;
  wire mem_read_cpu, mem_read_ppu;
  wire mem_write;
  wire [7:0] mem_din_cpu, mem_din_ppu;
  wire [7:0] mem_dout;
  reg [7:0] joypad_bits, joypad_bits2;
  reg [1:0] last_joypad_clock;
  wire [31:0] dbgadr;
  wire [1:0] dbgctr;
  reg [1:0] nes_ce;

  always @(posedge clk) begin
    if (joypad_strobe) begin
      joypad_bits <= load_btn;
      joypad_bits2 <= load_btn_2;
    end
    if (!joypad_clock[0] && last_joypad_clock[0])
      joypad_bits <= {1'b0, joypad_bits[7:1]};
    if (!joypad_clock[1] && last_joypad_clock[1])
      joypad_bits2 <= {1'b0, joypad_bits2[7:1]};
    last_joypad_clock <= joypad_clock;
  end
  
  wire reset_nes = (breset || !load_done || !ps_calib);
  wire run_mem = (nes_ce == 0) && !reset_nes;
  wire run_nes = (nes_ce == 3) && !reset_nes;

  // NES is clocked at every 4th cycle.
  wire [1:0] cpu_cycle_counter; ////
  always @(posedge clk)
    nes_ce <= nes_ce + 1;

  wire psr_mt00 = load_done && nes_ce==2'b00 && cpu_cycle_counter==2'b00; 
  wire [21:0] prg_linaddr;
  wire [7:0]  prg_din;
  
  NES nes(clk, reset_nes, run_nes,
          mapper_flags,
          sample, color,
          joypad_strobe, joypad_clock, {joypad_bits2[0], joypad_bits[0]},
          SW[4:0],
          nes_memaddr,
          mem_read_cpu, mem_din_cpu,
          mem_read_ppu, mem_din_ppu,
          mem_write, mem_dout,
          cycle, scanline,
          prg_linaddr,
          prg_din,
          prg_read,
          prg_write,
          cpu_cycle_counter,
          dbgadr,
          dbgctr,
          UART_TXD,
          UART_RXD
);

  // This is the memory controller to access the board's PSRAM
  wire MemOE, MemWR, MemWait;
  wire RamCS;
  wire ram_busy;
  wire [23:0] psr_maddr    = ~load_done ? {2'b00, load_addr} : {2'b00, prg_linaddr};
  wire [23:0] mem_addr_mc  = ~load_done ? {2'b00, load_addr} : {2'b00, nes_memaddr};
  wire  [7:0] mem_din_mc   = ~load_done ? load_write_data : mem_dout;
  wire  [7:0] psr_mdin     = ~load_done ? load_write_data : prg_din;
  wire        psr_wen      = ~load_done ? load_write      : prg_write;
  MemoryController memory(clk,
         mem_read_cpu && run_mem, 
         mem_read_ppu && run_mem,
         mem_write && run_mem || load_write,
         mem_addr_mc, //load_write ? {2'b00, load_addr} : {2'b00, nes_memaddr},
         mem_din_mc,  //load_write ? load_write_data : mem_dout,
         mem_din_cpu,
         mem_din_ppu,
         ram_busy,
		 // PSRAM
         psr_maddr,
         psr_mdin,
         psr_wen,
         psr_mt00,
         load_done,
		 breset,
		 clk_ps, 	// clkx4(86.4)=clk(1.8M)x12
		 pll_lock,	// ps reset
		 ps_calib,	// ps ready
		 O_psram_ck,
		 O_psram_ck_n,
		 IO_psram_rwds,
		 IO_psram_dq,
		 O_psram_reset_n,
		 O_psram_cs_n
                 );
  reg ramfail;
  always @(posedge clk) begin
    if (load_reset)
      ramfail <= 0;
    else
      ramfail <= ram_busy && load_write || ramfail;
  end

  wire [14:0] doubler_pixel;
  wire doubler_sync, hvlnk, vblnk;
  wire [9:0] vga_hcounter, doubler_x;
  wire [9:0] vga_vcounter;
  
  VgaDriver vga(clk, vga_h, vga_v, vga_r, vga_g, vga_b, vga_hcounter, vga_vcounter, doubler_x, hblnk, vblnk, doubler_pixel, doubler_sync, SW[0]);
  
  wire [14:0] pixel_in = pallut[color];
  Hq2x hq2x(clk, pixel_in, SW[5], 
            scanline[8],        // reset_frame
            (cycle[8:3] == 42), // reset_line
            doubler_x,          // 0-511 for line 1, or 512-1023 for line 2.
            doubler_sync,       // new frame has just started
            doubler_pixel);     // pixel is outputted

  wire [15:0] sound_signal = {sample[15] ^ 1'b1, sample[14:0]};
//  wire [15:0] sound_signal_fir;
//  wire sample_now_fir;
//  FirFilter fir(clk, sound_signal, sound_signal_fir, sample_now_fir);
  // Display mapper info on screen
  always @(posedge clk) begin
    led_enable <= 255;
    led_value <= sound_signal;
  end

//  reg [7:0] sound_ctr;
//  always @(posedge clk)
//    sound_ctr <= sound_ctr + 1;
//  wire sound_load = /*SW[6] ? sample_now_fir : */(sound_ctr == 0);
//  SoundDriver sound_driver(clk, 
//      /*SW[6] ? sound_signal_fir : */sound_signal, 
//      sound_load,
//      sound_load,
//      AUD_MCLK, AUD_LRCK, AUD_SCK, AUD_SDIN, DACout);
   //
  audiodac audiodac ( 
    .Clk(clk_126), .Reset(1'b0), .DACin({2'b00,sound_signal[15:2]}), .DACout(DACout)  );

  reg  clk_div21d;
  reg [2:0] load_resct;
  wire load_res  = load_resct[2];
  wire load_mode = load_done ? ~(load_state==3) : load_state!=0 ? clk_div[20] : clk_div[21];
  reg  [23:0] clk_div;
  always @(posedge clk) begin
    clk_div <= clk_div + 1; clk_div21d <= clk_div[21];
    if(~breset) load_resct <= 0;
    else if(clk_div[21] && ~clk_div21d && ~load_res) load_resct <= load_resct + 1;
  end
endmodule

// Asynchronous PSRAM controller for byte access
// After outputting a byte to read, the result is available 70ns later.
module MemoryController(
        input clk,
        input read_a,             // Set to 1 to read from RAM
        input read_b,             // Set to 1 to read from RAM
        input write,              // Set to 1 to write to RAM
        input [23:0] addr,        // Address to read / write
        input [7:0] din,          // Data to write
        output reg [7:0] dout_a,  // Last read data a
        output reg [7:0] dout_b,  // Last read data b
        output reg busy,          // 1 while an operation is in progress
	// PSRAM(Internal connection)
    input  wire [23:0]  psr_maddr,
    input  wire [7:0]   psr_mdin,
    input               load_write,
	input				psr_mt00,
	input				load_done,
	input  wire			reset,
	input  wire			psram_clk,
	input  wire			pll_lock,
	output wire			ps_calib,
	output wire [1:0] 	O_psram_ck,
	output wire [1:0] 	O_psram_ck_n,
	inout  wire [1:0] 	IO_psram_rwds,
	inout  wire [15:0]	IO_psram_dq,
	output wire [1:0] 	O_psram_reset_n,
	output wire [1:0] 	O_psram_cs_n
    );
        
  reg [23:0] maddr;
  reg [7:0] mem_din;
  reg [1:0] cycles;
  reg r_read_b;
  reg MemWR,MemOE;
  always @(posedge clk) begin
    // Initiate read or write
    if (!busy) begin
       if (read_b || write) begin
        maddr <= addr; mem_din <= din; r_read_b <= read_b;
		MemWR <= write;  MemOE <= ~write; busy <= 1; cycles <= 0;
      end else begin
        MemOE <= 0; MemWR <= 0; busy <= 0; cycles <= 0;
      end
    end else begin
      if (cycles == 2) begin
         if (MemOE) begin
          if (r_read_b) dout_b <= ppuDB;
        end
        MemOE <= 0; MemWR <= 0; busy <= 0; cycles <= 0;
      end else cycles <= cycles + 1;
    end
`ifndef Use32K
	if(cpuramCS)    dout_a <= cpuramdo;
	else
`endif
		if(sddtac) dout_a <= psr_mdo;
	//
  end

    // ========================================================================
    // SRAM
    // ========================================================================
  wire cpumemCS = psadr[21]   ==1'b0;
  wire cpuramCS = psadr[21:18]==4'b1110; 
  wire ppumemCS = maddr[21:20]==2'b10; 
  wire ppuramCS = maddr[21:18]==4'b1100; 
  wire cartCS   = maddr[21:18]==4'b1111;
  wire [15:0] cpumemdo, ppumemdo, cpuramdo, ppuramdo; 
  wire [7:0]  ppuDB = ppumemCS ? ppumemdo[7:0] : ppuramdo[7:0];  

`ifndef Use32K
    Gowin_SP_2KBx8 cpuram(
        .clk(clk), .reset(1'b0), .oce(1'b1), .ce(cpuramCS), .wre(pswr),
        .ad(psadr[10:0]), .din(din), .dout(cpuramdo[ 7:0]) );
    Gowin_SP_16KBx8 ppumem(
        .clk(clk), .reset(1'b0), .oce(1'b1), .ce(ppumemCS), .wre(MemWR),
        .ad(maddr[13:0]), .din(mem_din), .dout(ppumemdo[ 7:0]) );
`else
    Gowin_SP_32KBx8 ppumem(
        .clk(clk), .reset(1'b0), .oce(1'b1), .ce(ppumemCS), .wre(MemWR),
        .ad(maddr[14:0]), .din(mem_din), .dout(ppumemdo[ 7:0]) );
`endif
    Gowin_SP_2KBx8 ppuram(
        .clk(clk), .reset(1'b0), .oce(1'b1), .ce(ppuramCS), .wre(MemWR),
        .ad(maddr[10:0]), .din(mem_din), .dout(ppuramdo[ 7:0]) );

    // ========================================================================
    // 8 MB DRAM
    // ========================================================================
	reg  [23:0] psadr,psr_radr;
	wire [3:0]  wmask = wren ? (4'b0001 << maddr[1:0]) : 4'b0000;
	wire [7:0]  psdi  = psr_mdin;
	reg  [7:0]  psr_mdo;
	reg  psram_cs; 
	//wire psram_sig    = maddr[21]==1'b0 && maddr[15:8]==8'h30;
	wire wren         = load_write || write;

	reg  cmd, cmd_en, cmd_run, cmd_bsy;
	reg  [63:0] mlb[0:3];	// psram Buf(64Byte=8Byte x 4)

	wire psram_csu = psram_cs  && (~psram_csd);
	reg  pswr;
	reg  adrchgh, adrchgd, psram_csd, sddtac;
	reg  [5:0]  tmcnt;
	reg  [4:0]  mbp;
	reg  [3:0]  psbp;
	reg         psone, rd_validd, dcsdlyf;
	reg  [24:0] rcadr;
	wire cachematch =0;// No.Cache rcadr[24:5]=={1'b1, psadr[23:5]} ? 1'b1 : 1'b0;

	always @(posedge clk_mctr) begin
		if(reset) begin
			cmd_en <= 0; cmd_bsy <= 0; tmcnt <= 0; rcadr[24] <= 0; 
		end else begin
			psram_cs <= load_write || psr_mt00;	psram_csd <= psram_cs;
			if(psram_csu) begin
				if((~wren && ~cachematch) || wren ) begin
					cmd_en <= 1; cmd <= wren; psbp <= 0; 
					if(~wren) tmcnt <= 22;	// Read.Delay	// burst is 16, the command interval is 15 clock
					else      tmcnt <= 18;	// Write.Delay
					psadr <= psr_maddr; pswr <= wren; cmd_bsy <= 1;
				end else  tmcnt <=  2;	// Cache.Hit
			end
			mbp[4:0] <= psadr[4:0];
			if(cmd_en) cmd_en <= 0;
			//
			if(cmd_bsy) begin
				if(rd_valid) mlb[psbp] <= ps_rddt;
				if((pswr && psbp<4) || rd_valid) psbp <= psbp + 4'd1;
			end
			//
			if(tmcnt==2) begin
				sddtac <= 1;
				if(~pswr) rcadr[24:5] <= {1'b1, psadr[23:5]};	// Cache.Addr set
				else if(cachematch) rcadr[24] <= 0;				// Cache.Addr discard 
			end 
			else if(tmcnt==1) begin 
				cmd_bsy <= 0;
				psr_mdo <=  
					mbp[2:0]==3'h7 ? mlb[mbp[4:3]][63:56] : 
					mbp[2:0]==3'h3 ? mlb[mbp[4:3]][55:48] :
					mbp[2:0]==3'h6 ? mlb[mbp[4:3]][47:40] : 
					mbp[2:0]==3'h2 ? mlb[mbp[4:3]][39:32] :
					mbp[2:0]==3'h5 ? mlb[mbp[4:3]][31:24] : 
					mbp[2:0]==3'h1 ? mlb[mbp[4:3]][23:16] :
					mbp[2:0]==3'h4 ? mlb[mbp[4:3]][15: 8] :
									 mlb[mbp[4:3]][ 7: 0] ; 
			end
			if(tmcnt!=0) tmcnt <= tmcnt - 6'd1;
			if(psr_mt00) sddtac <= 0;
		end
	end

	wire [23:0] ps_addr = {psadr[23:5], 4'h0};
	wire [7:0]  ps_mask = psadr[4:3]==psbp[1:0] ? ps_mptn : 8'hff;
	wire [7:0]  ps_mptn = ~(8'b00000001 << {5'h0,psadr[2:0]});
	wire [63:0] ps_wrdt = {psdi,psdi,psdi,psdi,psdi,psdi,psdi,psdi};			// Write.DataSet(64bit)
	//wire [15:0] psbd    = psdin[15:0]; 

	wire [63:0] ps_rddt;
	wire        rd_valid, clk_mctr, ps_calib, error;
	PSRAM_Memory_Interface_HS_Top_B16 u_psram_top(
		.rst_n(~reset), .clk(clk), .memory_clk(psram_clk), .pll_lock(pll_lock),
		.O_psram_ck(O_psram_ck), .O_psram_ck_n(O_psram_ck_n),
		.IO_psram_rwds(IO_psram_rwds), .IO_psram_dq(IO_psram_dq),
		.O_psram_reset_n(O_psram_reset_n), .O_psram_cs_n(O_psram_cs_n),
		.addr({ps_addr[21:1]}), .wr_data(ps_wrdt), .rd_data(ps_rddt),
		.cmd(cmd), .cmd_en(cmd_en), .data_mask(ps_mask),
		.rd_data_valid(rd_valid), .clk_out(clk_mctr), .init_calib(ps_calib)
		);

endmodule  // MemoryController

// Module reads bytes and writes to proper address in ram.
// Done is asserted when the whole game is loaded.
// This parses iNES headers too.
module Gameload(input clk, input reset,
         input [7:0] indata, input indata_clk,
         output reg [21:0] mem_addr, output [7:0] mem_data, output mem_write,
         output [31:0] mapper_flags,
         output reg done, output state, output error);
  reg [1:0] state = 0;
  reg [7:0] prgsize;
  reg [3:0] ctr;
  reg [7:0] ines[0:15]; // 16 bytes of iNES header
  reg [21:0] bytes_left;
  
  assign error = (state == 3);
  wire [7:0] prgrom = ines[4];
  wire [7:0] chrrom = ines[5];
  assign mem_data = indata;
  assign mem_write = (bytes_left != 0) && (state == 1 || state == 2) && indata_clk;
  
  wire [2:0] prg_size = prgrom <= 1  ? 0 : prgrom <= 2  ? 1 : 
               prgrom <= 4  ? 2 : prgrom <= 8  ? 3 : 
               prgrom <= 16 ? 4 : prgrom <= 32 ? 5 : 
               prgrom <= 64 ? 6 : 7;
  wire [2:0] chr_size = chrrom <= 1  ? 0 : chrrom <= 2  ? 1 : 
               chrrom <= 4  ? 2 : chrrom <= 8  ? 3 : 
               chrrom <= 16 ? 4 : chrrom <= 32 ? 5 : 
               chrrom <= 64 ? 6 : 7;
  
  wire [7:0] mapper = {ines[7][7:4], ines[6][7:4]};
  wire has_chr_ram = (chrrom == 0);
  assign mapper_flags = {16'b0, has_chr_ram, ines[6][0], chr_size, prg_size, mapper};
  always @(posedge clk) begin
    if (reset) begin
      state <= 0;
      done <= 0;
      ctr <= 0;
      mem_addr <= 0;  // Address for PRG
    end else begin
      case(state)
      // Read 16 bytes of ines header
      0: if (indata_clk) begin
           ctr <= ctr + 1;
           ines[ctr] <= indata;
           bytes_left <= {prgrom, 14'b0};
           if (ctr == 4'b1111)
             state <= (ines[0] == 8'h4E) && (ines[1] == 8'h45) && (ines[2] == 8'h53) && (ines[3] == 8'h1A) && !ines[6][2] && !ines[6][3] ? 1 : 3;
         end
      1, 2: begin // Read the next |bytes_left| bytes into |mem_addr|
          if (bytes_left != 0) begin
            if (indata_clk) begin
              bytes_left <= bytes_left - 1;
              mem_addr <= mem_addr + 1;
            end
          end else if (state == 1) begin
            state <= 2;
            mem_addr <= 22'b10_0000_0000_0000_0000_0000;	// Address for CHR // 22'h200000
            bytes_left <= {1'b0, chrrom, 13'b0};
          end else if (state == 2) begin
            done <= 1;
          end
        end
      endcase
    end
  end
endmodule

