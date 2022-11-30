//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: ddr_186.v
// Description: Part of the Next186 SoC PC project, main system, RAM interface
// Version 2.0
// Creation date: Apr2014
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2012 Nicolae Dumitrache
// 
// This source file may be used and distributed without 
// restriction provided that this copyright statement is not 
// removed from the file and that any derivative work contains 
// the original copyright notice and the associated disclaimer.
// 
// This source file is free software; you can redistribute it 
// and/or modify it under the terms of the GNU Lesser General 
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any 
// later version. 
// 
// This source is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied 
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
// PURPOSE. See the GNU Lesser General Public License for more 
// details. 
// 
// You should have received a copy of the GNU Lesser General 
// Public License along with this source; if not, download it 
// from http://www.opencores.org/lgpl.shtml 
// 
///////////////////////////////////////////////////////////////////////////////////
// Additional Comments: 
//
// 25Apr2012 - added SD card SPI support
// 15May2012 - added PIT 8253 (sound + timer INT8)
// 24May2012 - added PIC 8259  
// 28May2012 - RS232 boot loader does not depend on CPU speed anymore (uses timer0)
//	01Feb2013 - ADD 8042 PS2 Keyboard & Mouse controller
// 27Feb2013 - ADD RTC
// 04Apr2013 - ADD NMI, port 3bc for 8 leds
//
// Feb2014 - ported for SDRAM, added USB host serial communication
// 		   - added video modes 0dh, 12h
//		   - support for ModeX
// Jul2017 - high speed COM (up to 115200*8)
// Aug2017 - added Line Compare Register
// Sep2017 - VGA barrel shifter, NMI on IRQ
// Oct2017 - added VGA VDE register, improved 400/480 lines configuration based on VDE
//////////////////////////////////////////////////////////////////////////////////

/* ----------------- implemented ports -------------------
0001 - BYTE write: bit01=ComSel (00=DCE, 01=EXT, 1x=HOST), bit2=Host reset, bit43=COM divider shift right bits
0001 - WORD write: bit0=auto cache flush
	  
0002 - 32 bit CPU data port R/W, lo first
0003 - 32 bit CPU command port W
		16'b00000cvvvvvvvvvv = set r/w pointer - 256 32bit integers, 1024 instructions. c=1 for code write, 0 for data read/write
		16'b100wwwvvvvvvvvvv = run ip - 1024 instructions, 3 bit data window offs
0004 - I2C interface: W= {xxxx,cccc,dddddddd}, R={dddddddd,xxxxxxxx}
0006 - WORD write: NMIonIORQ low port address. NMI if (IORQ and PORT_ADDR >= NMIonIORQ_LO and PORT_ADDR <= NMIonIORQ_HI)
0007 - WORD write: NMIonIORQ high port address

0021 - interrupt controller master data port. R/W interrupt mask, 1disabled/0enabled (bit0=timer, bit1=keyboard, bit4=COM1) 
00a1 - interrupt controller slave data port. R/W interrupt mask, 1disabled/0enabled (bit0=RTC, bit4=mouse) 

0040-0043 - PIT 8253 ports

0x60, 0x64 - 8042 keyboard/mouse data and cfg

0061 - bits1:0 speaker on/off (write only)

0070 - RTC (16bit write only counter value). RTC is incremented with 1Mhz and at set value sends INT70h, then restart from 0
		 When set, it restarts from 0. If the set value is 0, it will send INT70h only once, if it was not already 0
			
080h-08fh - memory map: bit9:0=64 Kbytes DDRAM segment index (up to 1024 segs = 64MB), mapped over 
								PORT[3:0] 80186 addressable segment
								
0200h-020fh - joystick port (GPIO) - pullup
		WORD/BYTE r/w: bits[15:8] = 0 for input, 1 for output, bits[7:0]=data

0378 - sound port: 8bit=Covox & DSS compatible, 16bit = stereo L+R - fifo sampled at 44100Hz
		 bit4 of port 03DA is 1 when the sound queue is full. If it is 0, the queue may accept up to 1152 stereo samples (L + R), so 2304 16bit writes.

0379 - parallel port control: bit6 = 1 when DSS queue is full

0388,0389,038A,038B - Adlib ports: 0388=bank1 addr, 0389=bank1 data, 038A=bank2 addr, 038B=bank2 data

03C0 - VGA mode 
		index 00h..0Fh  = EGA palette registers
		index 10h:
			bit0 = graphic(1)/text(0)
			bit3 = text mode flash enabled(1)
			bit4 = half mode (EGA)
			bit5 = ppm - pixel panning mode
			bit6 = vga mode 13h(1)
			bit7 = P54S - 1 to use color select 5-4 from reg 14h
		index 13h: bit[3:0] = hrz pan
		index 14h: bit[3:2] = color select 7-6, bit[1:0] = color select 5-4

03C4, 03C5 (Sequencer registers) - idx2[3:0] = write plane, idx4[3]=0 for planar (rw)

03C6 - DAC mask (rw)
03C7 - DAC read index (rw)
03C8 - DAC write index (rw)
03C9 - DAC color (rw)
03CB - font: write WORD = set index (8 bit), r/w BYTE = r/w font data

03CE, 03CF (Graphics registers) (rw)
	0: setres <= din[3:0];
	1: enable_setres <= din[3:0];
	2: color_compare <= din[3:0];
	3: logop <= din[4:3];
	4: rplane <= din[1:0];
	5: rwmode <= {din[3], din[1:0]};
	7: color_dont_care <= din[3:0];
	8: bitmask <= din[7:0]; (1=CPU, 0=latch)

03DA - read VGA status, bit0=1 on vblank or hblank, bit1=RS232in, bit2=i2cackerr, bit3=1 on vblank, bit4=sound queue full, bit5=DSP32 halt, bit6=i2cack, bit7=1 always, bit15:8=SD SPI byte read
		 write bit7=SD SPI MOSI bit, SPI CLK 0->1 (BYTE write only), bit8 = SD card chip select (WORD write only)
		 also reset the 3C0 port index flag

03B4, 03D4 - VGA CRT write index:  
										07h: bit1 = VDE8, bit4 = LCR8, bit6 = VDE9
										09h: bit6 = LCR9
										0Ah(bit 5 only): hide cursor
										0Ch: HI screen offset
										0Dh: LO screen offset
										0Eh: HI cursor pos
										0Fh: LO cursor pos
										12h: VDE[7:0]
										13h: scan line offset
										18h: Line Compare Register (LCR)
03B5, 03D5 - VGA CRT read/write data

03f8-03fb - COM1 ports
03fc-03fe - com0 ports(For.Debug)
03ff        User.Button
*/

