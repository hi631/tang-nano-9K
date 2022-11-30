`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: rs232_phy .v
// Description: Part of the Next186 SoC PC project, rs232 physical interface
// Version 1.0
// Creation date: Aug2015
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2015 Nicolae Dumitrache
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


module rs232_phy (
		input CLK_18432000, 
		input RS232_DCE_RXD,
		output reg RS232_DCE_TXD,
		input [15:0]div,
		output reg [7:0]rdata,
		output reg rdata_rdy = 1'b0,	// when rdata_rdy=1, keep rd=1 until rdata_rdy=0. (!)asserted on the same clock edge as rdata
		output reg rdata_ovr = 1'b0,	// data override (resets when rd=1)
		output reg wdata_rdy = 1'b0,	
		input rd,
		input wr,
		input [7:0]wdata // set wdata when wdata_rdy=1, keep it with wr=1 until wdata_rdy=0, then drive wr=0 until wdata_rdy=1
	);
	
	reg [15:0]cnt = 16'h0000;
	reg [1:0]STATE = 3'b000;
	reg [6:0]WSTATE = 6'b000000;
	reg [6:0]sample = 7'h00;
	reg [6:0]rdata1;
	reg [7:0]wdata1;
	reg sending = 1'b0;
	reg swr = 1'b0;
	reg sRS232_DCE_RXD = 1'b0;
	wire [15:0]cnt1 = cnt + 1'b1;
	wire ce = cnt1 == div;
	wire [9:0]wdata2 = {1'b1, wdata1, 1'b0};
		
	
	always @(posedge CLK_18432000) begin
		cnt <= ce ? 16'h0000 : cnt1;
		RS232_DCE_TXD <= wdata2[WSTATE[6:3]] | !sending;
		swr <= wr;
		sRS232_DCE_RXD <= RS232_DCE_RXD;
		
		if(ce) begin
// read
			case(STATE)
				0: if(sRS232_DCE_RXD) sample <= 7'h00;
				   else begin
						sample <= sample + 1'b1;
						if(sample[2]) STATE <= 1;
				   end
				1: begin
					sample <= sample + 1'b1;
					if(!sample[2]) STATE <= 2;
				end
				2: begin
					sample <= sample + 1'b1;
					if(sample[2]) 
						case({sample[6], sample[3]})
							2: begin 		// last data bit
								if(!rdata_rdy) rdata <= {sRS232_DCE_RXD, rdata1};
								else rdata_ovr <= 1'b1;
								rdata_rdy <= 1'b1;
								STATE <= 1;
							end
							3: begin
								sample <= 7'h00;
								STATE <= 0;	// stop bit
							end
							default: begin
								rdata1 <= {sRS232_DCE_RXD, rdata1[6:1]};
								STATE <= 1;
							end
						endcase
				end
			endcase
// write
			if(WSTATE == 7'b1001111) WSTATE <= 7'b000000;
			else WSTATE <= WSTATE + sending;
				
			if(WSTATE == 7'b1001111 || !sending) begin
				sending <= swr;
				if(swr) wdata1 <= wdata;
				wdata_rdy <= !swr;
			end else if(!swr) wdata_rdy <= 1'b1;
				
		end 
			
		if(rd && rdata_rdy) begin
			rdata_rdy <= 1'b0;
			rdata_ovr <= 1'b0;
		end

	end
	
endmodule
	