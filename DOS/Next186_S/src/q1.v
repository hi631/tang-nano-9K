`timescale 1ns / 1ps
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: q1.v
// Description: cross clock domain 1 byte FIFO
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
//////////////////////////////////////////////////////////////////////////////////


module q1(
	   input wr_clk,
		input wr_en,
		input [7:0]din,
		output full,
		
	   input rd_clk,
		input rd_en,
		output reg [7:0]dout,
		output empty
	);

	reg [1:0]stw = 2'b00;   // wr_clk domain write state
	reg [1:0]str = 2'b00;   // rd_clk domain read state
	reg [1:0]wstr = 2'b00;  // wr clk domain read state
	reg [1:0]rstw = 2'b00;  // rd_clk domain write state
	assign full = stw != 2'b00;
	assign empty = str != 2'b01;
	
	always @(posedge wr_clk) begin
		wstr <= str;
		case(stw)
			2'b00: if(wr_en) {stw, dout} <= {2'b01, din};
			2'b01: if(wstr == 2'b10) stw <= 2'b10;	// full
			default: if(wstr == 2'b00) stw <= 2'b00;
		endcase
	end

	always @(posedge rd_clk) begin
		rstw <= stw;
		case(str)
			2'b00: if(rstw == 2'b01) str <= 2'b01;	
			2'b01: if(rd_en) str <= 2'b10;	  // full
			default: if(rstw == 2'b10) str <= 2'b00; 
		endcase
	end
	
endmodule

/*                 +----------------------+
                   |                      |
                   |  write(stw)          |      read(str)
                   V    +-+               |        +-+ 
               +------>>|0|               +--------|0|<<------+
               |        +-+                        +-+ empty  |
               |         |                          |         |
               |         |write            +------>>|         |
               |         |                 |        |         |
               |         V                 |        V         |
               |        +-+                |       +-+        |
               |   full |1|----------------+       |1|        |
               |        +-+                        +-+        |
               |         |                          |         |
               |         |<<-----+                  |read     |
               |         |       |                  |         |
               |         V       |                  V         |
               |        +-+      |                 +-+        |
               |   full |2|---+  +-----------------|2| empty  |
               |        +-+   |                    +-+        |
               |         |    |                     |         |
               |         |    +------------------->>|         |
               +---------+                          +---------+
*/

