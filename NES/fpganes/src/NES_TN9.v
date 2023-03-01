// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.
`timescale 1ns / 1ps
`define UseSDCard
`define UseGamepad

module NES_TN9(
        input 			clk27M,
        // VGA output vga_vo, output vga_ho, output vga_ro, output vga_go, output vga_bo,
        // HDMI
        output       	tmds_clk_n,
        output       	tmds_clk_p,
        output [2:0] 	tmds_d_n,
        output [2:0] 	tmds_d_p,
		// usb
		inout	usb_dm, usb_dp,
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
		// SDCARD
		output wire		SD_CS,		// CS
		output wire 	SD_SCK,		// SCLK
		output wire 	SD_CMD,		// MOSI
		input  wire  	SD_DAT0,	// MISO
        // Debug.I/O
        input 			UART_RXD,
        output 			UART_TXD,
        input  [1:0]	BTN,
        output [5:0]	LED
        );

  assign LED = ~{load_mode, ~conerr, sdrun,load_resct};
  wire breset = ~BTN[1] || ~pll_lock;
  wire reset  =  breset || ~ps_calib;
  wire [15:0] SW = 16'b1111111111111111;

  wire clk       = clk_21;	// 21.6MHz <- 21.477M(Rea)
  wire clk_pixel = clk_25;	// 25.2MHz <- 25.175MHz(Rea)
  wire clk_dram  = clk_173;	// 172.8MHz
  wire clk_21, clk_25, clk_126, clk_173;	// clk_126:125.875
  wire pll_lock1,pll_lock2;
  wire pll_lock = pll_lock1 && pll_lock2;

  Gowin_rPLL  cpuclk( .clkin(clk27M), .clkout(clk_173), .clkoutd(clk_21), .lock(pll_lock1) );
  Gowin_rPLL2 memclk( .clkin(clk27M), .clkout(clk_126), .lock(pll_lock2) );
  Gowin_CLKDIV  u_div_5( .clkout(clk_25),   .hclkin(clk_126), .resetn(pll_lock) );

    wire [3:0] vga_r, vga_g, vga_b;
	wire vdma_tvalid;
	wire vdma_tready;
	wire [24-1:0] vdma_tdata;	// SVO_BITS_PER_PIXEL = 24
	wire [0:0] vdma_tuser;
	wire [3:0] enc_tuser;
	wire hsync_ns,vsync_ns;
	wire hblnk;

    // ========================================================================
    // Audio
    // ========================================================================
  logic clk_audio;		// 49KHz = 25.175/512
  logic [8:0] audio_clk_div;
  always_comb clk_audio = audio_clk_div[8];
always_ff @(posedge clk_pixel) begin
    if (reset) audio_clk_div <= 0;
    else       audio_clk_div <= audio_clk_div + 1;
end

logic [15:0] audio_sample_word [1:0] = '{16'd0, 16'd0};
logic [12:0] tinterval;
wire sound_on = (BTN[0] && tinterval[11]) || (~BTN[0] && tinterval[10]);
always @(posedge clk_audio) begin
  tinterval <= tinterval + 1;
  //if(sound_on) begin
  //  audio_sample_word[0][12:8] <= audio_sample_word[0][12:8] + 5'h1; 
  //  audio_sample_word[1][12:8] <= audio_sample_word[1][12:8] - 5'h1;
  //end
	audio_sample_word[0] <= sound_signal;
	audio_sample_word[1] <= sound_signal;
end

logic [23:0] rgb = 24'd0;
logic [9:0] cx, cy, screen_start_x, screen_start_y, frame_width, frame_height, screen_width, screen_height;
always @(posedge clk_pixel)
  rgb <= {cx == 0 ? ~8'd0 : 8'd0, cy == 0 ? ~8'd0 : 8'd0, cx == screen_width - 1'd1 || cy == screen_width - 1'd1 ? ~8'd0 : 8'd0};

// 640x480 @ 59.94Hz
wire [23:0] rgb_dd = {vga_r,4'h0,vga_g,4'h0,vga_b,4'h0};
hdmia #(.VIDEO_ID_CODE(1), .VIDEO_REFRESH_RATE(59.94), .AUDIO_RATE(48000), .AUDIO_BIT_WIDTH(16)) hdmia(
  .reset(reset),
  .clk_pixel_x5(clk_126),
  .clk_pixel(clk_pixel),
  .clk_audio(clk_audio),
  .rgb(rgb_dd),
  .audio_sample_word(audio_sample_word),
  .tmds_clk_n(tmds_clk_n),
  .tmds_clk_p(tmds_clk_p),
  .tmds_d_n(tmds_d_n),
  .tmds_d_p(tmds_d_p),
  .cx(cx),
  .cy(cy),
  .hsynci(vga_h),
  .vsynci(vga_v),
  .hsync0(hsync0),
  .vsync0(vsync0),
  .frame_width(frame_width),
  .frame_height(frame_height),
  .screen_width(screen_width),
  .screen_height(screen_height)
);

  wire [14:0] doubler_pixel;
  wire doubler_sync, hvlnk, vblnk;
  wire [9:0] vga_hcounter, doubler_x;
  wire [9:0] vga_vcounter, vga_ch, vga_cv;
  
  VgaDriver vga(
    clk, clk_pixel, cx, vga_ch, vga_cv, vga_h, vga_v, vga_r, vga_g, vga_b, 
    vga_hcounter, vga_vcounter, doubler_x, hblnk, vblnk, doubler_pixel,
    doubler_sync, hsync0, vsync0, SW[0]);
  
 // UART(ROM.Load & Debug)
  wire [7:0] uart_data;
  wire [7:0] uart_addr;
  wire       uart_write;
  wire       uart_error;
  UartDemux uart_demux(clk, 1'b0, UART_RXD, uart_data, uart_addr, uart_write, uart_error);

  // load
  //wire [7:0] load_input = uart_data;
  //wire       load_stb   = (uart_addr == 8'h37) && uart_write;
  wire [7:0] load_input = sdrun ? sdohld : uart_data;
  wire       load_stb   = sdrun ? sdrd   : (uart_addr == 8'h37) && uart_write;
  reg  [7:0] load_conf;
  reg  [7:0] load_btn, load_btn_2;
  always @(posedge clk) begin
    if (load_res)             load_conf  <= 0;
    else if(uart_write) begin 
      if (uart_addr == 8'h35) load_conf  <= uart_data;
      if (uart_addr == 8'h40) load_btn   <= uart_data;
      if (uart_addr == 8'h41) load_btn_2 <= uart_data;
    end
  end

  wire [21:0] load_addr;
  wire [7:0] load_write_data;
  wire [1:0] load_state;
  wire load_reset = load_conf[0] || load_res;
  wire load_write;
  wire [31:0] mapper_flags;
  wire load_done, load_fail;
  Gameload load(clk, load_reset, load_input, load_stb,
           load_addr, load_write_data, load_write,
           mapper_flags, load_done, load_state, load_fail,
           SD_CS, SD_SCK, SD_CMD, SD_DAT0 );

  wire clk_test = (load_stb || load_stbd) && clk_mctr;
  reg load_stbd;
  always @(posedge clk) begin
    load_stbd <= load_stb;
  end

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
  wire mem_read_cpu, mem_read_ppu;
  wire mem_write;
  wire [7:0] mem_din_cpu, mem_din_ppu;
  wire [7:0] chr_dout;
  reg [7:0] joypad_bits, joypad_bits2;
  reg [1:0] last_joypad_clock;
  wire [31:0] dbgadr;
  wire [1:0] dbgctr;
  reg [1:0] nes_ce;
  wire [1:0] cpu_cycle_counter; ////
  wire [21:0] prg_linaddr;
  wire [21:0] chr_linaddr;
  wire [7:0]  prg_din;
  wire [15:0] cpu_addr;

  always @(posedge clk) begin
    if (joypad_strobe) begin
      //joypad_bits <= load_btn;
      joypad_bits <= load_btn | btn_nes;
      joypad_bits2 <= load_btn_2;
    end
    if (!joypad_clock[0] && last_joypad_clock[0])
      joypad_bits <= {1'b0, joypad_bits[7:1]};
    if (!joypad_clock[1] && last_joypad_clock[1])
      joypad_bits2 <= {1'b0, joypad_bits2[7:1]};
    last_joypad_clock <= joypad_clock;
  end

  // NES is clocked at every 4th cycle.
  //wire reset_nes = (reset || !load_done || !ps_calib);
  //wire run_mem = (nes_ce == 0) && !reset_nes;
  reg  reset_nes, run_nes;
  always @(posedge clk) begin
    nes_ce <= nes_ce + 1;
    reset_nes <= (reset || !load_done || !ps_calib);
    run_nes   <= (nes_ce == 3) && !reset_nes;
  end

  NES nes(clk, reset_nes, run_nes,
          mapper_flags,
          sample, color,
          joypad_strobe, joypad_clock, {joypad_bits2[0], joypad_bits[0]},
          SW[4:0],
          chr_linaddr,
          mem_read_cpu, mem_din_cpu,
          mem_read_ppu, mem_din_ppu,
          chr_write, chr_dout,
          cycle, scanline,
          cpu_addr,
          prg_linaddr, prg_din, prg_read, prg_write,
          cpu_cycle_counter,
          dbgadr, dbgctr,
          UART_TXD, UART_RXD );

  // This is the memory controller to access the board's PSRAM
  wire [23:0] psr_maddr    = ~load_done ? {2'b00, load_addr} : {2'b00, prg_linaddr};
  wire [23:0] ppu_addr     = ~load_done ? {2'b00, load_addr} : {2'b00, chr_linaddr};
  wire  [7:0] ppu_din      = ~load_done ? load_write_data : chr_dout;
  wire  [7:0] psr_mdin     = ~load_done ? load_write_data : prg_din;
  wire        psr_wen      = ~load_done ? load_write      : prg_write;
  wire        ppu_write    = ~load_done ? load_write      : chr_write;
  wire ppuwrinh = ~(cpu_addr[15] && prg_write);
  wire psr_mt00 = load_done ? nes_ce==2'b00 && cpu_cycle_counter==2'b00 && ppuwrinh :
					          psr_wen && (psr_maddr[21]==1'b0); 
 MemoryController memory(clk, cycle,
         mem_read_cpu, mem_read_ppu,
         ppu_write, ppu_addr, ppu_din,
         mem_din_cpu, mem_din_ppu,
		 // PSRAM
         psr_maddr, psr_mdin, psr_wen,
         psr_mt00, reset, clk_dram, 	// clk(221.6)x8=172.8MHz
		 pll_lock,	ps_calib, clk_mctr,
		 O_psram_ck, O_psram_ck_n,
		 IO_psram_rwds, IO_psram_dq,
		 O_psram_reset_n, O_psram_cs_n );
/*
  reg ramfail;
  always @(posedge clk) begin
    if (load_reset)
      ramfail <= 0;
    else
      ramfail <= ram_busy && load_write || ramfail;
  end
*/
  wire [14:0] pixel_in = pallut[color];
  Hq2x hq2x(clk, clk_pixel, pixel_in, SW[5], 
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
    if(~reset) load_resct <= 0;
    else if(clk_div[21] && ~clk_div21d && ~load_res) load_resct <= load_resct + 1;
  end

	//-----------------------------
	// SD-CARD Reader
	//-----------------------------
	reg  sdrun = 0;
	reg  sdrd;
	reg  [7:0]  sdohld;
`ifdef UseSDCard
	reg  [2:0]  rseq,aseq,aseqc;
	reg  		sdwr,sdcbsy,sdinitd;
	reg  [23:0] sdadr;
	reg  [2:0]  sdra;
	reg  [7:0]  sdin,sdout;
	wire [7:0]  sdout;
	reg  [9:0]  sdbbcnt;

	reg  [7:0]  ineshd [0:7];
	wire [15:0] sdsecdl = {3'b000,{ineshd[4],1'b0} + {1'b0,ineshd[5]},4'h1};	// x512byte 
	reg  [15:0] sdsecct;

	wire clk_spi = clk;	// 21.6MHz
