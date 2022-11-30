`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: uart_8250.v
// Description: Part of the Next186 SoC PC project, simplified 8250 UART implementation
// Version 1.0
// Creation date: Sep2016
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2016 Nicolae Dumitrache
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
// Only 8bit, 1stop bit, no parity 
// no scratch register, no FIFO, no hw flow control
//////////////////////////////////////////////////////////////////////////////////

module UART_8250(
		input CLK_18432000,
		input RS232_DCE_RXD,
		output RS232_DCE_TXD,
		input clk,
		input [7:0]din,
		output reg [7:0]dout,
		input cs,
		input wr,
		input [2:0]addr,
		input [1:0]BRShift,
		output INT
    );

	wire [7:0]rdata;
	wire [7:0]wdata;
	wire [7:0]dout0;
	wire rdata_rdy;
	wire rdata_ovr;
	wire wdata_rdy;
	reg new_wdata = 1'b0;
	reg [15:0]div;
	wire wfull;
	wire wempty;
	wire rfull;
	wire rempty;
	reg [1:0]rwd = 2'b00;
	reg rdd = 1'b0;
	reg [3:0]IER = 8'h00;
	reg [7:0]LCR = 8'h00;
//	reg [7:0]MCR = 8'h00;
//	reg [7:0]SCR = 8'h00;
	reg [2:0]IIR = 3'b001;
	reg wint = 1'b0;
	wire dlab = LCR[7];
	reg rdok = 1'b0;
	wire [15:0]divider = {div[13:0], 4'b0000} >> BRShift;
	
	assign INT = !IIR[0];

	rs232_phy rs232_phy_inst
	(
		.CLK_18432000(CLK_18432000), 
		.RS232_DCE_RXD(RS232_DCE_RXD),
		.RS232_DCE_TXD(RS232_DCE_TXD),
		.div(divider),
		.rdata(rdata),
		.rdata_rdy(rdata_rdy),	// when rdata_rdy=1, keep rd=1 until rdata_rdy=0. (!)asserted on the same clock edge as rdata
		.rdata_ovr(rdata_ovr),	// data override (resets when rd=1)
		.wdata_rdy(wdata_rdy),	
		.rd(rdd),
		.wr(rwd == 2'b01),
		.wdata(wdata) 				// set wdata when wdata_rdy=1, keep it with wr=1 until wdata_rdy=0, then drive wr=0 until wdata_rdy=1
	);
/* ////	
	q1 rs232_wr
	(
	  .wr_clk(clk), // input wr_clk
	  .rd_clk(CLK_18432000), // input rd_clk
	  .din(din), // input [7 : 0] din
	  .wr_en(cs && wr && (addr == 3'b000) && !dlab), // input wr_en
	  .rd_en(&rwd), // input rd_en
	  .dout(wdata), // output [7 : 0] dout
	  .full(wfull), // output full
	  .empty(wempty) // output empty
	);
	
	q16 rs232_rd
	(
	  .wrclk(CLK_18432000), // input wr_clk
	  .rdclk(clk), // input rd_clk
	  .data(rdata), // input [7 : 0] din
	  .wrreq(!rdd && rdata_rdy), // input wr_en
	  .rdreq(!rdok && !rempty), // input rd_en
	  .q(dout0), // output [7 : 0] dout
	  .wrfull(rfull), // output full
	  .rdempty(rempty) // output empty
	);
*/
	always @(*) begin
		case(addr)
			3'b000: dout = dlab ? div[7:0] : dout0;
			3'b001: dout = dlab ? div[15:8] : {4'b0000, IER};
			3'b010: dout = {5'b0000, IIR};			// FCR
			3'b011: dout = {LCR[7], 7'b0000011};	// LCR
			3'b100: dout = 8'h00;			// MCR
			3'b101: dout = {1'b0, wdata_rdy, !wfull, 3'b000, rdata_ovr, rdok};	// LSR
			3'b110: dout = 8'b10000000;	// MSR
			3'b111: dout = 8'h00;			// SCR 
		endcase
	end
	
	always @(posedge CLK_18432000) begin
		case(rwd)
			2'b00: if(!wempty && wdata_rdy) rwd <= 2'b01;
			2'b01: if(!wdata_rdy) rwd <= 2'b11;
			default: rwd <= 2'b00;
		endcase
		if(!rfull || rdd) rdd <= rdata_rdy;
	end
	
	always @(posedge clk) begin
		if(cs && wr) case(addr)
			3'b000: if(dlab) div[7:0] <= din;
					  else wint <= 1'b1;
			3'b001: if(dlab) div[15:8] <= din;
					  else IER <= din[3:0];
			3'b011: LCR[7] <= din[7];
//			3'b100: MCR <= din;
//			3'b111: SCR <= din;
		endcase
		
		if(!rdok) rdok <= !rempty;
		else if(cs && !wr && (addr == 3'b000) && !dlab) rdok <= 1'b0;
		
		if(IIR[0]) begin
			if(rdok && IER[0]) IIR <= 3'b100;
			else if(!wfull && wint && IER[1]) {wint, IIR} <= {1'b0, 3'b010};
		end else if(cs)
			if((IIR[2:1] == 2'b10) && !wr && (addr == 3'b000) && !dlab ||  // read receive buffer RBR
			   (IIR[2:1] == 2'b01) && (!wr && (addr == 3'b010) || 			  // read IIR 
											  	 wr && (addr == 3'b000) && !dlab)) IIR[0] <= 1'b1;	// write transmit buffer THR
	end

endmodule

