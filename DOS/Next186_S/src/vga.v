//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: vga.v
// Description: Part of the Next186 SoC PC project, VGA module
//		customized VGA, only modes 3 (25x80x256 text), 13h (320x200x256 graphic) 
//		and VESA 101h (640x480x256) implemented
// Version 1.0
// Creation date: Jan2012
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
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module VGA_SG
  (
  input  wire	[9:0]	tc_hsblnk,
  input  wire	[9:0]	tc_hssync,
  input  wire	[9:0]	tc_hesync,
  input  wire	[9:0]	tc_heblnk,

  output reg	[9:0]	hcount = 0,
  output reg			hsync,
  output reg			hblnk = 0,

  input  wire	[9:0]	tc_vsblnk,
  input  wire	[9:0]	tc_vssync,
  input  wire	[9:0]	tc_vesync,
  input  wire	[9:0]	tc_veblnk,

  output reg	[9:0]	vcount = 0,
  output reg			vsync,
  output reg			vblnk = 0,

  input  wire			clk,	// clk_pixel
  input  wire			ce
  );

  //******************************************************************//
  // This logic describes a 10-bit horizontal position counter.       //
  //******************************************************************//
  always @(posedge clk)
		if(ce) begin
			if(hcount >= tc_heblnk) begin
				hcount <= 0;
				hblnk <= 0;
			end else begin
				hcount <= hcount + 1;
				hblnk <= (hcount >= tc_hsblnk);
			end
			hsync <= (hcount >= tc_hssync) && (hcount < tc_hesync);
		end
		
  //******************************************************************//
  // This logic describes a 10-bit vertical position counter.         //
  //******************************************************************//
	always @(posedge clk)
		if(ce && hcount == tc_heblnk) begin
			if (vcount >= tc_veblnk) begin
				vcount <= 0;
				vblnk <= 0;
			end else begin
				vcount <= vcount + 1;
				vblnk <= (vcount >= tc_vsblnk);
			end
			vsync <= (vcount >= tc_vssync) && (vcount < tc_vesync);
		end

  //******************************************************************//
  // This is the logic for the horizontal outputs.  Active video is   //
  // always started when the horizontal count is zero.  Example:      //
  //                          
  //
  // tc_hsblnk = 03                                                   //
  // tc_hssync = 07                                                   //
  // tc_hesync = 11                                                   //
  // tc_heblnk = 15 (htotal)                                          //
  //                                                                  //
  // hcount   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15         //
  // hsync    ________________________------------____________        //
  // hblnk    ____________------------------------------------        //
  //                                                                  //
  // hsync time  = (tc_hesync - tc_hssync) pixels                     //
  // hblnk time  = (tc_heblnk - tc_hsblnk) pixels                     //
  // active time = (tc_hsblnk + 1) pixels                             //
  //                                                                  //
  //******************************************************************//

  //******************************************************************//
  // This is the logic for the vertical outputs.  Active video is     //
  // always started when the vertical count is zero.  Example:        //
  //                                                                  //
  // tc_vsblnk = 03                                                   //
  // tc_vssync = 07                                                   //
  // tc_vesync = 11                                                   //
  // tc_veblnk = 15 (vtotal)                                          //
  //                                                                  //
  // vcount   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15         //
  // vsync    ________________________------------____________        //
  // vblnk    ____________------------------------------------        //
  //                                                                  //
  // vsync time  = (tc_vesync - tc_vssync) lines                      //
  // vblnk time  = (tc_veblnk - tc_vsblnk) lines                      //
  // active time = (tc_vsblnk + 1) lines                              //
  //                                                                  //
  //******************************************************************//


endmodule