always @(posedge reset or posedge clk_spi) begin
	if(reset) begin
		rseq <= 3'h0; aseq <= 3'h0;	sdcbsy <= 0;
		sdadr <= 0; sdra <= 3'b000; sdrd <= 0; sdwr <= 0;
		sdinitd <= 0; sdrun <= 0; ineshd[4] <= 8'hff; sdsecct <= 0;
	end else begin
		if(sdinit) sdinitd <= 1; 
		if(sdsecdl>=sdsecct) begin
			if(~sdinit && ~sdcbsy && sdinitd) begin 
				sdsecct <= sdsecct + 1; sdcbsy <= 1; sdrun <= 1; aseq <= 1;
			end
		end else sdrun <= 0;
		//
		case(rseq)
			3'h1: begin sdbbcnt <= -1; sdcbsy <= 1; rseq <= 3'h2; end
			3'h2: if(sdbkbsy && !sdinit) rseq <= 3'h3; // INIT & BLOCK Not.Busy 
			3'h3: begin sdra <= 3'b000; sdrd <= 1'b0; sdbbcnt <= sdbbcnt + 1; rseq <= 3'h4; end
			3'h4: if(sdbbcnt[9:0]==10'h200) begin
					if(!sdbkbsy) begin sdcbsy <= 0; rseq <= 0; sdadr <= sdadr + 23'd1; end // Read(512B).End
				  end else
					if(sdrdrdy) begin 
						sdohld <= sdout; sdrd <= 1; rseq <= 3'h3;
						if(sdsecct==1 && sdbbcnt<6) ineshd[sdbbcnt[2:0]] <= sdout;
						//if(sdsecct==sdsecdl && sdbbcnt>=16) sdrun <= 0;
					end 
		endcase;
		//
		case(aseq)
			3'h1: begin sdra <= 3'b010; aseqc <= 3'h0; aseq <= 3'h2; end
			3'h2: begin  aseq <= 3'h3; end
			3'h3: begin  
					case(aseqc)
						3'h0: begin sdcbsy <= 1; sdra <= 3'b010; sdin <= sdadr[ 7: 0]; end
						3'h1: begin sdra <= 3'b011; sdin <= sdadr[15: 8]; end
						3'h2: begin sdra <= 3'b100; sdin <= sdadr[23:16]; end
						3'h3: begin sdra <= 3'b001; sdin <= 8'h00; end
						default: ;
					endcase
					aseq <= 3'h4;
				end
			3'h4: begin sdwr <= 1'b1; aseq <= 3'h5; end 
			3'h5: begin 
					sdwr <= 1'b0; aseqc <= aseqc + 3'h1;
					if(aseqc<3'h3) aseq <= 3'h2;
					else           aseq <= 3'h7; // Address Set.End
				end
			3'h7: begin rseq <= 1; aseq <= 3'h0; end
			default: ;
		endcase

	end
end

// regAddr dataOut   n_rd(Rise)   n_wr(Rise)
//  000    <= sdout  Data.Read    Data.Write              
//  001    <= status              Start.Read(0)/Write(1)  0/1=DataIn/Out
//  010 - 100 Block.Adr SDHC(7:0-15:8-23:16) SDSC(16:9-24:17-31:25)  
//	status(7) <= '1' tx empty  status(6) <= '0' rx ready
//	status(5) <= block_busy;   status(4) <= init_busy;
	wire [7:0]  stout;
	wire sdinit  = stout[4];
	wire sdbkbsy = stout[5];
	wire sdrdrdy = stout[6];
sd_controller	sd1 (
	.clk(clk_spi), .n_reset(!reset), .regAddr(sdra),
	.n_wr(!sdwr), .n_rd(!sdrd),
	.dataIn(sdin), .dataOut(sdout), .status(stout),
	.sdCS(SD_CS), .sdMOSI(SD_CMD), .sdMISO(SD_DAT0), .sdSCLK(SD_SCK),
	.driveLED()
);
`endif

	//-----------------------------
	// USB_KB
	//-----------------------------
	wire [7:0] btn_nes;
	wire       conerr;
`ifdef UseGamepad
	wire usbclk = uclko; // 125.875MHz/10.5=11.988MHz 
	reg  [3:0] uclkct;
	reg        uclkcta, uclko;
	always @(posedge clk_126) begin
		if(uclkct<={3'b100,uclkcta}) uclkct <= uclkct + 1;
		else begin uclkct <=0; uclkcta <= ~uclkcta; end
		if(uclkct>=5) uclko <= 1;
		else          uclko <= 0;
	end

	ukp2nes ukp2nes(
		.usbclk(usbclk),		// 12MHz
		.usbrst_n(~reset),		// reset
		.usb_dm(usb_dm), 
		.usb_dp(usb_dp),
		.btn_nes(btn_nes),
		.conerr(conerr) );
`endif
endmodule

// Asynchronous PSRAM controller for byte access
// After outputting a byte to read, the result is available 70ns later.
module MemoryController(
        input clk,
		input [8:0] cycle,
        input read_cpu,             // Set to 1 to read from RAM
        input read_ppu,             // Set to 1 to read from RAM
        input write_ppu,            // Set to 1 to write to RAM
        input [23:0] addr_ppu,      // Address to read / write
        input [7:0] din_ppu,        // Data to write
        output reg [7:0] dout_cpu,  // Last read data a
        output reg [7:0] dout_ppu,  // Last read data b
		// PSRAM(Internal connection)
		input  wire [23:0]  psr_maddr,
		input  wire [7:0]   psr_mdin,
		input               psr_wen,
		input				psr_mt00,
		input  wire			reset,
		input  wire			clk_dram,
		input  wire			pll_lock,
		output wire			ps_calib,
		output wire			clk_mctr,
		output wire [1:0] 	O_psram_ck,
		output wire [1:0] 	O_psram_ck_n,
		inout  wire [1:0] 	IO_psram_rwds,
		inout  wire [15:0]	IO_psram_dq,
		output wire [1:0] 	O_psram_reset_n,
		output wire [1:0] 	O_psram_cs_n
    );
        
  wire cpumemCS = psr_maddr[21]   ==1'b0 || cpucrtCS;
  wire cpuramCS = psr_maddr[21:18]==4'b1110; 
  wire cpucrtCS = psr_maddr[21:18]==4'b1111;
  wire ppumemCS = ppu_maddr[21:20]==2'b10; 
  wire ppuramCS = ppu_maddr[21:18]==4'b1100; 
  wire [7:0] cpumemdo, ppumemdo, cpuramdo, cpucrtdo, ppuramdo; 

  reg [23:0] ppu_maddr;
  reg [7:0]  ppu_mem_din;
  reg ppuwr;
  wire run_ppu = read_ppu || write_ppu;
  reg  run_ppud, read_ppud;;
  always @(posedge clk) begin
    run_ppud <= run_ppu; read_ppud <= read_ppu;
      if (run_ppu && ~run_ppud) begin
        ppu_maddr <= addr_ppu; ppu_mem_din <= din_ppu; ppuwr <= write_ppu; end
      if (|run_ppu && run_ppud) begin
        if (read_ppud) begin 
			if(ppuramCS) dout_ppu <= ppuramdo; 
		end
		ppuwr <= 0;
    end
	if(ppumemCS) dout_ppu <= ps_mdo1;
	//
	if(cpuramCS)      dout_cpu <= cpuramdo;
	else
		if(ps_dtac0 && cpumemCS) dout_cpu <= ps_mdo0;
  end

    // ========================================================================
    // SRAM
    // ========================================================================
    Gowin_SP_2KBx8 cpuram(
        .clk(clk), .reset(1'b0), .oce(1'b1), .ce(cpuramCS), .wre(psr_wen),
        .ad(psr_maddr[10:0]), .din(psr_mdin), .dout(cpuramdo[ 7:0]) );
    Gowin_SP_2KBx8 ppuram(
        .clk(clk), .reset(1'b0), .oce(1'b1), .ce(ppuramCS), .wre(ppuwr),
        .ad(ppu_maddr[10:0]), .din(ppu_mem_din), .dout(ppuramdo[ 7:0]) );
    // ========================================================================
    // 4 MB(8bit) DRAM0
    // ========================================================================
	reg  [23:0] psadr0;
	reg  [7:0]  ps_mdo0;
	wire [7:0]  psdi0  = psr_mdin;

	reg  psram0_cs; 
	wire psram0_csu = psram0_cs  && (~psram0_csd);
	reg  pswr0;
	reg  psram0_csd, ps_dtac0;
	reg  cmd0, cmd_en0, cmd_bsy0;
	reg  [31:0] mlb0[0:3];	// psram Buf(16Byte=4Byte x 4)
	reg  [5:0]  tmcnt0;
	reg  [3:0]  mbp0, psbp0;

	always @(posedge clk_mctr) begin
		if(reset) begin
			cmd_en0 <= 0; cmd_bsy0 <= 0; tmcnt0 <= 0; //rcadr[24] <= 0;
		end else begin

			psram0_cs <= psr_mt00; 
			psram0_csd <= psram0_cs;
			if(psram0_csu) begin
				cmd_en0 <= 1; cmd0 <= psr_wen; psbp0 <= 0; 
				if(~psr_wen) tmcnt0 <= 22;	// Read.Delay	// burst is 16, the command interval is 15 clock
				else         tmcnt0 <= 18;	// Write.Delay
				psadr0 <= psr_maddr; pswr0 <= psr_wen; cmd_bsy0 <= 1;
			end
			mbp0[3:0] <= psadr0[3:0];
			if(cmd_en0) cmd_en0 <= 0;
			//
			if(cmd_bsy0) begin
				if(rd_valid0) mlb0[psbp0] <= ps_rddt0;
				if((pswr0 && psbp0<4) || rd_valid0) psbp0 <= psbp0 + 4'd1;
			end
			//
			if(tmcnt0==2) ps_dtac0 <= 1;
			else if(tmcnt0==1) begin 
				if(~pswr0) ps_mdo0 <=  
					mbp0[1:0]==3'h3 ? mlb0[mbp0[3:2]][31:24] :
					mbp0[1:0]==3'h2 ? mlb0[mbp0[3:2]][23:16] :
					mbp0[1:0]==3'h1 ? mlb0[mbp0[3:2]][15: 8] :
									  mlb0[mbp0[3:2]][ 7: 0] ; 
				cmd_bsy0 <= 0;
			end
			if(tmcnt0!=0) tmcnt0 <= tmcnt0 - 6'd1;
			else          ps_dtac0 <= 0;
		end
	end

	wire [23:0] ps_addr0 = {psadr0[23:4], 3'h0};
	wire [7:0]  ps_mask0 = psadr0[3:2]==psbp0[1:0] ? ps_mptn0 : 8'hff;
	wire [7:0]  ps_mptn0 = ~(8'b00000001 << {6'h0,psadr0[1:0]});
	wire [31:0] ps_wrdt0 = {psdi0,psdi0,psdi0,psdi0};			// Write.DataSet(32bit)
	wire [31:0] ps_rddt0;
	wire        rd_valid0, clk_mctr, ps_calib, error;
	reg         ps_calibd;

    // ========================================================================
    // 4 MB(8bit) DRAM1
    // ========================================================================
	reg  [23:0] psadr1;
	reg  [7:0]  ps_mdo1;
	wire [7:0]  psdi1  = din_ppu;

	reg  psram1_cs; 
	wire psram1_csu = psram1_cs  && (~psram1_csd);
	reg  pswr1,wppud,wppudd;
	reg  psram1_csd, ps_dtac1;
	reg  cmd1, cmd_en1, cmd_bsy1;
	reg  [31:0] mlb1[0:3];	// psram Buf(16Byte=4Byte x 4)
	reg  [5:0]  tmcnt1;
	reg  [3:0]  mbp1, mbp2, psbp1;
	reg  [1:0]  bgnsel;

	always @(posedge clk_mctr) begin
		if(reset) begin
			cmd_en1 <= 0; cmd_bsy1 <= 0; tmcnt1 <= 0;
		end else begin

			psram1_cs <= read_ppu || (write_ppu && addr_ppu[21:20]==2'b10); 
			psram1_csd <= psram1_cs;
			wppud <= write_ppu;
			if(~ppumemCS) bgnsel <= 0;
			if(write_ppu && ~wppud) wppudd <= 1; 
			if(psram1_csu) begin
				cmd_en1 <= 1; cmd1 <= write_ppu; psbp1 <= 0; 
				if(~write_ppu) tmcnt1 <= 22;	// Read.Delay	// burst is 16, the command interval is 15 clock
				else           tmcnt1 <= 18;	// Write.Delay
				psadr1 <= addr_ppu; pswr1 <= write_ppu; cmd_bsy1 <= 1;
				wppudd <= 0;
			end
			mbp1[3:0] <= psadr1[3:0]; mbp2[3:0] <= psadr1[3:0]+4'd8;
			if(cmd_en1) cmd_en1 <= 0;
			//
			if(cmd_bsy1) begin
				if(rd_valid1) mlb1[psbp1] <= ps_rddt1;
				if((pswr1 && psbp1<4) || rd_valid1) psbp1 <= psbp1 + 4'd1;
			end
			//
			if(tmcnt1==2) ps_dtac1 <= 1;
			else if(tmcnt1==1) begin 
				if(~pswr1) 
						ps_mdo1 <=  
						mbp1[1:0]==3'h3 ? mlb1[mbp1[3:2]][31:24] :
						mbp1[1:0]==3'h2 ? mlb1[mbp1[3:2]][23:16] :
						mbp1[1:0]==3'h1 ? mlb1[mbp1[3:2]][15: 8] :
										  mlb1[mbp1[3:2]][ 7: 0] ; 
				if(bgnsel!=2'b11) bgnsel <= bgnsel + 1;
				cmd_bsy1 <= 0;
			end
			if(tmcnt1!=0) tmcnt1 <= tmcnt1 - 6'd1;
			if(psr_mt00) ps_dtac1 <= 0;
		end
	end

	wire [23:0] ps_addr1 = {psadr1[23:4], 3'h0};
	wire [7:0]  ps_mask1 = psadr1[3:2]==psbp1[1:0] ? ps_mptn1 : 8'hff;
	wire [7:0]  ps_mptn1 = ~(8'b00000001 << {6'h0,psadr1[1:0]});
	wire [31:0] ps_wrdt1 = {psdi1,psdi1,psdi1,psdi1};			// Write.DataSet(32bit)
	wire [31:0] ps_rddt1;
	wire        rd_valid1;

    // ========================================================================
    // 4 MB(8bit)x2 DRAM
    // ========================================================================
	wire ps_calib0,ps_calib1;
	assign ps_calib = ps_calib0 && ps_calib1;
	PSRAM_Memory_Interface_HS_WB16 your_instance_name(
		.clk(clk), .rst_n(~breset), .memory_clk(clk_dram), .pll_lock(pll_lock),
		.clk_out(clk_mctr), .init_calib0(ps_calib0), .init_calib1(ps_calib1),
		.O_psram_ck(O_psram_ck), .O_psram_ck_n(O_psram_ck_n),
		.O_psram_reset_n(O_psram_reset_n), .O_psram_cs_n(O_psram_cs_n),
		.IO_psram_rwds(IO_psram_rwds), .IO_psram_dq(IO_psram_dq),
		.cmd0(cmd0),  .cmd_en0(cmd_en0),  .data_mask0(ps_mask0),  .rd_data_valid0(rd_valid0),
		.addr0(ps_addr0[20:0]), .wr_data0(ps_wrdt0), .rd_data0(ps_rddt0),
		.cmd1(cmd1), .cmd_en1(cmd_en1), .data_mask1(ps_mask1), .rd_data_valid1(rd_valid1),
		.addr1({1,b0,ps_addr1[19:0]}), .wr_data1(ps_wrdt1), .rd_data1(ps_rddt1)
	);

endmodule  // MemoryController

    // ========================================================================
    // Gameload
    // ========================================================================
	// Module reads bytes and writes to proper address in ram.
	// Done is asserted when the whole game is loaded.
	// This parses iNES headers too.
module Gameload(input clk, input reset,
         input [7:0] indata, input indata_stb,
         output reg [21:0] load_addr, output [7:0] load_data, output load_write,
         output [31:0] mapper_flags,
         output reg done, output state, output error,
		 output wire		SD_CS,		// CS
		 output wire 	SD_SCK,		// SCLK
		 output wire 	SD_CMD,		// MOSI
		 input  wire  	SD_DAT0		// MISO
);
  reg [1:0] state = 0;
  reg [7:0] prgsize;
  reg [3:0] ctr;
  reg [7:0] ines[0:15]; // 16 bytes of iNES header
  reg [21:0] bytes_left;
  
  assign error = (state == 3);
  wire [7:0] prgrom = ines[4];
  wire [7:0] chrrom = ines[5];
  assign load_data  = indata;
  assign load_write = (bytes_left != 0) && (state == 1 || state == 2) && indata_stb;
  
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
  assign mapper_flags = {8'b0, ines[7][3:0], ines[6][3:0],has_chr_ram, ines[6][0], chr_size, prg_size, mapper};
  always @(posedge clk) begin
    if (reset) begin
      state <= 0; done <= 0; ctr <= 0;
      load_addr <= 0;  // Address for PRG
    end else begin
      case(state)
      // Read 16 bytes of ines header
      0: if (indata_stb) begin
           ctr <= ctr + 1;
           ines[ctr] <= indata;
           bytes_left <= {prgrom, 14'b0};
           if (ctr == 4'b1111)
             state <= (ines[0] == 8'h4E) && (ines[1] == 8'h45) && (ines[2] == 8'h53) && (ines[3] == 8'h1A) && !ines[6][2] && !ines[6][3] ? 1 : 3;
         end
      1, 2: begin // Read the next |bytes_left| bytes into |load_addr|
          if (bytes_left != 0) begin
            if (indata_stb) begin
              bytes_left <= bytes_left - 1;
              load_addr <= load_addr + 1;
            end
          end else if (state == 1) begin
            state <= 2;
            load_addr <= 22'b10_0000_0000_0000_0000_0000;	// Address for CHR // 22'h200000
            bytes_left <= {1'b0, chrrom, 13'b0};
          end else if (state == 2) begin
            done <= 1;
          end
        end
      endcase
    end
  end

endmodule

