`timescale 1ns/1ps
`default_nettype none

module cpm80_top(
	input wire			RESET_n, CLK_27M, USER_n,
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
	// I/O
	input  wire		rxd1,rxd2, // cts1,cts2,
	output wire		txd1,txd2,rts1,rts2,
	input  wire [5:0]   GPIO,
	output wire	[5:0]	LED
    );
	//assign LED    = ~{~n_psRamCS,~n_internalRam1CS,GPIOout[0],SD_SCK,SD_CMD,SD_DAT0};
	assign LED    = RESET_n ? ~GPIOout[5:0] : ~ledf[6:1];
	assign GPIOin = GPIO; 
	wire			clk = CLK_27M;
	wire			n_reset = RESET_n;

	wire	[15:0]	cpuAddress;
	wire	[7:0]	cpuDataOut, cpuDataIn;
	wire			n_WR, n_RD, n_MREQ, n_IORQ;

	wire	[7:0]	basRomOut;
	reg		[7:0] 	psramin, psramout;
	wire	[7:0]	internalRam1DataOut;
	wire	[7:0]	sdCardDataOut;
	wire	[7:0]	interface1DataOut, interface2DataOut, GPIOin;
	wire			n_int1, n_int2;
	wire			n_internalRam1CS;
	wire			n_interface1CS, n_interface2CS, n_GPIOCS;
	wire			n_psRamCS, n_basRomCS,  n_sdCardCS;

	// Z80
	tv80s cpu1 (
		.reset_n(n_reset && init_calib), .clk(cpuClock), .wait_n(~waitreq), 
		.int_n(1'b1), .nmi_n(1'b1), .busrq_n(1'b1), .cen(1'b1),
		.mreq_n(n_MREQ), .iorq_n(n_IORQ), .rd_n(n_RD), .wr_n(n_WR),
		.A(cpuAddress), .di(cpuDataIn), .dout(cpuDataOut) );

	// 8KB BASIC (BAS or CPM)
    Gowin_pROM rom1(
        .reset(~n_reset), .clk(cpuClock), .oce(1'b1), .ce(1'b1),
        .ad(cpuAddress[12:0]), .dout(basRomOut) );
	// 16KB RAM
    Gowin_SP ram1 (
        .reset(~n_reset), .clk(cpuClock), .oce(1'b1), .ce(1'b1),
        .wre(~(n_memWR | n_internalRam1CS)),
        .ad(cpuAddress[13:0]), .din(cpuDataOut), .dout(internalRam1DataOut) );
	
	bufferedUART	io1 (
		.clk(cpuClock),
		.n_wr(n_interface1CS | n_ioWR), .n_rd(n_interface1CS | n_ioRD),
		.n_int(n_int1), .regSel(cpuAddress[0]),
		.dataIn(cpuDataOut), .dataOut(interface1DataOut),
		.rxClock(serialClock), .txClock(serialClock),
		.rxd(rxd1),	.txd(txd1), .n_cts(1'b0), .n_dcd(1'b0) , .n_rts(rts1) );
	bufferedUART	io2 (
		.clk(cpuClock),
		.n_wr(n_interface2CS | n_ioWR), .n_rd(n_interface2CS | n_ioRD),
		.n_int(n_int2), .regSel(cpuAddress[0]),
		.dataIn(cpuDataOut), .dataOut(interface2DataOut),
		.rxClock(serialClock), .txClock(serialClock),
		.rxd(rxd2), .txd(txd2), .n_cts(1'b0), .n_dcd(1'b0), .n_rts(rts2) );
	sd_controller	sd1 (
		.sdCS(SD_CS), .sdMOSI(SD_CMD), .sdMISO(SD_DAT0), .sdSCLK(SD_SCK),
		.n_reset(n_reset), .n_wr(n_sdCardCS | n_ioWR), .n_rd(n_sdCardCS | n_ioRD),
		.regAddr(cpuAddress[2:0]), .dataIn(cpuDataOut), .dataOut(sdCardDataOut),
		.clk(sdClock), .driveLED() //.stsout(stsout),
	);

	// Address Select
	wire n_ioWR  = n_WR | n_IORQ;
	wire n_ioRD  = n_RD | n_IORQ;
	wire n_memWR = n_WR | n_MREQ;
	wire n_memRD = n_RD | n_MREQ;

	assign	n_basRomCS	     = (cpuAddress[15:13] == 3'b000 && ~n_RomActive) ? (1'b0) : (1'b1);	//8KB at 0000 - 1FFF
	assign	n_internalRam1CS = (cpuAddress[15:13] == 3'b111) || (cpuAddress[15:12] == 4'b1101) || (cpuAddress[15:12] == 4'b0000) ? (1'b0) : (1'b1); 	// 0,D,E,Fxxxx
	assign  n_psRamCS        = ~n_basRomCS || ~n_internalRam1CS;
	assign	n_interface1CS	 = (cpuAddress[7:1] == 7'b1000000) ? (1'b0) : (1'b1); // $80-$81 2Bytes
	assign	n_interface2CS	 = (cpuAddress[7:1] == 7'b1000001) ? (1'b0) : (1'b1); // $82-$83 2Bytes
	assign	n_sdCardCS	     = (cpuAddress[7:3] == 5'b10001)   ? (1'b0) : (1'b1); // $88-$8F 8Bytes
	assign	n_GPIOCS         = (cpuAddress[7:1] == 7'b1001000) ? (1'b0) : (1'b1); // $90-$91 2Bytes

	assign	cpuDataIn	= 
				  (~n_interface1CS && ~n_ioRD) ? interface1DataOut
				: (~n_interface2CS && ~n_ioRD) ? interface2DataOut
				: (~n_GPIOCS       && ~n_ioRD) ? GPIOin
				: (~n_sdCardCS     && ~n_ioRD) ? sdCardDataOut
				: (~n_basRomCS               ) ? basRomOut
				: (~n_internalRam1CS         ) ? internalRam1DataOut
				: (~n_psRamCS                ) ? psramout
				: (8'hFF);

	// CPU Wait CTRL
	wire waitsig = ~n_MREQ && ~n_psRamCS;
	wire waittup = waitsig && ~waitsigd;
	reg  waitsigd;
	reg [5:0] waitcount = 0;
	wire waitreq;
	assign waitreq = waittup || waitcount!=0;
	always @(posedge clk_mem) begin
		waitsigd <= waitsig;
		if (waittup && ~rcmatchs) 
			if(n_memRD) waitcount <= 16;	// Write
			else        waitcount <= 22;	// Read
		else if(waitcount!=0) waitcount <= waitcount - 6'd1;
	end

	// PSRAM Byte Access
	reg  [63:0] mlb[0:3];	// psram Buf
	reg  [16:0] rcadr;
	reg  [1:0]  mp;
	wire [4:0]  mbp = cpuAddress[4:0];
	reg  psmd,  pswr, startd, rd_validd;
	reg  dmrd;
	wire rcmatch = rcadr[16:5]=={1'b0, cpuAddress[15:5]} && ~n_memRD ? 1'b1 : 1'b0;
	wire rcmatchs =  rcmatch && waittup;
	always @(posedge clk_mem) begin
		if(~n_reset) begin
			cmd_en <= 0; dmrd <= 0; rcadr <= 17'h10000;
		end else begin
			rd_validd <= rd_valid;
			ps_mptn <= ~(8'h01 << cpuAddress[2:0]);
			psbd <= cpuDataOut; mp <= 0;
			if(waittup && ~rcmatchs) begin
				psmd <= 1; pswr <= n_RD; cmd = n_RD;
				if(~n_RD) rcadr[16:5] = {1'b0, cpuAddress[15:5]};
				else
					if(rcadr[16:5]=={1'b0, cpuAddress[15:5]}) rcadr[16] <= 1;	// Cache discard 
				cmd_en <= 1; 
			end 
			//
			if(rd_valid) begin 	mlb[mp] <= ps_rddt; end
			//
			if(cmd_en) cmd_en <= 0;
			if((psmd && pswr) || rd_valid) mp <= mp + 2'd1;
			if((mp==2'h3) || (~rd_valid && rd_validd) || rcmatch) begin
				case(mbp[2:0])
				3'h0: psramout <= mlb[mbp[4:3]][ 7: 0];
				3'h4: psramout <= mlb[mbp[4:3]][15: 8];
				3'h1: psramout <= mlb[mbp[4:3]][23:16];
				3'h5: psramout <= mlb[mbp[4:3]][31:24];
				3'h2: psramout <= mlb[mbp[4:3]][39:32];
				3'h6: psramout <= mlb[mbp[4:3]][47:40];
				3'h3: psramout <= mlb[mbp[4:3]][55:48];
				3'h7: psramout <= mlb[mbp[4:3]][63:56];
				endcase
				psmd <= 0;
			end 			
		end
	end

	reg         cmd, cmd_en;
	wire [20:0] ps_addr;
	wire [63:0] ps_wrdt, ps_rddt;
	wire [7:0]  ps_mask;
	reg  [7:0]  psbd, ps_mptn;
	wire        rd_valid, clk_mem, init_calib, error;
	assign ps_wrdt = {psbd,psbd,psbd,psbd,psbd,psbd,psbd,psbd};
	assign ps_mask = cpuAddress[4:3]==mp ? ps_mptn : 8'hff;
	assign ps_addr = {5'h0, cpuAddress[15:5], 5'h0};
	PSRAM_Memory_Interface_HS_Top u_psram_top(
		.rst_n(n_reset), .clk(clk), .memory_clk (memory_clk), .pll_lock(pll_lock),
		.O_psram_ck(O_psram_ck), .O_psram_ck_n(O_psram_ck_n),
		.IO_psram_rwds(IO_psram_rwds), .IO_psram_dq(IO_psram_dq),
		.O_psram_reset_n(O_psram_reset_n), .O_psram_cs_n(O_psram_cs_n),
		.addr(ps_addr), .wr_data(ps_wrdt), .rd_data(ps_rddt),
		.cmd(cmd), .cmd_en(cmd_en), .data_mask(ps_mask),
		.rd_data_valid(rd_valid), .clk_out(clk_mem), .init_calib(init_calib)
		);

	// Clock CTRL
	wire memory_clk, cpuClock;
	wire pll_lock;
	Gowin_rPLL clkgen(
		.clkout(memory_clk),	// 159MHz
		.clkoutd(cpuClock),		// 39.75MHz
		.clkin(CLK_27M),		// 27MHz
		.lock(pll_lock)
		);

	reg 	   sdClock,serialClock;
	reg  [15:0]serialClkCount;
	reg  [2:0] sdClkCount;
	always @(posedge cpuClock) begin
		sdClkCount <= sdClkCount + 3'd1;
		sdClock   <= sdClkCount[1];	// 39.75/4=19.875MHz/2
		// @50MHz 115200 2416	// 38400 805	// 19200 403	// 9600 201	// 4800 101	// 2400 50
		serialClkCount <= serialClkCount + 16'd3039; // 115200@39.75MHz
		serialClock    <= serialClkCount[15];
	end

	reg  [7:0] GPIOout;	// GPIO.out
	always @(posedge cpuClock) begin
		if (~n_reset ) begin GPIOout <= 0; end
		else if(~n_GPIOCS && ~n_ioWR) GPIOout <= cpuDataOut;
	end

	// CPM -- Disable ROM if out 38. Re-enable when (asynchronous) reset pressed
	reg 			n_RomActive;	// :='1';
	always @(posedge n_ioWR) begin
		if (n_reset == 1'b0) n_RomActive	<= 1'b0; 
		else //if (rising_edge[n_ioWR]) begin
			if (cpuAddress[7:0] == 8'b00111000) n_RomActive	<= 1'b1;	// $38
	end

	// LED
	reg[24:0] count;
	reg [7:0] ledf;
	parameter CNT_MAX = 25'd6250000;
	always@( posedge CLK_27M ) begin
		if( count == CNT_MAX ) begin
			count <= 0; 
			if(ledf[6:1]==6'h0) ledf <= 3;
			else                ledf <= {ledf[6:0],1'b0};
		end else count <= count + 1'b1;
	end

endmodule
`default_nettype wire
