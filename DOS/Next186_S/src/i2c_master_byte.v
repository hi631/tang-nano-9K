`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nicolae Dumitrache
// 
// Create Date:    14:18:38 20Mar2015 
// Design Name: 
// Module Name:    i2c master byte
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module i2c_master_byte
	(
		input refclk,	// 25Mhz=100Kbps...100Mhz=400Kbps
		input [7:0]din,
		input [3:0]cmd,	// 01xx=wr,10xx=rd+ack, 11xx=rd+nack, xx1x=start, xxx1=stop
		output reg [7:0]dout,
		output reg ack,
		output noack,
		output SCL,
		inout SDA,
		input rst
	);

	reg [8:0]rdin;
	reg rstop;
	reg rrd;
	reg b0;
	reg [1:0]STATE = 0;
	reg [7:0]divclk;
	reg [1:0]scmd = 0;
	reg [3:0]rdck = 4'b0000;
	reg [3:0]cpat = 4'b1111;
	reg [1:0]dpat = 2'b11;
	reg [3:0]dbit;
	wire sclk = cpat[rdck[3:2]];
	wire [1:0]cs = rdck[1:0] != divclk[7:6] ? rdck[1:0] : 2'b00; // clock stage
	assign SCL = sclk;// ? 1'bz : 1'b0;
	assign SDA = dpat[rdck[3]] ? 1'bz : 1'b0;
	assign noack = b0 && !rrd;

	always @(posedge refclk) begin
		rdck <= {rdck[1:0], divclk[7:6]};
		scmd <= {scmd[0], |cmd};
		if(STATE == 0) divclk <= 0;
		else if(!sclk || SCL) divclk <= divclk + 1'b1; // take in account the clock stretching

		if(rst) STATE <= 0;
		else case(STATE)
			0: begin
				if({ack, scmd} == 3'b011) begin
					rdin <= {cmd[3] ? 8'hff : din , cmd[2]};
					rstop <= cmd[0];
					rrd <= cmd[3];
					STATE <= cmd[1] ? 2'd1 : 2'd2;
					ack <= 1'b1;
					dbit <= 0;
				end else if(scmd == 2'b00) ack <= 1'b0;
			end 
			1: begin
				cpat[3:1] <= 3'b011;
				dpat <= 2'b01;
				if(cs == 2'b11) STATE <= 2'd2;
			end
			2: begin
				cpat <= 4'b0110;
				dpat <= {2{rdin[8]}};
				if(cs == 2'b01) {dout, b0} <= {dout[6:0], b0, SDA};
				if(cs == 2'b11) begin
					rdin <= {rdin[7:0], 1'bx};
					dbit <= dbit + 1'b1;
					if(dbit[3]) STATE <= (rstop || b0 && !rrd) ? 2'd3 : 2'd0;
				end
			end
			3: begin
				cpat <= {3'b111, cs[1]};
				dpat <= {1'b1, cs[1]};
				if(cs == 2'b11) STATE <= 2'd0;
			end
		endcase
	end
	
endmodule