module VGA_DAC(
     input CE,
	 input WR,
	 input reset,
     input [3:0]addr,
	 input [7:0]din,
	 output [7:0]dout,
	 input CLK,
	 input VGA_CLK,
	 input [7:0]vga_addr,
	 input setindex,
	 output [17:0]color,
	 output reg vgatext = 1'b1,
	 output reg vga13 = 1'b1,
	 output reg vgaflash = 0,
	 output reg half = 0,
	 output reg [3:0]hrzpan = 0,
	 output reg ppm = 0, // pixel panning mode
	 input [3:0]ega_attr,
	 output [7:0]ega_pal_index
    );

	initial vgatext = 1'b1;
	initial vga13 = 1'b1;
	
	reg [7:0]mask = 8'hff;
	reg [9:0]index = 0;
	reg mode = 0;
	reg [4:0]a0index = 0;
	reg a0data = 0;
	wire [7:0]pal_dout;
	wire [31:0]pal_out;
	wire addr6 = addr == 6;
	wire addr7 = addr == 7;
	wire addr8 = addr == 8;
	wire addr9 = addr == 9;
	wire addr0 = addr == 0;
	//reg [5:0]egapal[15:0];
	//initial $readmemh("egapal.mem", egapal);
	reg [0:15][5:0] egapal = {6'd0,6'd1,6'd2,6'd3,6'd4,6'd5,6'd6,6'd7,6'd8,6'd9,6'd10,6'd11,6'd12,6'd13,6'd14,6'd15};
	reg p54s = 1'b0;
	reg [3:0]colsel = 4'b0000;
	wire [5:0]egacolor = egapal[ega_attr]; 
	assign ega_pal_index = {colsel[3:2], p54s ? colsel[1:0] : egacolor[5:4], egacolor[3:0]};
	reg [7:0]store[5'h14:0];
	reg [7:0]attrib;
////
//	DAC_SRAM vga_dac 
	
	wire [7:0] dadr = vga_addr & mask;
    Gowin_DPB_dac vga_dac(
        .clka(CLK), //input clka
        .wrea(CE & WR & addr9), //input wrea
        .reseta(1'b0), //input reseta
        .cea(1'b1), //input cea
        .ocea(1'b1), //input ocea
        .ada(index), //input [9:0] ada
        .dina(din), //input [7:0] dina
        .douta(pal_dout), //output [7:0] douta

        .clkb(VGA_CLK), //input clkb
        .wreb(1'b0), //input wreb
        .resetb(1'b0), //input resetb
        .ceb(1'b1), //input ceb
        .oceb(1'b1), //input oceb
        .adb(vga_addr & mask), //input [7:0] adb
        .dinb(32'h00000000), //input [31:0] dinb
        .doutb(pal_out) //output [31:0] doutb
    );

	assign color = {pal_out[21:16], pal_out[13:8], pal_out[5:0]};
	assign dout = addr6 ? mask : addr7 ? {6'bxxxxxx, mode, mode} : addr8 ? index[9:2] : addr9 ? pal_dout : attrib;
	
	always @(posedge CLK) begin

		if(setindex) a0data <= 0;
		else if(CE && addr0 && WR) a0data <= ~a0data;
	
		if(CE) begin
			if(addr0) begin
				if(WR) begin					
					if(a0data) begin
						if(!a0index[4]) egapal[a0index[3:0]] <= din[5:0];
						else case(a0index[3:0]) 
							4'h0: {p54s, vga13, ppm, half, vgaflash, vgatext} <= {din[7:3], ~din[0]};
							4'h3: hrzpan <= din[3:0];
							4'h4: colsel <= din[3:0];
						endcase 
						store[a0index] <= din;
					end else begin
						a0index <= din[4:0];
						attrib <= store[din[4:0]];
					end
				end
			end 
			if(addr6 && WR) mask <= din;
			if(addr7 | addr8) begin
				if(WR) index <= {din, 2'b00};
				mode <= addr8;
			end else if(addr9) index <= index + (index[1:0] == 2'b10 ? 2 : 1);
		end
	end

endmodule



module VGA_CRT(
    input CE,
	 input WR,
	 input WORD,
	 input [15:0]din,
	 input addr,
	 output [7:0]dout,
	 input CLK,
	 output reg oncursor,
	 output reg [4:0]cursorstart,
	 output reg [4:0]cursorend,
	 output reg [11:0]cursorpos,
	 output reg [15:0]scraddr,
	 output reg [7:0]offset = 8'h28,
	 output reg [9:0]lcr = 10'h3ff, // line compare register
	 output reg repln = 1'b0,		// line repeat count - 1 for graphics mode only
	 output reg [9:0]vde = 10'h18f	// last display visible scan line (i.e. 399 in text mode)
    );
	
	initial offset = 8'h28;
	initial lcr = 10'h3ff;
	initial vde = 10'h18f;	// 400 lines
	
	reg [4:0]idx_buf = 0;
	reg [7:0]store[5'h18:0];
	wire [4:0]index = addr ? idx_buf : din[4:0];
	wire [7:0]data = addr ? din[7:0] : din[15:8];
	reg [7:0]dout1;
	assign dout = addr ? dout1 : {3'b000, idx_buf};
	 
	always @(posedge CLK) begin
		if(CE && WR) begin
			if(!addr) idx_buf <= din[4:0];
			if(addr || WORD) begin
				store[index] <= data;
				case(index)
					5'h7: {vde[9:8], lcr[8]} <= {data[6], data[1], data[4]};
					5'h9: {lcr[9], repln} <= {data[6], data[0] | data[7]};
					5'ha: {oncursor, cursorstart} <= data[5:0];
					5'hb: cursorend <= data[4:0];
					5'hc: scraddr[15:8] <= data;
					5'hd: scraddr[7:0] <= data;
					5'he: cursorpos[11:8] <= data[3:0];
					5'hf: cursorpos[7:0] <= data;
					5'h12: vde[7:0] <= data;
					5'h13: offset <= data;
					5'h18: lcr[7:0] <= data;
				endcase
			end
		end
		dout1 <= store[idx_buf];
	end
endmodule


module VGA_SC(
    input CE,
	 input WR,
	 input WORD,
	 input [15:0]din,
	 output [7:0]dout,
	 input addr,
	 input CLK,
	 output reg planarreq,
	 output reg[3:0]wplane
    );
	
	reg [2:0]idx_buf = 0;
	wire [2:0]index = addr ? idx_buf : din[2:0];
	wire [7:0]data = addr ? din[7:0] : din[15:8];
	reg [7:0]dout1;
	assign dout = addr ? dout1 : {5'b00000, idx_buf};
	 
	always @(posedge CLK) begin 
		if(CE && WR) begin
			if(!addr) idx_buf <= din[2:0];
			if(addr || WORD) begin
				if(index == 2) wplane <= data[3:0];
				if(index == 4) planarreq <= ~data[3];
			end
		end
		dout1 <= {4'b0000, idx_buf == 2 ? wplane : {~planarreq, 3'b000}};
	end
endmodule


module VGA_GC(
    input CE,
	 input WR,
	 input WORD,
	 input [15:0]din,
	 output [7:0]dout,
	 input addr,
	 input CLK,
	 output reg [1:0]rplane = 2'b00,
	 output reg[7:0]bitmask = 8'b11111111,
	 output reg [2:0]rwmode = 3'b000,
	 output reg [3:0]setres = 4'b0000,
	 output reg [3:0]enable_setres = 4'b0000,
	 output reg [1:0]logop = 2'b00,
	 output reg [3:0]color_compare = 4'b0000,
	 output reg [3:0]color_dont_care = 4'b1111,
	 output reg [2:0]rotate_count = 3'b000
    );
	
	initial bitmask = 8'b11111111;
	initial color_dont_care = 4'b1111;
	
	reg [3:0]idx_buf = 0;
	reg [7:0]store[8:0];
	wire [3:0]index = addr ? idx_buf : din[3:0];
	wire [7:0]data = addr ? din[7:0] : din[15:8];
	reg [7:0]dout1;
	assign dout = addr ? dout1 : {4'b0000, idx_buf};
	 
	always @(posedge CLK) begin
		if(CE && WR) begin
			if(!addr) idx_buf <= din[3:0];
			if(addr || WORD) begin
				store[index] <= data;
				case(index)
					0: setres <= data[3:0];
					1: enable_setres <= data[3:0];
					2: color_compare <= data[3:0];
					3: {logop, rotate_count} <= data[4:0];
					4: rplane <= data[1:0];
					5: rwmode <= {data[3], data[1:0]};
					7: color_dont_care <= data[3:0];
					8: bitmask <= data;
				endcase
			end
		end
		dout1 <= store[idx_buf];
	end
endmodule

