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

module svo_hdmi_out (
	//input clk,
	input resetn,

	// video clocks
	input clk_pixel,
	input clk_5x_pixel,
	input locked,
	// input VGA
	input [5:0] rout,
	input [5:0] gout,
	input [5:0] bout,
	input       hsync_n,
	input       vsync_n,
	input       hblnk_n,
	// output signals
	output       tmds_clk_n,
	output       tmds_clk_p,
	output [2:0] tmds_d_n,
	output [2:0] tmds_d_p,
	output [5:0] tmds_ts
);
assign tmds_ts[2:0] = video_enc_tdata[3:1];
assign tmds_ts[5:3] = video_enc_tuser[3:1];

	parameter SVO_MODE             =   "640x480V";
	parameter SVO_FRAMERATE        =   60;
	parameter SVO_BITS_PER_PIXEL   =   24;
	parameter SVO_BITS_PER_RED     =    8;
	parameter SVO_BITS_PER_GREEN   =    8;
	parameter SVO_BITS_PER_BLUE    =    8;
	parameter SVO_BITS_PER_ALPHA   =    0;

	localparam [SVO_BITS_PER_PIXEL-1:0] white_pixval = ~0;

	wire vdma_tvalid;
	wire vdma_tready;
	wire [SVO_BITS_PER_PIXEL-1:0] vdma_tdata;
	wire [0:0] vdma_tuser;

	wire video_tvalid;
	wire video_tready;
	wire [SVO_BITS_PER_PIXEL-1:0] video_tdata;
	wire [0:0] video_tuser;

	wire term_out_tvalid;
	// wire term_out_tready;
	wire [1:0] term_out_tdata;
	wire [0:0] term_out_tuser;

	wire video_enc_tvalid, video_enc_tready;
	wire [SVO_BITS_PER_PIXEL-1:0] video_enc_tdata;
	wire [3:0] video_enc_tuser;

	wire [2:0] tmds_d;
	wire [2:0] tmds_serdes_shift1;
	wire [2:0] tmds_serdes_shift2;
	wire [2:0] tmds_d0, tmds_d1, tmds_d2, tmds_d3, tmds_d4;
	wire [2:0] tmds_d5, tmds_d6, tmds_d7, tmds_d8, tmds_d9;

	reg [3:0] locked_clk_q;
	reg [3:0] resetn_clk_pixel_q;

	always @(posedge clk_pixel)
		locked_clk_q <= {locked_clk_q, locked};

	always @(posedge clk_pixel)
		resetn_clk_pixel_q <= {resetn_clk_pixel_q, resetn};

	wire clk_resetn = resetn && locked_clk_q[3];
	wire clk_pixel_resetn = locked && resetn_clk_pixel_q[3];

	svo_tcard #( `SVO_PASS_PARAMS ) svo_tcard (
		.clk_pixel(clk_pixel),
		.resetn(resetn),

		.out_axis_tvalid(vdma_tvalid),
		.out_axis_tready(vdma_tready),
		.out_axis_tdata(vdma_tdata),
		.out_axis_tuser(vdma_tuser)
	);

assign video_tvalid = vdma_tvalid;
assign video_tdata  = vdma_tdata;
assign video_tuser  = vdma_tuser;
assign vdma_tready  = video_tready;

wire [23:0] enc_tdata;
wire [3:0]  enc_tuser;

//assign video_enc_tdata = enc_tdata;
//assign video_enc_tuser = enc_tuser;
assign video_enc_tdata = {bout,2'b00,gout,2'b00,rout,2'b00};
assign video_enc_tuser = {hblnk_n,vsync_n,hsync_n,1'b0}; 

	svo_enc #( `SVO_PASS_PARAMS ) svo_enc (
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),

		.in_axis_tvalid(video_tvalid),
		.in_axis_tready(video_tready),
		.in_axis_tdata(video_tdata),
		.in_axis_tuser(video_tuser),

		.out_axis_tvalid(),					// output No.Use
		.out_axis_tready(1'b1),				// input  assign video_enc_tready = 1;
		.out_axis_tdata(enc_tdata),	// output
		.out_axis_tuser(enc_tuser)	// output B,V,H,S
			//   tuser[0] ... start of frame
			//   tuser[1] ... hsync
			//   tuser[2] ... vsync
			//   tuser[3] ... Hblank
	);

	svo_tmds svo_tmds_0 (
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(video_enc_tuser[2:1]),
		.din(video_enc_tdata[23:16]),
		.dout({tmds_d9[0], tmds_d8[0], tmds_d7[0], tmds_d6[0], tmds_d5[0],
		       tmds_d4[0], tmds_d3[0], tmds_d2[0], tmds_d1[0], tmds_d0[0]})
	);

	svo_tmds svo_tmds_1 (
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(2'b0),
		.din(video_enc_tdata[15:8]),
		.dout({tmds_d9[1], tmds_d8[1], tmds_d7[1], tmds_d6[1], tmds_d5[1],
		       tmds_d4[1], tmds_d3[1], tmds_d2[1], tmds_d1[1], tmds_d0[1]})
	);

	svo_tmds svo_tmds_2 (
		.clk(clk_pixel),
		.resetn(clk_pixel_resetn),
		.de(!video_enc_tuser[3]),
		.ctrl(2'b0),
		.din(video_enc_tdata[7:0]),
		.dout({tmds_d9[2], tmds_d8[2], tmds_d7[2], tmds_d6[2], tmds_d5[2],
		       tmds_d4[2], tmds_d3[2], tmds_d2[2], tmds_d1[2], tmds_d0[2]})
	);
    
	OSER10 tmds_serdes [2:0] (
		.Q(tmds_d),
		.D0(tmds_d0), .D1(tmds_d1), .D2(tmds_d2), .D3(tmds_d3),
		.D4(tmds_d4), .D5(tmds_d5), .D6(tmds_d6), .D7(tmds_d7),
		.D8(tmds_d8), .D9(tmds_d9),
		.PCLK(clk_pixel), .FCLK(clk_5x_pixel),
		.RESET(~clk_pixel_resetn)
	);
	
	ELVDS_OBUF tmds_bufds [3:0] (
		.I({clk_pixel, tmds_d}),
		.O({tmds_clk_p, tmds_d_p}),
		.OB({tmds_clk_n, tmds_d_n})
	);

endmodule
