`default_nettype none
//`define DumyDO

module mem_controller(
	 input  wire [20:0] addr,
	 output wire [31:0] dout,
	 input  wire [31:0] din,
	 input  wire clk,	
	 input  wire mreq,
	 input  wire [3:0]  wmask,
	 output wire ce,	// clock enable for CPU

	// PSRAM(Internal connection)
	input  wire			reset,
	input  wire			psram_clk,
	input  wire			pll_lock,
	output wire			ps_calib,
	output wire [1:0] 	O_psram_ck,
	output wire [1:0] 	O_psram_ck_n,
	inout  wire [1:0] 	IO_psram_rwds,
	inout  wire [15:0]	IO_psram_dq,
	output wire [1:0] 	O_psram_reset_n,
	output wire [1:0] 	O_psram_cs_n,

	// VGA Data Read
	output wire        clk_mctr,
	input  wire        vblnk,
	input  wire [1:0]  sys_CMD,
	input  wire [23:0] sdraddr,
	output reg  [1:0]  sys_cmd_ack,
	output wire [15:0] sys_DOUT,
	output reg         sys_rd_data_valid, 
	 input wire flush
    );

	reg  boot_rom_csd, bios_rom_csd, boot_ram_csd;
	reg  move_rom, bios_rom_kill;
	//reg  [1:0] nmivec_wc;
	reg  xram_csd;
	reg [7:0] xram_ad;
	reg  [63:0] mlb[0:7];	// psram Buf(64Byte=8Byte x 4)
	always @(posedge clk) begin
		if(reset) begin move_rom <= 0; bios_rom_kill <= 0; end
		else begin
			boot_rom_csd <= boot_rom_cs; bios_rom_csd <= bios_rom_cs; 
			boot_ram_csd <= boot_ram_cs; xram_csd <= xram_cs;
			xram_ad <= addr[7:0];
			if(mreq && addr[19:12]==8'hfc && ~WRE) move_rom <= 1;
			if(mreq && addr[19: 0]==20'hffffe && WRE) bios_rom_kill <= 1;
			if(ce) psram_dout <= mbp[2] ? mlb[mbp[5:3]][63:32] : mlb[mbp[5:3]][31:0];
		end
	end

assign ce        = ~((psram_cs && ~sddtac) || xram_dis);
wire trgadr      = mreq && addr[15:4]=={12'hcff} ? 1'b1 : 1'b0;	// xcffx Trigger addr
wire xram_cs     = mreq && addr[19:8]=={12'hfca}  ? 1'b1 : 1'b0;	// fcaxx insart ~ce 1cycl
wire xram_dis    = xram_cs && xram_ad!=addr[7:0];
wire int10adr    = mreq && addr[19:4]==16'h0004  ? 1'b1 : 1'b0;
wire WRE         = wmask!=4'b0000;
wire boot_ram_cs = mreq && addr[19:10]=={8'hfc,2'b10} ? 1'b1 : 1'b0;			// ff800 - ffbff
wire boot_rom_cs = mreq && ((addr[19:12]==8'hff && ~move_rom) || addr[19:12]==8'hfc) && ~boot_ram_cs   ? 1'b1 : 1'b0;	// ff000 - fffff 
wire bios_rom_cs = mreq && ~WRE && (addr[19:16]==4'hf && addr[15:13]==3'b111) && ~bios_rom_kill ? 1'b1 : 1'b0;	// fe000 - fffff 
wire psram_cs    = mreq && ~boot_rom_cs && ~bios_rom_cs && ~boot_ram_cs ? 1'b1 : 1'b0;
assign dout =   ~ce ? dout : 
				boot_rom_csd ? boot_rom_dout :
				boot_ram_csd ? boot_ram_dout :
				bios_rom_csd ? bios_rom_dout :
				psram_dout;

;wire [9:0]  boot_rom_addr = addr[11:2];
wire [31:0] boot_rom_dout;
    Gowin_pROM_boot bootrom(
        .clk(clk), .ad(addr[11:2]), .dout(boot_rom_dout), .oce(1'b1), .ce(1'b1), .reset(1'b0) );

wire [31:0] bios_rom_dout;
    Gowin_pROM_bios bios(
        .clk(clk), .ad(addr[12:2]), .dout(bios_rom_dout),
        .oce(1'b1), .ce(1'b1), .reset(1'b0)
    );


wire [7:0]  boot_ram_addr = addr[9:2];
wire [31:0] boot_ram_dout;
    Gowin_SP_256x8 bootram0(
        .clk(clk), .ad(boot_ram_addr), .oce(1'b1), .ce(1'b1), .reset(1'b0),
        .din(din[7:0]),   .dout(boot_ram_dout[7:0]),   .wre(wmask[0] && boot_ram_cs && WRE) );
    Gowin_SP_256x8 bootram1(
        .clk(clk), .ad(boot_ram_addr), .oce(1'b1), .ce(1'b1), .reset(1'b0),
        .din(din[15:8]),  .dout(boot_ram_dout[15:8]),  .wre(wmask[1] && boot_ram_cs && WRE) );
    Gowin_SP_256x8 bootram2(
        .clk(clk), .ad(boot_ram_addr), .oce(1'b1), .ce(1'b1), .reset(1'b0),
        .din(din[23:16]), .dout(boot_ram_dout[23:16]), .wre(wmask[2] && boot_ram_cs && WRE) );
    Gowin_SP_256x8 bootram3(
        .clk(clk), .ad(boot_ram_addr), .oce(1'b1), .ce(1'b1), .reset(1'b0),
        .din(din[31:24]), .dout(boot_ram_dout[31:24]), .wre(wmask[3] && boot_ram_cs && WRE) );

    // ========================================================================
    // 1 MB DRAM at $00000 - $fefff
    // ========================================================================
	wire psram_csu = psram_cs  && (~psram_csd);
	wire pswr      = psram_cs ? WRE : 0;
	reg  adrchgh, adrchgd, psram_csd, sddtac;
	reg  [5:0]  tmcnt;
	reg  [5:2]  mbp;
	reg  [3:0]  psbp;
	reg         psone, rd_validd, dcsdlyf;
	reg  [24:0] rcadr;
	wire rcmatch = rcadr[24:6]=={1'b1, psadr[23:6]} ? 1'b1 : 1'b0;

	always @(posedge clk_mctr) begin
		if(reset) begin
			cmd0_en <= 0; cmd0_bsy <= 0; cmd0_req <= 0; tmcnt <= 0; rcadr[24] <= 0;
		end else begin
			psram_csd <= psram_cs;
			mbp[5:2] <= psadr[5:2];
			if(psram_csu || (psram_cs && tmcnt==0))
				if((~pswr && ~rcmatch) || pswr ) cmd0_req <= 1;
				else          tmcnt <=  2;	// Cache.Hit
			if(cmd0_run) begin	// Wait For req -> run
					cmd0_en <= 1; cmd0 <= psram_cs &&  pswr; psbp <= 0;
					if(~pswr) tmcnt <= 22+4;	// Read.Delay	// burst length is 16, the command interval is at least 15 clock
					else      tmcnt <= 18+4;	// Write.Delay
					cmd0_bsy <= 1;
				cmd0_req <= 0;
			end
			if(cmd0_en) cmd0_en <= 0;
			//
			if(cmd0_bsy) begin
				if(rd_valid) mlb[psbp] <= ps_rddt;
				if((pswr && psbp<8) || rd_valid) psbp <= psbp + 4'd1;
			end
			//
			//if(cmd1_run) rcadr[24] <= 0;
			if(tmcnt==2) begin
				sddtac <= 1;
				if(~pswr) rcadr[24:6] <= {1'b1, psadr[23:6]};	// Cache.Addr set
				else if(rcmatch) rcadr[24] <= 0;				// Cache.Addr discard 
			end 
			else if(tmcnt==1) cmd0_bsy <= 0;
			else if(tmcnt==0) sddtac <= 0;
			if(tmcnt!=0) tmcnt <= tmcnt - 6'd1;
		end
	end

	reg  [31:0] psram_dout;
	wire [23:0] ps_addr0 = {psadr[23:6], 5'h0};
	wire [7:0]  ps_mask0 = psadr[5:3]==psbp[2:0] ? ps_mptn : 8'hff;
	wire [7:0]  ps_mptn  = ~({2'b00,wmask[3],wmask[1],2'b00,wmask[2],wmask[0]} << {6'h0,psadr[2],1'b0});
	wire [63:0] ps_wrdt  = {psbd,psbd,psbd,psbd};						// Write.DataSet(64bit)
	wire [15:0] psbd     = din[15:0]; 
	wire [23:0] psadr    = {3'b000,addr[20:2],2'b00};

    // ========================================================================
    // PSRAM(Max8MB) Use 1MB 
    // ========================================================================
	wire cmd_en         = cmd0_bsy ? cmd0_en  : cmd1_en;
	wire cmd            = cmd0_bsy ? cmd0     : cmd1;
	wire [23:0] ps_addr = cmd0_bsy ? ps_addr0 : ps_addr1;
	wire [7:0]  ps_mask = cmd0_bsy ? ps_mask0 : ps_mask1;

	reg  cmd0 = 0, cmd0_en = 0;
	reg  cmd1 = 0, cmd1_en = 0;
	reg  cmd0_req = 0, cmd0_run = 0, cmd0_bsy = 0;
	reg  cmd1_req = 0, cmd1_run = 0, cmd1_bsy = 0;
	wire cmd_bsy = cmd0_run || cmd1_run || cmd0_bsy || cmd1_bsy;
	always @(posedge clk_mctr) begin
		if(cmd1_req && ~cmd_bsy) cmd1_run <= 1;
		else begin 	             cmd1_run <= 0;
			if(cmd0_req && ~cmd_bsy) cmd0_run <= 1;
			else                     cmd0_run <= 0;
		end
	end

	wire [63:0] ps_rddt;
	wire        rd_valid, clk_mctr, ps_calib, error;
	PSRAM_Memory_Interface_HS_Top_B32 u_psram_top(
		.rst_n(~reset), .clk(clk), .memory_clk (psram_clk), .pll_lock(pll_lock),
		.O_psram_ck(O_psram_ck), .O_psram_ck_n(O_psram_ck_n),
		.IO_psram_rwds(IO_psram_rwds), .IO_psram_dq(IO_psram_dq),
		.O_psram_reset_n(O_psram_reset_n), .O_psram_cs_n(O_psram_cs_n),
		.addr({~ps_addr[21],ps_addr[20:1]}), .wr_data(ps_wrdt), .rd_data(ps_rddt),
		.cmd(cmd), .cmd_en(cmd_en), .data_mask(ps_mask),
		.rd_data_valid(rd_valid), .clk_out(clk_mctr), .init_calib(ps_calib)
		);
    // ========================================================================
    // VGA Data Read
    // ========================================================================
	reg  [63:0] mvb[0:7];
	wire [23:0] ps_addr1 = {sdraddr[22:0],1'b0};
	reg  [3:0]  ps_mask1;
	reg  [5:0]  ddrrct, psvadr;
	reg  [3:0]  psbpv;
	wire        cmd1_dmv = sys_rd_data_valid;
	reg  [23:0] psvadrb;
	reg         ss_match;
	wire rd_match = rd_matcht;
	reg  cmd1_reqd, rd_matcht;
	wire vstart = ps_addr1[23:8]==16'h0b80 ? 1 : 0;

`ifndef DumyDO	 
	//assign sys_DOUT = {8'h01,8'h41+psvadr};
	assign sys_DOUT = psvadr[1:0]==2'd3 ?  mvb[psvadr[4:2]][63:48] : 
					  psvadr[1:0]==2'd2 ?  mvb[psvadr[4:2]][47:32] :
					  psvadr[1:0]==2'd1 ?  mvb[psvadr[4:2]][31:16] :
										   mvb[psvadr[4:2]][15: 0] ;   
	always @(posedge clk_mctr) begin
		if(reset) begin
			cmd1_en <= 0; cmd1_bsy <= 0; ss_match <= 0;
		end else begin
			rd_validd <= rd_valid; cmd1_reqd <= cmd1_req;
			if(sys_CMD==2'b10) cmd1_req <= 1; 
			if(~cmd1_req && cmd1_reqd) psvadrb <= ps_addr1; 
			if(cmd1_run) begin
				if(~rd_match) begin
					cmd1_en <= 1; cmd1 <= 0; psvadr[4] <= 0; ddrrct <= 6'd40;
				end else begin
					ss_match <= 1; ddrrct <= 6'd40-22; psvadr[4] <= 1;
				end
				cmd1_req <= 0; ps_mask1 <= 4'b0000;
				psbpv <= 0; sys_cmd_ack <= 2'b10; cmd1_bsy <= 1; 
			end
			if(cmd1_en) cmd1_en <= 0;
			//
			if(cmd1_bsy) begin
				if(rd_valid && ~rd_match) begin mvb[psbpv] <= ps_rddt; psbpv <= psbpv + 4'd1; end
				if((~rd_valid && rd_validd) || ss_match) begin 
					sys_rd_data_valid <= 1; psvadr[3:0] <= 0; sys_cmd_ack <= 2'b00; 
					ss_match <= 0; 
				end else begin
					if(psvadr[3:0]!=15) psvadr <= psvadr + 1;
					else 				sys_rd_data_valid <= 0;
				end
				//
				if(ddrrct==1)
					if(ps_addr1[23:5]==psvadrb[23:5] && ps_addr1[4]) rd_matcht <= 1;
					else                                             rd_matcht <= 0; 
				if(ddrrct!=0) ddrrct <= ddrrct - 1;
				else cmd1_bsy <= 0;
			end
		end
	end

`else
//--  Dumy.Data gen  --------
	assign sys_DOUT = {8'h01,8'h30};
	reg [5:0] ddrrct;
	always @ (posedge clk_mctr) begin
		if(sys_CMD==2'b10 && ddrrct==0) begin ddrrct <= 24; sys_cmd_ack <= 2'b10; end // 8+16
		if(ddrrct==16) begin sys_rd_data_valid <= 1; sys_cmd_ack <= 2'b00; end
		if(ddrrct== 1) sys_rd_data_valid <= 0;
		if(ddrrct!=0) ddrrct <= ddrrct - 1;
	end
//-----------------------------	
`endif

endmodule
`default_nettype wire