`timescale 1ns / 1ps
//`define NoCPU

module system (
		 input 	CLK_50MHZ,
		 input clk_pixel,
		 output reg [5:0] VGA_R, VGA_G, VGA_B,
		 output wire      VGA_HSYNC, VGA_VSYNC, VGA_hblnk,
		 output frame_on,
		 input BTN_RESET,	// Reset
		 input BTN_NMI,		// NMI
		 input BTN_USER,	// USER
		 output [7:0]LED,	// HALT
		 input  RS232_DCE_RXD, RS232_EXT_RXD,
		 output RS232_DCE_TXD, RS232_EXT_TXD,
		 input  RS232_HOST_RXD,
		 output RS232_HOST_TXD,
		 output reg RS232_HOST_RST,

		 // PSRAM(Internal connection)
		 input  wire		psram_clk,
		 input  wire		pll_lock,
		 output wire [1:0] 	O_psram_ck,
		 output wire [1:0] 	O_psram_ck_n,
		 inout  wire [1:0] 	IO_psram_rwds,
		 inout  wire [15:0]	IO_psram_dq,
		 output wire [1:0] 	O_psram_reset_n,
		 output wire [1:0] 	O_psram_cs_n,

		 output reg  SD_n_CS = 1'b1,
		 output wire SD_DI,
		 output reg  SD_CK = 0,
		 input  wire SD_DO,
		 
		 output AUD_L, AUD_R,
	 	 inout PS2_CLK1, PS2_CLK2,
		 inout PS2_DATA1, PS2_DATA2,
		 
		 //inout [7:0]GPIO,
		 output [7:0]GPIO,
		 output I2C_SCL,
		 inout I2C_SDA
    );

	initial SD_n_CS = 1'b1;
	
	wire [15:0]cntrl0_user_input_data;//i
	wire [1:0]sys_cmd_ack;
	wire sys_rd_data_valid;
	wire sys_wr_data_valid;
	wire ps_calib; // psram init.end   
	wire [15:0]sys_DOUT;	// sdr data out
	wire [31:0] DOUT;
	wire [15:0]CPU_DOUT;
	wire [15:0]PORT_ADDR;
	wire [31:0] DRAM_dout;
	wire [20:0] ADDR;
	wire IORQ;
	wire WR;
	wire INTA;
	wire WORD;
	wire [3:0] RAM_WMASK;
	wire hblnk;
	wire vblnk;
	wire [9:0]hcount;
	wire [9:0]vcount;
	reg [3:0]vga_hrzpan = 0;
	wire [3:0]vga_hrzpan_req;
	wire [9:0]hcount_pan = hcount + vga_hrzpan - 17;
	reg FifoStart = 1'b0;	// fifo not empty
	wire displ_on = !(hblnk | vblnk | !FifoStart);
	wire [17:0]DAC_COLOR;
	wire [8:0]fifo_wr_used_words;
	wire AlmostFull;
	wire AlmostEmpty;
	wire clk_cpu;
	wire clk_dsp;
	wire CPU_CE;	// CPU clock enable
	wire CE;
	wire CE_186;
	wire ddr_rd; 
	wire ddr_wr;
	wire TIMER_OE = PORT_ADDR[15:2] == 14'b00000000010000;	//   40h..43h
	wire VGA_DAC_OE = PORT_ADDR[15:4] == 12'h03c && PORT_ADDR[3:0] <= 4'h9; // 3c0h..3c9h	
	wire LED_PORT = PORT_ADDR[15:0] == 16'h03bc;
	wire SPEAKER_PORT = PORT_ADDR[15:0] == 16'h0061;
	wire MEMORY_MAP = PORT_ADDR[15:4] == 12'h008;
	wire VGA_FONT_OE = PORT_ADDR[15:0] == 16'h03cb;
	wire AUX_OE = PORT_ADDR[15:0] == 16'h0001;
	wire I2C_SELECT = PORT_ADDR[15:0] == 16'h0004;
	wire INPUT_STATUS_OE = PORT_ADDR[15:0] == 16'h03da;
	wire VGA_CRT_OE = (PORT_ADDR[15:1] == 15'b000000111011010) || (PORT_ADDR[15:1] == 15'b000000111101010); // 3b4h, 3b5h, 3d4h, 3d5h
	wire RTC_SELECT = PORT_ADDR[15:0] == 16'h0070;
	wire VGA_SC = PORT_ADDR[15:1] == (16'h03c4 >> 1); // 3c4h, 3c5h
	wire VGA_GC = PORT_ADDR[15:1] == (16'h03ce >> 1); // 3ceh, 3cfh
	wire PIC_OE = PORT_ADDR[15:8] == 8'h00 && PORT_ADDR[6:0] == 7'b0100001;	// 21h, a1h
	wire KB_OE = PORT_ADDR[15:4] == 12'h006 && {PORT_ADDR[3], PORT_ADDR[1:0]} == 3'b000; // 60h, 64h
	wire JOYSTICK = PORT_ADDR[15:4] == 12'h020; // 0x200-0x20f
	wire PARALLEL_PORT = PORT_ADDR[15:0] == 16'h0378;
	wire PARALLEL_PORT_CTL = PORT_ADDR[15:0] == 16'h0379;
	wire CPU32_PORT = PORT_ADDR[15:1] == (16'h0002 >> 1); // port 1 for data and 3 for instructions
	wire COM0_PORT = PORT_ADDR[15:3] == (16'h03fc >> 3);
	wire COM1_PORT = PORT_ADDR[15:3] == (16'h03f8 >> 3);
	wire OPL3_PORT = PORT_ADDR[15:2] == (16'h0388 >> 2); // 0x388 .. 0x38b
	wire NMI_IORQ_PORT = PORT_ADDR[15:1] == (16'h0006 >> 1); // 6, 7
 	wire [7:0]VGA_DAC_DATA;
	wire [7:0]VGA_CRT_DATA;
	wire [7:0]VGA_SC_DATA;
	wire [7:0]VGA_GC_DATA;
	wire [15:0]PORT_IN;
	wire [7:0]TIMER_DOUT;
	wire [7:0]KB_DOUT;
	wire [7:0]PIC_DOUT;
	wire [7:0]COM0_DOUT;
	wire [7:0]COM1_DOUT;
	wire HALT;
	wire CLK14745600; // RS232 clk
 	wire CLK44100x256;
	wire sq_full; // sound queue full
	wire dss_full;
	wire [15:0]cpu32_data;
	wire cpu32_halt;
		
	reg [1:0]cntrl0_user_command_register = 0;
	reg [16:0]vga_ddr_row_col = 0; // video buffer offset (multiple of 4)
	reg s_prog_full;
	reg s_prog_empty;
	reg s_ddr_rd = 1'b0;
	reg s_ddr_wr = 1'b0;
	reg crw = 0;	// 1=cache read window
	reg s_RS232_DCE_RXD;
	reg s_RS232_HOST_RXD;
	reg [18:0]rstcount = 0;
	reg [18:0]s_displ_on = 0;	// clk_25 delayed displ_on
	reg [2:0]vga13 = 0; 		// 1 for mode 13h
	reg [2:0]vgatext = 0;  		// 1 for text mode
	reg [2:0]v240 = 0;
	reg [2:0]planar = 0;
	reg [2:0]half = 0;
	reg [0:0]repln_graph = 0;
	wire vgaflash;
	reg flashbit = 0;
	reg [5:0]flashcount = 0;
	wire [5:0]char_row = vcount[8:3] >> !half[2];
	wire [3:0]char_ln = {(vcount[3] & !half[1]), vcount[2:0]};
	wire [11:0]charcount = {char_row, 4'b0000} + {char_row, 6'b000000} + hcount_pan[9:3];
	wire [31:0]fifo_dout32;
	wire [15:0]fifo_dout = (vgatext[1] ? hcount_pan[3] : vga13[1] ? hcount_pan[2] : hcount_pan[1]) ? fifo_dout32[31:16] : fifo_dout32[15:0];

	reg [8:0]vga_ddr_row_count = 0;
	reg [2:0]max_read;
	reg [4:0]col_counter;
	wire vga_end_frame = vga_ddr_row_count == (v240[0] ? 479 : 399);
	reg [3:0]vga_repln_count = 0; // repeat line counter
	wire [3:0]vga_repln = vgatext[0] ? (half[0] ? 7 : 15) : {3'b000, repln_graph[0]};//(vga13[0] | half[0]) ? 1 : 0;
	reg [7:0]vga_lnbytecount = 0; // line byte count (multiple of 4)
	wire [4:0]vga_lnend = (vgatext[0] | half[0]) ? 6 : (vga13[0] | planar[0]) ? 11 : 21; // multiple of 32 (SDRAM resolution = 32)
	reg [11:0]vga_font_counter = 0;
	reg [7:0]vga_attr;
	reg [4:0]RTCDIV25 = 0;
	reg [1:0]RTCSYNC = 0;
	reg [15:0]RTC = 0;
	reg [15:0]RTCSET = 0;
	wire RTCEND = RTC == RTCSET;
	wire RTCDIVEND = RTCDIV25 == 24;
	wire [14:0]cache_hi_addr;
	wire [8:0]memmap;
	wire [8:0]memmap_mux;
	wire [7:0]font_dout;
	wire [7:0]VGA_FONT_DATA;
	wire vgatextreq;
	wire vga13req;
	wire planarreq;
	wire replnreq;
	wire halfreq;
	wire oncursor;
	wire [4:0]crs[1:0];
	wire [11:0]cursorpos;
	wire [15:0]scraddr;
	reg flash_on;
	reg speaker_on = 1'b0;
	reg [9:0]rNMI = 0;
	wire [2:0]shift = half[1] ? ~hcount_pan[3:1] : ~hcount_pan[2:0];
	wire [2:0]pxindex = -hcount_pan[2:0];
	wire [3:0]EGA_MUX = vgatext[1] ? (font_dout[pxindex] ^ flash_on) ? vga_attr[3:0] : {vga_attr[7] & ~vgaflash, vga_attr[6:4]} :
							  {fifo_dout32[{2'b11, shift}], fifo_dout32[{2'b10, shift}], fifo_dout32[{2'b01, shift}], fifo_dout32[{2'b00, shift}]};
	wire [7:0]VGA_INDEX;						  
	reg [3:0]exline = 4'b0000; // extra 8 dwords (32 bytes) for screen panning
	wire vrdon = s_displ_on[~vga_hrzpan];
	wire vrden = (vrdon || exline[3]) && ((vgatext[1] | half[1]) ? &hcount_pan[3:0] : (vga13[1] | planar[1]) ? &hcount_pan[2:0] : &hcount_pan[1:0]);
	reg s_vga_endline;
	reg s_vga_endscanline = 1'b0;
	reg s_vga_endframe;
	reg [23:0]sdraddr;
	wire [3:0]vga_wplane;
	wire [1:0]vga_rplane;
	wire [7:0]vga_bitmask;	// write 1=CPU, 0=VGA latch
	wire [2:0]vga_rwmode;
	wire [3:0]vga_setres;
	wire [3:0]vga_enable_setres;
	wire [1:0]vga_logop;
	wire [3:0]vga_color_compare;
	wire [3:0]vga_color_dont_care;
	wire [2:0]vga_rotate_count;
	wire [7:0]vga_offset;
	reg [2:0]auto_flush = 3'b000;
	wire ppm; 			// pixel panning mode
	wire [9:0]lcr; 		// line compare register
	wire [9:0]vde;		// vertical display end
	wire sdon = s_displ_on[17+vgatext[1]] & (vcount <= vde);
	wire preset = BTN_RESET || ~rstcount[18] || ~ps_calib;

// Com interface
	reg [1:0]ComSel = 2'b00; // 00:COM1=RS232_DCE, 01: COM1=RS232_EXT, 1x: COM1=RS232_HOST
	//wire RX = ComSel[1] ? RS232_HOST_RXD : ComSel[0] ? RS232_EXT_RXD : RS232_DCE_RXD;	
	wire RX = RS232_DCE_RXD;	
	wire TX;
	//assign RS232_DCE_TXD = ComSel[1:0] == 2'b00 ? TX : 1'b1;
	assign RS232_DCE_TXD = TX;
	assign RS232_EXT_TXD = ComSel[1:0] == 2'b01 ? TX : 1'b1;
	assign RS232_HOST_TXD = ComSel[1] ? TX : 1'b1;
	reg [1:0]COMBRShift = 2'b00; 
	
//// SD interface
//	reg [7:0]SDI;
//	assign SD_DI = CPU_DOUT[7];

// GPIO interface	// Output only IO.Adrd:0x200-0x20f(WORD)
	reg [7:0]GPIOState = 8'h00;
	reg [7:0]GPIOData;
	reg [7:0]GPIODout = 8'h00;
	assign GPIO = GPIODout;

// I2C interface
	reg [11:0]i2c_cd = 0;
	wire [7:0]i2cdout;
	wire i2cack;
	wire i2cackerr;
	
// opl3 interface
    wire [7:0]opl32_data;
    wire [15:0]opl3left;
    wire [15:0]opl3right;
    wire stb44100;

// NMI on IORQ
	reg [15:0]NMIonIORQ_LO = 16'h0001;
	reg [15:0]NMIonIORQ_HI = 16'h0000;

	assign LED = {1'b0, !cpu32_halt, AUD_L, AUD_R, planarreq, |sys_cmd_ack, ~SD_n_CS, HALT};
	assign frame_on = s_displ_on[16+vgatext[1]];
	
	assign PORT_IN[15:8] = 
		({8{MEMORY_MAP}} & {7'b0000000, memmap[8]}) |
		({8{INPUT_STATUS_OE}} & SDI) |
		({8{CPU32_PORT}} & cpu32_data[15:8]) | 
		({8{JOYSTICK}} & GPIOState) |
		({8{I2C_SELECT}} & i2cdout);

	assign PORT_IN[7:0] = //INPUT_STATUS_OE ? {2'b1x, cpu32_halt, sq_full, vblnk, s_RS232_HOST_RXD, s_RS232_DCE_RXD, hblnk | vblnk} : CPU32_PORT ? cpu32_data[7:0] : slowportdata;
							 ({8{VGA_DAC_OE}} & VGA_DAC_DATA) |
							 ({8{VGA_FONT_OE}}& VGA_FONT_DATA) |
							 ({8{KB_OE}} & KB_DOUT) |
							 ({8{INPUT_STATUS_OE}} & {1'b1, i2cack, cpu32_halt, sq_full, vblnk, i2cackerr, s_RS232_DCE_RXD, hblnk | vblnk}) | 
							 ({8{VGA_CRT_OE}} & VGA_CRT_DATA) | 
							 ({8{MEMORY_MAP}} & {memmap[7:0]}) |
							 ({8{TIMER_OE}} & TIMER_DOUT) |
							 ({8{PIC_OE}} & PIC_DOUT) |
							 ({8{VGA_SC}} & VGA_SC_DATA) |
							 ({8{VGA_GC}} & VGA_GC_DATA) |
							 ({8{JOYSTICK}} & GPIOData) |
							 ({8{PARALLEL_PORT_CTL}} & {1'bx, dss_full, 6'bxxxxxx}) |
							 ({8{CPU32_PORT}} & cpu32_data[7:0]) | 
							 ({8{COM0_PORT}} & COM0_DOUT) | 
							 ({8{COM1_PORT}} & COM1_DOUT) | 
							 ({8{OPL3_PORT}} & opl32_data) ;

	//dcm dcm_system ( .inclk0(CLK_50MHZ), .c0(clk_25), .c1(clk_sdr), .c2(sdr_CLK_out), .c3(CLK44100x256), .c4(CLK14745600) ); 
	//dcm_cpu dcm_cpu_inst ( .inclk0(CLK_50MHZ), .c0(clk_cpu), .c1(clk_dsp) );
	assign CLK44100x256 = sysdiv[1];
	assign CLK14745600  = sysdiv[1];
	assign clk_cpu = CLK_50MHZ;
	assign clk_dsp = CLK_50MHZ;
	reg [2:0] sysdiv;
	always @ (posedge CLK_50MHZ) sysdiv <= sysdiv + 1; ////

`ifndef NoCPU
	wire [3:0]seg_addr;
	wire vga_planar_seg;
	unit186 CPUUnit
	(
		 .INPORT(INTA ? {8'h00, PIC_IVECT} : PORT_IN), 
		 .DIN(DRAM_dout), 
		 .CPU_DOUT(CPU_DOUT),
		 .PORT_ADDR(PORT_ADDR),
		 .SEG_ADDR(seg_addr),
		 .DOUT(DOUT), 
		 .ADDR(ADDR), 
		 .WMASK(RAM_WMASK), 
		 .CLK(clk_cpu), 
		 .CE(CE), 
		 .CPU_CE(CPU_CE),
		 .CE_186(CE_186),
		 .INTR(INT), 
		 .NMI(rNMI[9] || (CPU_CE && IORQ && PORT_ADDR >= NMIonIORQ_LO && PORT_ADDR <= NMIonIORQ_HI)), 
		 .RST(preset), 
		 .INTA(INTA), 
		 .LOCK(LOCK), 
		 .HALT(HALT), 
		 .MREQ(MREQ),
		 .IORQ(IORQ),
		 .WR(WR),
		 .WORD(WORD),
		 .FASTIO(1'b1),
		 
		 .VGA_SEL(planarreq && vga_planar_seg),
		 .VGA_WPLANE(vga_wplane),
		 .VGA_RPLANE(vga_rplane),
		 .VGA_BITMASK(vga_bitmask),
		 .VGA_RWMODE(vga_rwmode),
		 .VGA_SETRES(vga_setres),
		 .VGA_ENABLE_SETRES(vga_enable_setres),
		 .VGA_LOGOP(vga_logop),
		 .VGA_COLOR_COMPARE(vga_color_compare),
		 .VGA_COLOR_DONT_CARE(vga_color_dont_care),
		 .VGA_ROTATE_COUNT(vga_rotate_count)
	);
`else
//--  Dumy.Setup VGA  ------------------------------------
	assign ADDR = daddr;
	assign DOUT = ddout;
	assign MREQ = dmreq;
	assign RAM_WMASK = dmask;
	reg  [20:0] daddr,waddr;
	reg  [31:0] ddout;
	reg         dmreq;
	reg  [3:0]  dmask;
	reg  [7:0]  hloop, vloop;
	reg  [15:0] ddptn;

	assign PORT_ADDR = dioadr;
	assign CPU_DOUT  = {8'h00,diodat};
	assign CPU_CE    = 1;
	assign IORQ      = diorq;
	assign WR        = diowr;
	reg [ 3:0] dioseq,diossq;
	reg [15:0] dioadr;
	reg  [7:0] diodat;
	reg        diorq, diowr;

	always @ (posedge clk_cpu) begin	// Dumy.Access
		if(preset) begin
			dioseq <= 1; diossq <= 0; diorq <= 0; dmreq <= 0; 
		end else if(CE) begin
			case(dioseq)
				4'h1: if(diossq==0) begin dioadr <= 16'h03c8; diodat <= 8'h01; diossq <= 1; dioseq <= 2; end 
				4'h2: if(diossq==0) begin dioadr <= 16'h03c9; diodat <= 8'h2a; diossq <= 1; dioseq <= 3; end 
				4'h3: if(diossq==0) begin dioadr <= 16'h03c9; diodat <= 8'h2a; diossq <= 1; dioseq <= 4; end 
				4'h4: if(diossq==0) begin dioadr <= 16'h03c9; diodat <= 8'h2a; diossq <= 1; dioseq <= 5; end
				//
				4'd5 : begin dioseq <=  6; waddr <= 21'h0b8000; vloop <= 0; end
				4'd6 : begin dioseq <=  7; ddptn <= 16'h0100+vloop; hloop <= 0; end 
				4'd7 : begin dioseq <=  8; dmreq <= 1; daddr <= waddr; ddout <= {16'h0000,ddptn+32}; 
							if(~waddr[1]) dmask <= 4'b0011;
							else          dmask <= 4'b1100; 
					   end
				4'd8 : begin 
						dioseq <=  9; dmreq <= 0; daddr <= 0; waddr <= waddr + 2; 
						if(ddptn[7:0]>=8'h60) ddptn[7:0] <= 0;
						else                  ddptn[7:0] <= ddptn[7:0] + 1; 
					end
				4'd9 : if(hloop<79) begin dioseq <= 7; hloop <= hloop + 1; end
						else        begin dioseq <= 10; dmreq <= 0; end
				4'd10: begin
						if(vloop<24) dioseq <= 6;
						else         dioseq <= 0; // end
						vloop <= vloop + 1;
					end
			endcase
			//
			case(diossq)
				4'h1: begin diorq <= 1; diowr <= 1; diossq <= 2; end
				4'h2: begin diorq <= 0; diowr <= 0; diossq <= 3; end
				4'h3: diossq <= 0;
			endcase
		end
	end
//-------------------------------------------
`endif

	mem_controller cache_ctl
	(
		 .addr(ADDR), 
		 .dout(DRAM_dout), 
		 .din(DOUT), 
		 .clk(clk_cpu), 
		 .mreq(MREQ), 
		 .wmask(RAM_WMASK),
		 .ce(CE), 
		 // PSRAM(Internal connection)
		 .reset(BTN_RESET),
		 .psram_clk(psram_clk),
		 .ps_calib(ps_calib),
		 .pll_lock(pll_lock),
		 .O_psram_ck(O_psram_ck),
		 .O_psram_ck_n(O_psram_ck_n),
		 .IO_psram_rwds(IO_psram_rwds),
		 .IO_psram_dq(IO_psram_dq),
		 .O_psram_reset_n(O_psram_reset_n),
		 .O_psram_cs_n(O_psram_cs_n),
		// vga data
		//.clk_sdr(clk_sdr),
		.clk_mctr(clk_mctr),
		.vblnk(vblnk),
		.sdraddr(sdraddr),
		.sys_CMD(cntrl0_user_command_register),
		.sys_cmd_ack(sys_cmd_ack),
		.sys_DOUT(sys_DOUT),
		.sys_rd_data_valid(sys_rd_data_valid),

		 .flush(auto_flush == 3'b110)
	);

	// Debug serial (COM0_PORT:$3fc-3fe)
	always @ (posedge clk_cpu) begin
		if(COM0_PORT && PORT_ADDR[1:0]==2'b00 && WR) tx0_dt <= CPU_DOUT[7:0];
	end
	assign COM0_DOUT = 	PORT_ADDR[1:0]==2'b00 ? rx0_dt :			// $3fc
						PORT_ADDR[1:0]==2'b01 ? {rx0_rdy,7'h00} :	// $3fd
						PORT_ADDR[1:0]==2'b10 ? {tx0_bsy,7'h00} :	// $3fe
												{~BTN_USER,7'h00};	// 03ff Reset.Start DOS
						//						{~BTN_USER,7'h00};	// 03ff Reset.Start MON
	wire rx0_rd  = COM0_PORT && PORT_ADDR[1:0]==2'b00;
	wire tx0_req = COM0_PORT && PORT_ADDR[1:0]==2'b00 && WR;
	//wire rx_rd   = COM1_PORT && PORT_ADDR[1:0]==2'b00;
	//wire tx_req  = COM1_PORT && PORT_ADDR[1:0]==2'b00 && WR;
	wire tx0_bsy,rx0_rdy;
	reg  [7:0] tx0_dt;
	wire [7:0] rx0_dt;
	rs232c rs232c(
		.RESETB(~BTN_RESET), .CLK(clk_cpu), .TXD(TX), .RXD(RX), 
		.TX_DATA(tx0_dt), .TX_DATA_EN(tx0_req), .TX_BUSY(tx0_bsy), 
		.RX_DATA(rx0_dt), .RX_DATA_RD(rx0_rd),  .RX_DATA_RDY(rx0_rdy)
		);
 
	VGA_SG VGA 
	(
		.tc_hsblnk(10'd639), 
		.tc_hssync(10'd655+10'd19), 	// +17 for hrz panning
		.tc_hesync(10'd751+10'd19), 	// +17 for hrz panning
		.tc_heblnk(10'd799), 
		.hcount(hcount), 
		.hsync(VGA_HSYNC), 
		.hblnk(hblnk), 
		.tc_vsblnk(v240[2] ? 10'd479 : 10'd399), 
		.tc_vssync(v240[2] ? 10'd489 : 10'd411), 
		.tc_vesync(v240[2] ? 10'd491 : 10'd413), 
		.tc_veblnk(v240[2] ? 10'd520 : 10'd446), 
		.vcount(vcount), 
		.vsync(VGA_VSYNC), 
		.vblnk(vblnk), 
		.clk(clk_pixel),
		.ce(FifoStart)
	);
	assign VGA_hblnk = hblnk || vblnk;
	
	VGA_DAC dac 
	(
		 .CE(VGA_DAC_OE && IORQ && CPU_CE), 
		 .WR(WR), 
		 .reset(preset),
		 .addr(PORT_ADDR[3:0]), 
		 .din(CPU_DOUT[7:0]), 
		 .dout(VGA_DAC_DATA), 
		 .CLK(clk_cpu), 
		 .VGA_CLK(clk_pixel), 
		 .vga_addr((vgatext[1] | (~vga13[1] & planar[1])) ? VGA_INDEX : (vga13[1] ? hcount_pan[1] : hcount_pan[0]) ? fifo_dout[15:8] : fifo_dout[7:0]), 
		 .color(DAC_COLOR),
		 .vgatext(vgatextreq),
		 .vga13(vga13req),
		 .half(halfreq),
		 .vgaflash(vgaflash),
		 .setindex(INPUT_STATUS_OE && IORQ && CPU_CE),
		 .hrzpan(vga_hrzpan_req),
		 .ppm(ppm),
		 .ega_attr(EGA_MUX),
		 .ega_pal_index(VGA_INDEX)
    );
	 
	 VGA_CRT crt
	 (
		.CE(IORQ && CPU_CE && VGA_CRT_OE),
		.WR(WR),
		.WORD(WORD),
		.din(CPU_DOUT),
		.addr(PORT_ADDR[0]),
		.dout(VGA_CRT_DATA),
		.CLK(clk_cpu),
		.oncursor(oncursor),
		.cursorstart(crs[0]),
		.cursorend(crs[1]),
		.cursorpos(cursorpos),
		.scraddr(scraddr),
		.offset(vga_offset),
		.lcr(lcr),
		.repln(replnreq),
		.vde(vde)
	);
	
	VGA_SC sc
	(
		.CE(IORQ && CPU_CE && VGA_SC),	// 3c4, 3c5
		.WR(WR),
		.WORD(WORD),
		.din(CPU_DOUT),
		.dout(VGA_SC_DATA),
		.addr(PORT_ADDR[0]),
		.CLK(clk_cpu),
		.planarreq(planarreq),
		.wplane(vga_wplane)
    );

	VGA_GC gc
	(
		.CE(IORQ && CPU_CE && VGA_GC),
		.WR(WR),
		.WORD(WORD),
		.din(CPU_DOUT),
		.addr(PORT_ADDR[0]),
		.CLK(clk_cpu),
		.rplane(vga_rplane),
		.bitmask(vga_bitmask),
		.rwmode(vga_rwmode),
		.setres(vga_setres),
		.enable_setres(vga_enable_setres),
		.logop(vga_logop),
		.color_compare(vga_color_compare),
		.color_dont_care(vga_color_dont_care),
		.rotate_count(vga_rotate_count),
		.dout(VGA_GC_DATA)
	);

    Gowin_DPB_font vga_font(
        .clka(clk_pixel),
        .wrea(1'b0),
        .ada({fifo_dout[7:0], char_ln}),
        .dina(8'h00),
        .douta(font_dout),
        .ocea(1'b1), .cea(1'b1), .reseta(1'b0),
        .clkb(clk_cpu),
        .wreb(WR & IORQ & VGA_FONT_OE & ~WORD & CPU_CE),
        .adb(vga_font_counter),
        .dinb(CPU_DOUT[7:0]),
        .doutb(VGA_FONT_DATA),
        .oceb(1'b1), .ceb(1'b1), .resetb(1'b0)
    );

//--//
	wire [7:0]PIC_IVECT;
	wire INT;
	wire timer_int;
	wire I_COM1;
	PIC_8259 PIC 
	(
		 .CS(PIC_OE && IORQ && CPU_CE), // 21h, a1h
		 .WR(WR), 
		 .din(CPU_DOUT[7:0]), 
		 .slave(PORT_ADDR[7]),
		 .dout(PIC_DOUT), 
		 .ivect(PIC_IVECT), 
		 .clk(clk_cpu), 
		 .INT(INT), 
		 .IACK(INTA & CPU_CE), 
		 .I({I_COM1, I_MOUSE, RTCEND, I_KB, timer_int})
    );

	 wire timer_spk;
	 timer_8253 timer 
	 (
		 .CS(TIMER_OE && IORQ && CPU_CE), 
		 .WR(WR), 
		 .addr(PORT_ADDR[1:0]), 
		 .din(CPU_DOUT[7:0]), 
		 .dout(TIMER_DOUT), 
		 .CLK_25(clk_pixel), 
		 .clk(clk_cpu), 
		 .out0(timer_int), 
		 .out2(timer_spk)
    );
	 
	wire I_KB    = 0;
	wire I_MOUSE = 0;
	//wire KB_RST  = 0;

	KB_Mouse_8042 KB_Mouse 
	(
		 .CS(IORQ && CPU_CE && KB_OE), // 60h, 64h
		 .WR(WR), 
		 .cmd(PORT_ADDR[2]), // 64h
		 .din(CPU_DOUT[7:0]), 
		 .dout(KB_DOUT), 
		 .clk(clk_cpu), 
		 .I_KB(I_KB), 
		 .I_MOUSE(I_MOUSE), 
		 .CPU_RST(KB_RST), 
		 .PS2_CLK1(PS2_CLK1), 
		 .PS2_CLK2(PS2_CLK2), 
		 .PS2_DATA1(PS2_DATA1), 
		 .PS2_DATA2(PS2_DATA2)
	);
/*	
	 soundwave sound_gen
	 (
		.CLK(clk_cpu),
		.CLK44100x256(CLK44100x256),
		.data(CPU_DOUT),
		.we(IORQ & CPU_CE & WR & PARALLEL_PORT),
		.word(WORD),
		.speaker(speaker_on & timer_spk),
		.opl3left(opl3left),
        .opl3right(opl3right),
        .stb44100(stb44100),
		.full(sq_full),	// when not full, write max 2x1152 16bit samples
		.dss_full(dss_full),
		.AUDIO_L(AUD_L),
		.AUDIO_R(AUD_R)
	);
	 
	DSP32 DSP32_inst
	(
		.clkcpu(clk_cpu),
		.clkdsp(clk_dsp),
		.cmd(PORT_ADDR[0]), // port 2=data, port 3=cmd (word only)
		.ce(IORQ & CPU_CE & CPU32_PORT & WORD),
		.wr(WR),
		.din(CPU_DOUT),
		.dout(cpu32_data),
		.halt(cpu32_halt)
	);

//	UART_8250 UART(
//		.CLK_18432000(CLK14745600),
//		.RS232_DCE_RXD(RX),
//		.RS232_DCE_TXD(TX),
//		.clk(clk_cpu),
//		.din(CPU_DOUT[7:0]),
//		.dout(COM1_DOUT),
//		.cs(COM1_PORT && IORQ && CPU_CE),
//		.wr(WR),
//		.addr(PORT_ADDR[2:0]),
//		.BRShift(COMBRShift),
//		.INT(I_COM1)
//   );

    opl3 opl3_inst (
        .clk(CLK_50MHZ), // 50Mhz (min 45Mhz)
        .cpu_clk(clk_cpu),
        .addr(PORT_ADDR[1:0]),
        .din(CPU_DOUT[7:0]),
        .dout(opl32_data),
        .ce(IORQ & CPU_CE & OPL3_PORT),
        .wr(WR),
        .left(opl3left),
        .right(opl3right),
        .stb44100(stb44100),
        .reset(preset)    
     );
	
	i2c_master_byte i2cmb
	(
		.refclk(clk_pixel),	// 25Mhz=100Kbps...100Mhz=400Kbps
		.din(i2c_cd[7:0]),
		.cmd(i2c_cd[11:8]),	// 01xx=wr,10xx=rd+ack, 11xx=rd+nack, xx1x=start, xxx1=stop
		.dout(i2cdout),
		.ack(i2cack),
		.noack(i2cackerr),
		.SCL(I2C_SCL),
		.SDA(I2C_SDA),
		.rst(1'b0)
	);
*/
	wire wrreq = (!crw && sys_rd_data_valid && !col_counter[4]);
	FIFO_HS_vga vga_fifo(
		.WrClk(clk_mctr),
		.RdClk(clk_pixel),
		.Data(sys_DOUT),
		.WrEn(wrreq),
		.RdEn(vrden || VGA_VSYNC),
		.Q(fifo_dout32),
		.Rnum(fifo_wr_used_words)
	);

	reg nop;
	always @ (posedge clk_mctr) begin
		s_prog_full <= fifo_wr_used_words > 350; // AlmostFull;
		if(fifo_wr_used_words < 64) s_prog_empty <= 1'b1; //AlmostEmpty;
		else begin
			s_prog_empty <= 1'b0;
			FifoStart <= 1'b1;
		end
		s_ddr_rd <= ddr_rd;
		s_ddr_wr <= ddr_wr;
		s_vga_endline <= vga_repln_count == vga_repln;
		s_vga_endframe <= vga_end_frame;
		nop <= sys_cmd_ack == 2'b00;
		sdraddr <= s_prog_empty || !(s_ddr_wr || s_ddr_rd) ? {6'b000001, vga_ddr_row_col + vga_lnbytecount} : {memmap_mux[8:0], cache_hi_addr[9:0], 4'b0000};
		max_read <= &sdraddr[7:3] ? ~sdraddr[2:0] : 3'b111;	// SDRAM row size = 512 words

if(VGA_VSYNC) begin 
	vga_lnbytecount <= 0; vga_ddr_row_count <= 0; vga_repln_count <= 0;	// Timing.Adjust!
end else begin

		if(s_prog_empty) cntrl0_user_command_register <= 2'b10;			// read 32 bytes VGA
		//else if(s_ddr_wr) cntrl0_user_command_register <= 2'b01;		// write 256 bytes cache
		//else if(s_ddr_rd) cntrl0_user_command_register <= 2'b11;		// read 256 bytes cache
		else if(~s_prog_full) cntrl0_user_command_register <= 2'b10;	// read 32 bytes VGA
		else cntrl0_user_command_register <= 2'b00;

		if(!crw && sys_rd_data_valid) col_counter <= col_counter - 1'b1;
		if(nop) case(sys_cmd_ack)
			2'b10: begin 
				crw <= 1'b0;	// VGA read
				col_counter <= {1'b0, max_read, 1'b1};
				vga_lnbytecount <= vga_lnbytecount + max_read + 1'b1;
			end					
			2'b01, 2'b11: crw <= 1'b1;	// cache read/write			
		endcase

		if(s_vga_endscanline) begin
			col_counter[3:1] <= col_counter[3:1] - vga_lnbytecount[2:0];
			vga_lnbytecount <= 0;
			s_vga_endscanline <= 1'b0;

			if(s_vga_endframe) vga_ddr_row_col <= {{1'b0, scraddr[15:13]} + (vgatext[0] ? 4'b0111 : 4'b0100), scraddr[12:0]};
			else if({1'b0, vga_ddr_row_count} == lcr) vga_ddr_row_col <= vgatext[0] ? 17'he000 : 17'h8000; 
				 else if(s_vga_endline) vga_ddr_row_col <= vga_ddr_row_col + (vgatext[0] ? 40 : {vga_offset, 1'b0});
			
			if(s_vga_endline) vga_repln_count <= 0;
			else vga_repln_count <= vga_repln_count + 1'b1;
			if(s_vga_endframe) begin
				vga13[0] <= vga13req;
				vgatext[0] <= vgatextreq;
				v240[0] <= vde >= 10'd400;
				planar[0] <= planarreq;
				half[0] <= halfreq;
				repln_graph[0] <= replnreq;
				vga_ddr_row_count <= 0;
			end else vga_ddr_row_count <= vga_ddr_row_count + 1'b1; 
		end else s_vga_endscanline <= (vga_lnbytecount[7:3] == vga_lnend);
end
	end

	reg [7:0]SDI;
	//assign SD_DI = CPU_DOUT[7];
	assign SD_DI = sd_dout[7];

	reg  [7:0] sd_dout, sd_din;
	reg  [4:0] sd_dct; 
	reg        sd_bsy, sd_run, sd_ckx;
	wire       sd_dix = sd_dout[7];
	always @ (posedge clk_cpu) begin
		s_RS232_DCE_RXD <= RS232_DCE_RXD;
		s_RS232_HOST_RXD <= RS232_HOST_RXD;
		if(IORQ & CPU_CE) begin
			if(WR & AUX_OE) begin
				if(WORD) auto_flush[2] <= CPU_DOUT[0];
				else {COMBRShift[1:0], RS232_HOST_RST, ComSel[1:0]} <= CPU_DOUT[4:0];
			end
			if(VGA_FONT_OE) vga_font_counter <= WR && WORD ? {CPU_DOUT[7:0], 4'b0000} : vga_font_counter + 1'b1; 
			if(WR & SPEAKER_PORT) speaker_on <= &CPU_DOUT[1:0];
		end
// SD
		if(CPU_CE) begin
			//SD_CK <= IORQ & INPUT_STATUS_OE & WR & ~WORD;
			if(IORQ & INPUT_STATUS_OE & WR) begin
				if(WORD) SD_n_CS <= ~CPU_DOUT[8]; // SD chip select
				//else SDI <= {SDI[6:0], SD_DO};
			end
		end

		if(preset) begin sd_bsy <= 0; sd_run <= 0; sd_ckx <= 0; end
		else begin
			if(IORQ & INPUT_STATUS_OE && CPU_CE) begin
				if(WR && ~WORD && ~sd_bsy) begin
					sd_dout <= CPU_DOUT[7:0]; sd_dct <= 15;
					sd_bsy <= 1; sd_run <= 1;
				end
				if(~WR && WORD) sd_bsy <= 0;
			end

			if(sd_run) begin	
				//sd_ckx <= sd_dct[0];
				SD_CK <= sd_dct[0];
				if(~sd_dct[0]) begin
					sd_dout <= {sd_dout[6:0],1'b0};
					//sd_din  <= {sd_din[6:0],SD_DO};
					SDI  <= {SDI[6:0],SD_DO};
				end 
				if(sd_dct==0) sd_run <= 0; 
				else          sd_dct <= sd_dct - 1;
			end
		end

// RESET
		if(KB_RST || BTN_RESET) rstcount <= 0;
		else if(CPU_CE && ~rstcount[18]) rstcount <= rstcount + 1'b1;
// RTC		
		RTCSYNC <= {RTCSYNC[0], RTCDIVEND};
		if(IORQ && CPU_CE && WR && WORD && RTC_SELECT) begin
			RTC <= 0;
			RTCSET <= CPU_DOUT;
		end else if(RTCSYNC == 2'b01) begin
			if(RTCEND) RTC <= 0;
			else RTC <= RTC + 1'b1;
		end
// GPIO
		if(CPU_CE) GPIOData <= GPIO;
		if(IORQ && CPU_CE && WR && JOYSTICK) begin
			if(WORD) GPIOState <= CPU_DOUT[15:8];
			GPIODout <= CPU_DOUT[7:0];
		end
// NMI on IORQ
		if(IORQ && CPU_CE && WR && NMI_IORQ_PORT)
			if(PORT_ADDR[0]) NMIonIORQ_HI <= CPU_DOUT;
			else NMIonIORQ_LO <= CPU_DOUT;
// I2C
		if(CPU_CE && IORQ && WR && WORD && I2C_SELECT) i2c_cd <= CPU_DOUT[11:0];
					
		auto_flush[1:0] <= {auto_flush[0], vblnk};		
	end
	
	always @ (posedge clk_pixel) begin
		s_displ_on <= {s_displ_on[17:0], displ_on};
		exline <= vrdon ? 4'b1111 : (exline - vrden); // 32 extra bytes at the end of the scanline, for panning
		
		vga_attr <= fifo_dout[15:8];		
		flash_on <= (vgaflash & fifo_dout[15] & flashcount[5]) | (~oncursor && flashcount[4] && (charcount == cursorpos) && (char_ln >= crs[0][3:0]) && (char_ln <= crs[1][3:0]));		
		
		if(!vblnk) begin
			flashbit <= 1;
			vga13[2] <= vga13[1];
			vgatext[2] <= vgatext[1];
			v240[2] <= v240[1];
			planar[2] <= planar[1];
			half[2] <= half[1];
		end else if(flashbit) begin
			flashcount <= flashcount + 1'b1;
			flashbit <= 0;
			vga13[1] <= vga13[0];
			vgatext[1] <= vgatext[0];
			v240[1] <= v240[0];
			planar[1] <= planar[0];
			half[1] <= half[0];
		end
		
		if(RTCDIVEND) RTCDIV25 <= 0;	// real time clock
		else RTCDIV25 <= RTCDIV25 + 1'b1;
		
		if(!BTN_NMI) rNMI <= 0;		// NMI
		else if(!rNMI[9] && RTCDIVEND) rNMI <= rNMI + 1'b1;	// 1Mhz increment

		if(VGA_VSYNC) vga_hrzpan <= half[0] ? {vga_hrzpan_req[2:0], 1'b0} : {1'b0, vga_hrzpan_req[2:0]};
		else if(VGA_HSYNC && ppm && (vcount == lcr)) vga_hrzpan <= 4'b0000;

		{VGA_B, VGA_G, VGA_R} <= DAC_COLOR & {18{sdon}};
	end
	
endmodule

