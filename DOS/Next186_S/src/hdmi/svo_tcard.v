/*
 *  SVO - Simple Video Out FPGA Core
 *
 *  Copyright (C) 2014  Clifford Wolf <clifford@clifford.at>
 *  
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1ns / 1ps
`include "svo_defines.vh"

module svo_tcard #( `SVO_DEFAULT_PARAMS ) (
	input clk_pixel, resetn,

	// output stream
	//   tuser[0] ... start of frame
	output reg out_axis_tvalid,
	input out_axis_tready,
	output reg [SVO_BITS_PER_PIXEL-1:0] out_axis_tdata,
	output reg [0:0] out_axis_tuser
);
	`SVO_DECLS
	localparam HOFFSET = ((32 - (SVO_HOR_PIXELS % 32)) % 32) / 2;
	localparam VOFFSET = ((32 - (SVO_VER_PIXELS % 32)) % 32) / 2;

	reg [`SVO_XYBITS-1:0] hcursor, vcursor;
	reg [`SVO_XYBITS-6:0] x, y;
	reg [4:0] xoff, yoff;
	reg [31:0] rng;
	reg [SVO_BITS_PER_RED-1:0] r;
	reg [SVO_BITS_PER_GREEN-1:0] g;
	reg [SVO_BITS_PER_BLUE-1:0] b;

	wire [32*32-1:0] bolt_bitmap = {
		32'b 00000000000000000000000000000000,32'b 01111111000000000000000001111111,
		32'b 01111100000000000000000000011111,32'b 01110000000000000000000000000111,
		32'b 01100000000000000000000000000011,32'b 01100000000000000000000000000011,
		32'b 01000000000000000000000000000001,32'b 01000000000000000000000000000001,
		32'b 00000000000000000000000000000000,32'b 00000000000000000000000000000000,
		32'b 00000000000000000000000000000000,32'b 00000000000000000000000000000000,
		32'b 00000000000000111100000000000000,32'b 00000000000001111110000000000000,
		32'b 00000000000011111111000000000000,32'b 00000000000011111111000000000000,
		32'b 00000000000011111111000000000000,32'b 00000000000011111111000000000000,
		32'b 00000000000001111110000000000000,32'b 00000000000000111100000000000000,
		32'b 00000000000000000000000000000000,32'b 00000000000000000000000000000000,
		32'b 00000000000000000000000000000000,32'b 00000000000000000000000000000000,
		32'b 00000000000000000000000000000000,32'b 01000000000000000000000000000001,
		32'b 01000000000000000000000000000001,32'b 01100000000000000000000000000011,
		32'b 01100000000000000000000000000011,32'b 01110000000000000000000000000111,
		32'b 01111100000000000000000000011111,32'b 01111111000000000000000001111111
	};


	always @(posedge clk_pixel) begin
		if (!resetn) begin
			hcursor <= 0; vcursor <= 0; x <= 0; y <= 0;
			xoff <= HOFFSET; yoff <= VOFFSET;
			out_axis_tvalid <= 0; out_axis_tdata <= 0; out_axis_tuser <= 0;
		end else
		if (!out_axis_tvalid || out_axis_tready) begin
			out_axis_tdata <= bolt_bitmap[{yoff,  xoff}] ? ~0 : 0;
			out_axis_tuser[0] <= !hcursor && !vcursor; out_axis_tvalid <= 1;
			if (hcursor == SVO_HOR_PIXELS-1) begin
				hcursor <= 0; x <= 0; xoff <= HOFFSET;
				if (vcursor == SVO_VER_PIXELS-1) begin
					vcursor <= 0; y <= 0; yoff <= VOFFSET;
				end else begin
					vcursor <= vcursor + 14'd1;
					if (&yoff) y <= y + 9'd1;
					yoff <= yoff + 5'd1;
				end
			end else begin
				hcursor <= hcursor + 14'd1;
				if (&xoff) x <= x + 9'd1;
				xoff <= xoff + 5'd1;
			end

		end
	end
endmodule
