// Copyright 2011-2018 Frederic Requin
//
// This file is part of the MCC216 project
//
// The J68 core:
// -------------
// Simple re-implementation of the MC68000 CPU
// The core has the following characteristics:
//  - Tested on a Cyclone III (90 MHz) and a Stratix II (180 MHz)
//  - from 1500 (~70 MHz) to 1900 LEs (~90 MHz) on Cyclone III
//  - 2048 x 20-bit microcode ROM
//  - 256 x 28-bit decode ROM
//  - 2 x block RAM for the data and instruction stacks
//  - stack based CPU with forth-like microcode
//  - not cycle-exact : needs a frequency ~3 x higher
//  - all 68000 instructions are implemented
//  - almost all 68000 exceptions are implemented (only bus error missing)
//  - only auto-vector interrupts supported

//`default_nettype none
module soc_j68 (
    input           clk27M,
	// PSRAM(Internal connection)
	output wire [1:0] 	O_psram_ck,
	output wire [1:0] 	O_psram_ck_n,
	inout  wire [1:0] 	IO_psram_rwds,
	inout  wire [15:0]	IO_psram_dq,
	output wire [1:0] 	O_psram_reset_n,
	output wire [1:0] 	O_psram_cs_n,
	// SDCARD
	output 		SD_CS,		// CS
	output 		SD_SCK,		// SCLK
	output 		SD_CMD,		// MOSI
	input  		SD_DAT0,	// MISO
    // UART #0 (Load port) / UART #1 (Terminal)
    input           uart0_rxd,uart1_rxd,
    output          uart0_txd, uart0_rts_n,uart1_txd, uart1_rts_n,
	 //
	input  [1:0] 	BTN,	// BTN[1]=reset
    output [5:0]	LED
);
	assign LED = ~{w_sysmd[7],w_sysmd[13:12]==2'b01,2'b00,scctl_cmd[1] && sdacc,scctl_cmd[0] && sdacc} ;

	reg clk;
    wire rst         = !locked;
    wire clk_ena     = 1;
	wire init_calib;
    wire uart0_cts_n = 0;
	 wire uart0_dcd_n = 0;
    wire uart1_cts_n = 0;
	 wire uart1_dcd_n = 0;
    
    // Peripherals
    reg   [9:0] r_eclk;
    reg         r_ser_clk;
    reg   [5:0] r_ser_ctr;
    wire        w_uart0_txd;
    reg   [2:0] r_uart0_txd;
    reg   [2:0] r_uart0_rxd;
    wire        w_uart1_txd;
    reg   [2:0] r_uart1_txd;
    reg   [2:0] r_uart1_rxd;
    
    // Read/write controls
    reg         r_rden_dly;
    wire        w_cpu_rden;
    wire        w_cpu_wren;
    wire        w_cpu_rw_n;
    wire        w_cpu_dtack;
    
    // Address bus
    wire  [1:0] w_cpu_bena;
    wire [31:0] w_cpu_addr;
    wire        w_cpu_vpa;
    
    // Data bus
    wire [15:0] w_cpu_wdata;
    wire [15:0] w_cpu_rdata;
    wire [15:0] w_q_rom;
    wire [15:0] w_q_ram;
    wire [15:0] w_q_bram;
    wire [15:0] w_q_scram;
    wire [15:0] w_q_dram;
    reg   [7:0] r_q_acia;
    wire  [7:0] w_aciaa_data_out;
    wire        w_aciaa_data_en;
    wire  [7:0] w_aciab_data_out;
    wire        w_aciab_data_en;
    
    // Interrupts
    wire  [2:0] w_cpu_fc;
    reg   [2:0] r_cpu_ipl_n;
    wire        w_irq_1_n;
    wire        w_irq_2_n;
    wire        w_irq_3_n;
    
    // Debug
    reg  [31:0] r_dbg_regs[15:0];
    wire  [3:0] w_dbg_reg_addr;
    wire  [3:0] w_dbg_reg_wren;
    wire [15:0] w_dbg_reg_data;
    wire [15:0] w_dbg_sr_reg;
    wire [31:0] w_dbg_pc_reg;
    wire [31:0] w_dbg_usp_reg;
    wire [31:0] w_dbg_ssp_reg;
    wire [31:0] w_dbg_cycles;
    wire        w_dbg_ifetch;
    wire  [2:0] w_dbg_irq_lvl;
	 
    // ========================================================================
    // 68000 core
    // ========================================================================
	wire [2:0] ipl_n = req_brk ? 3'b000 : r_cpu_ipl_n;	// bp Break

    cpu_j68 U_j68
    (
        .rst          (rst || ~init_calib), //sdwait),
        .clk          (clk),
        .clk_ena      (clk_ena),
        .rd_ena       (w_cpu_rden),
        .wr_ena       (w_cpu_wren),
        .data_ack     (w_cpu_dtack),
        .byte_ena     (w_cpu_bena),
        .address      (w_cpu_addr),
        .rd_data      (w_cpu_rdata),
        .wr_data      (w_cpu_wdata),
        .fc           (w_cpu_fc),
        .ipl_n        (ipl_n),
        .dbg_reg_addr (w_dbg_reg_addr), .dbg_reg_wren (w_dbg_reg_wren), .dbg_reg_data (w_dbg_reg_data),
        .dbg_sr_reg   (w_dbg_sr_reg), .dbg_pc_reg   (w_dbg_pc_reg),
        .dbg_usp_reg  (w_dbg_usp_reg), .dbg_ssp_reg  (w_dbg_ssp_reg),
        .dbg_vbr_reg  (), .dbg_cycles   (w_dbg_cycles),
        .dbg_ifetch   (w_dbg_ifetch), .dbg_irq_lvl  (w_dbg_irq_lvl),
		.dbg_pc_nxt	  (dbg_pc_nxt)
    );
	wire [10:0] dbg_pc_nxt;    

    // Write control
    assign w_cpu_vpa  = w_acia_a_cs || w_acia_b_cs || w_scctl_cs || w_sysmd_cs;
	assign w_cpu_smem = w_rom_cs || w_bram_cs || w_ram_cs || w_scram_cs;
    assign w_cpu_rw_n = w_cpu_rden & ~w_cpu_wren;
	wire w_cpu_rwen  = w_cpu_rden || w_cpu_wren;
	wire w_rom_cs    = ((w_cpu_addr[23:16]==8'h00 && w_cpu_addr[15:14] == 2'b00 && ~w_sysmd[7]) ||	// 000000 - 003fff 
	                    (w_cpu_addr[23:16]==8'hff && w_cpu_addr[15:14] == 2'b01)) && w_cpu_rwen;	// FF4000 - ff7fff MON68K
	wire w_bram_cs   = 0;//w_cpu_addr[23:16]==8'hfF && w_cpu_addr[15:13] == 3'b011 && w_cpu_rwen; // FF6000 - FF7FFF BIOS_RAM
 	wire w_ram_cs    = w_cpu_addr[23:16]==8'hFF && w_cpu_addr[15:13] == 3'b001 && w_cpu_rwen; // FF2000 - FF3FFF
	wire w_dram_cs   = w_cpu_addr[23]==1'b0 && ~w_cpu_smem && w_cpu_rwen; // 0 - 7fffff SDRAM

    wire w_acia_a_cs = w_cpu_addr[23:8] == 16'hff11 ? w_cpu_bena[1] : 1'b0; // ACIA0    FF11xx No.Use
    wire w_acia_b_cs = w_cpu_addr[23:8] == 16'hff10 ? w_cpu_bena[1] : 1'b0; // ACIA1    FF10xx
	wire w_scram_cs  = w_cpu_addr[23:9] == {12'hff0,3'b001} && w_cpu_rwen;	// SDCD.BUF FF0200 - 3FF(512)
	wire w_scctl_cs  = w_cpu_addr[23:8] == 16'hff01 && w_cpu_rwen;			// SDCD.CTL FF01xx
	wire w_sysmd_cs  = w_cpu_addr[23:8] == 16'hff0f && w_cpu_rwen;			// SYS.CTL  FF0Fxx
	wire w_ddmy_cs   = w_cpu_addr[23:8] == 16'hff00 && w_cpu_rwen;			// Disk.Dmy FF00xx
	wire w_timer_cs  = w_cpu_addr[23:2] == {20'hff7ff,2'b10} && w_cpu_rwen;	// Timer    FF7FF8 - 7FFB 
	wire w_exit_cs   = w_cpu_addr[23:2] == {20'hff7ff,2'b11} && w_cpu_rwen;	// SYS.CTL  FF7FFC - 7FFF
   
     // ========================================================================
    // Clock
    // ========================================================================
	reg [7:0] rescnt;
	reg       resflg;
	always@(posedge clk27M) begin
		if(BTN[1]!=1) begin resflg <= 1; rescnt <= 0; end
		else if(rescnt!=8'hff) rescnt <= rescnt + 8'd1;
		     else              resflg <= 0;
	end

	wire clksdr,locked;
    Gowin_rPLL clkgen( // in:27M clkout:100M(100.286) clkoutd:50M(50.143)
        .clkin(clk27M), .clkout(clksdr), .clkoutd(), .reset(resflg), .lock(locked) );
	reg  clkspi;
	reg [7:0] divspi;
	always@(posedge clksdr) begin	// 162MHz
		divspi <= divspi + 8'd1;
		clk = divspi[1];			// 40.5MHz
		clkspi = divspi[2];			// 20.25MHz
	end

	reg [31:0] timercnt;
	always@(posedge clk) timercnt <= timercnt + 1;
	
    // ========================================================================
    // E clock (CPU clock divided by 10)
    // ========================================================================
    always@(posedge rst or posedge clk) begin : E_CLOCK
        if (rst) begin
            r_eclk <= 10'b0000000001;
        end
        else if (clk_ena) begin
            r_eclk <= { r_eclk[8:0], r_eclk[9] };
        end
    end
    
    // ========================================================================
    // Interrupts levels with priority encoding
    // ========================================================================
    always@(posedge rst or posedge clk) begin : IRQ_LEVEL
        reg [3:1] v_irq;
        if (rst) begin
            r_cpu_ipl_n <= 3'b111;
        end
        else if (clk_ena) begin
            v_irq[3] = ~w_irq_3_n;
            v_irq[2] = ~w_irq_2_n;
            v_irq[1] = ~w_irq_1_n;
            casez (v_irq)
                3'b??1 : r_cpu_ipl_n <= 3'b110; // Level #1 from ACIA-A
                3'b?10 : r_cpu_ipl_n <= 3'b101; // Level #2 from ACIA-B
                3'b100 : r_cpu_ipl_n <= 3'b100; // Level #3 (not used)
                3'b000 : r_cpu_ipl_n <= 3'b111; // No interrupts
            endcase
        end
    end
    assign w_irq_3_n = 1'b1;
    
    // ========================================================================
    // Data acknowledge
    // ========================================================================
	always@(posedge rst or posedge clk) begin : DTACK_GEN
        if (rst) begin
            r_rden_dly <= 1'b0;
            r_q_acia   <= 8'h00;
        end
        else begin
            // Read latencies
            r_rden_dly <= w_cpu_rden & ~w_cpu_vpa              // ROM/RAM read
                        | w_cpu_rden &  w_cpu_vpa & r_eclk[3]; // ACIAs read
            // Peripheral data bus
            if (r_eclk[3]) begin
                // MSB (even addresses)
                r_q_acia <= w_aciaa_data_out & {8{w_acia_a_cs}}  // ACIA-A
                          | w_aciab_data_out & {8{w_acia_b_cs}}; // ACIA-B
                //r_q_sdcd <= w_sdcd_data_out  & {8{w_scram_cs  }}; // SD-CARD
            end
        end
    end
    assign w_cpu_dtack = w_dram_cs ? sddtac :
	                      w_cpu_wren & ~w_cpu_vpa             // RAM write
                       | w_cpu_wren &  w_cpu_vpa & r_eclk[3] // ACIAs write
                       | r_rden_dly;                         // ROM/RAM, ACIAs read
    
    // ========================================================================
    // Read data multiplexing
    // ========================================================================
	 assign w_cpu_rdata = w_rom_cs    ? w_q_rom :
	                      w_ram_cs    ? w_q_ram :
	                      w_bram_cs   ? w_q_bram :
	                      w_dram_cs   ? w_q_dram :
	                      w_scram_cs  ? w_q_scram:
	                      w_acia_a_cs ? { r_q_acia, 8'h00 } :
	                      w_acia_b_cs ? { r_q_acia, 8'h00 } :
						  w_scctl_cs  ? {8'h00,7'b1000000, sdacc}: //sdcbusy} :
						  w_sysmd_cs  ? w_q_sysmd :
						  w_ddmy_cs   ? 16'h0000 : // Disk Dumy.Read(All.0)
						  w_timer_cs  ? w_cpu_addr[1]==0 ? timercnt[31:16] : timercnt[15:0] :
						  16'hffff;

    // ========================================================================
    // Monitor Regs
    // ========================================================================
	reg  [15:0] w_sysmd;	// b7=move_rom_ff8 000xxx --> ff8xxxx(32KB)
    reg  [15:0] w_scctl[0:3]; // 4word(8byte) RAM
	reg  [31:0] brk_adr0, brk_adr1, brk_adr2;
	reg  [15:0] trc_len;
	reg  [15:0] scctl_cmd,scctl_sts;
	reg  [1:0]  s_scctl; // Select scctl.addr
	wire [1:0]  scctl_adr = w_cpu_addr[2:1];
	reg         sdcd_req;
    always@(posedge rst or posedge clk) begin
        if (rst) begin
            w_sysmd <= 0; trc_len <= 0;
			scctl_cmd <= 0; sdcd_req <= 0;
			brk_adr0[31] <= 1; brk_adr1[1] <= 1; brk_adr2[31] <= 1; 
		end else begin
			if(w_sysmd_cs && ~w_cpu_rw_n) begin 
				case(w_cpu_addr[4:1])
					4'h0: w_sysmd[15:0]   <= w_cpu_wdata[15:0];
					4'h1: trc_len[15:0]   <= w_cpu_wdata[15:0];
					4'h2: brk_adr0[31:16] <= w_cpu_wdata[15:0];
					4'h3: brk_adr0[15:0]  <= w_cpu_wdata[15:0]; 
					4'h4: brk_adr1[31:16] <= w_cpu_wdata[15:0];
					4'h5: brk_adr1[15:0]  <= w_cpu_wdata[15:0];
					4'h6: brk_adr2[31:16] <= w_cpu_wdata[15:0];
					4'h7: brk_adr2[15:0]  <= w_cpu_wdata[15:0];
				endcase;
			end
			if(w_scctl_cs && ~w_cpu_rw_n) begin 
				w_scctl[scctl_adr] <= w_cpu_wdata; // Cmd
				case(w_cpu_addr[2:1])
					2'h0: begin scctl_cmd <= w_cpu_wdata; sdcd_req <= 1; end
					2'h1: sdadr[23:16] <= w_cpu_wdata[7:0];
					2'h2: sdadr[15:0]  <= w_cpu_wdata[15:0];
					default: ;
				endcase;
			end
			if(sdcd_req && sdcbusy) sdcd_req <= 0;
		end
    end

	wire [15:0] w_q_sysmd = w_cpu_addr[3:1]== 3'h0 ? {kbd_brk,w_sysmd[14:0]} : 
                            w_cpu_addr[3:1]== 3'h1 ? 16'h00                  :
                            w_cpu_addr[3:1]== 3'h2 ? { 8'h00, brk_pc[23:16]} :
                            w_cpu_addr[3:1]== 3'h3 ? brk_pc[15:0]            :
	                        16'h00;
    // ========================================================================
    // Address.Trace/Break
    // ========================================================================
	reg  [1:0] kbd_csadr;
	reg  [2:0] trctct;
	reg [23:0] brk_pc, brk_fpc;
	reg        req_brk, cpu_wrend, kbd_brk, kbd_brkd, ifetchd, ifetchdd;
    always@(posedge rst or posedge clk) begin
		if (rst) begin  
			req_brk <= 0; trctct <= 0;
		end else begin
			ifetchd <= w_dbg_ifetch; ifetchdd <= ifetchd;
			if(~ifetchd && ifetchdd) brk_fpc = w_cpu_addr;
			if(req_brk) brk_pc = brk_fpc;
			if(w_sysmd[13:12]==2'b01) begin
				if(w_sysmd[11] && w_dbg_ifetch && ~trctct[2]) begin
					if(trctct==2'd1) req_brk <= 1;
					trctct <= trctct + 1;
				end
				if(w_cpu_rwen) begin
					if(~brk_adr0[31] && (w_cpu_addr[23:0]==brk_adr0[23:0])) req_brk <= 1;
					if(~brk_adr1[31] && (w_cpu_addr[23:0]==brk_adr1[23:0])) req_brk <= 1;
					if(~brk_adr2[31] && (w_cpu_addr[23:0]==brk_adr2[23:0])) req_brk <= 1;
				end
				if(r_q_acia==8'h11) kbd_brk <= 1;
				if(~w_sysmd[11]) begin
					if(kbd_brk && w_dbg_ifetch && w_cpu_addr[23:12]<12'hff4) begin req_brk <= 1; kbd_brk <= 0; end
				end
			end else trctct <= 0;
			if(req_brk && (w_dbg_irq_lvl==7)) req_brk <= 0;
		end
	end
    // ========================================================================
    // 16 KB ROM(mon68K) at $FF4000-$FF7FFF($0000 - $1FFF)
    // ========================================================================
    Gowin_pROM mon68k(
        .clk(clk), .oce(1'b1), .ce(1'b1), .reset(1'b0),
        .ad(w_cpu_addr[13:1]), .dout(w_q_rom) );
    // ========================================================================
    // 8 KB RAM (No.Use)
    // ======================================================================/*==
/*	Gowin_SP_8X4K workramL(
        .reset(1'b0), .clk(clk), .oce(1'b1), .ce(w_cpu_bena[0]), .wre(w_cpu_wren && w_bram_cs),
        .ad(w_cpu_addr[12:1]), .din(w_cpu_wdata[ 7:0]), .dout(w_q_bram[ 7:0]) );
    Gowin_SP_8X4K workramH(
        .reset(1'b0), .clk(clk), .oce(1'b1), .ce(w_cpu_bena[1]), .wre(w_cpu_wren && w_bram_cs),
        .ad(w_cpu_addr[12:1]), .din(w_cpu_wdata[15:8]), .dout(w_q_bram[15:8]) 
*/	// ========================================================================
    // 8 KB RAM at $FF2000-FF3FFF
	// ========================================================================
	//assign w_q_ram = w_scctl[scctl_adr];
    Gowin_SP_8X4K monramL(
        .reset(1'b0), .clk(clk), .oce(1'b1), .ce(w_cpu_bena[0]), .wre(w_cpu_wren && w_ram_cs),
        .ad(w_cpu_addr[12:1]), .din(w_cpu_wdata[ 7:0]), .dout(w_q_ram[ 7:0]) );
    Gowin_SP_8X4K monramH(
        .reset(1'b0), .clk(clk), .oce(1'b1), .ce(w_cpu_bena[1]), .wre(w_cpu_wren && w_ram_cs),
        .ad(w_cpu_addr[12:1]), .din(w_cpu_wdata[15:8]), .dout(w_q_ram[15:8]) );
    // ========================================================================
    // 16 MB DRAM at $0000 - $ffff
    // ========================================================================
	// CPU Dtack CTRL
	wire waitsig = w_cpu_rwen && w_dram_csc;
	wire waittup = waitsig && ~waitsigd;
	reg  w_dram_csc,waitsigd,waitsigdd,sddtac;
	reg [5:0] waitcount;
	// PSRAM Word Access
	reg	 [15:0]	psramin, psramout;
	reg  [63:0] mlb[0:3];	// psram Buf
	reg  [24:0] rcadr;
	reg  [2:0]  psbp;
	wire [4:1]  mbp = psaddr[4:1];
	reg  psmd, pswr, psone, rd_validd, dcsdlyf;
	reg  [3:0] dcsdlyc;
	wire [23:0] psaddr = w_cpu_addr[23:0];
	wire rcmatch = rcadr[23:5]=={1'b1, psaddr[23:5]} ? 1'b1 : 1'b0;
	//wire clkddrt = clksdr & (w_dram_cs || dcsdlyf);	// debug.clk

	always @(posedge clk_out) begin
		if(rst) begin
			cmd_en <= 0; psmd <= 0; rcadr[24] <= 0; waitcount <= 0; 
		end else begin
			w_dram_csc <= w_dram_cs; waitsigd <= waitsig; waitsigdd <= waitsigd;
			if(waitcount!=0) waitcount <= waitcount - 6'd1;
			if(waitcount==1) sddtac <= 1;
			else if(~w_dram_csc) sddtac <= 0;
			// -- For debug.clk --
			//if(sddtac) begin dcsdlyc <= 4'h7; dcsdlyf <= 1; end
			//else if(dcsdlyc==0) dcsdlyf <= 0;
			//	   else dcsdlyc <= dcsdlyc - 1; 
			//
			cmd <= w_cpu_wren;
			if(w_dram_csc) begin
				if(waittup)begin
					if((w_cpu_rden && ~rcmatch) || w_cpu_wren ) begin
						cmd_en <= 1; psmd <= 1;   psbp <= 0;
						if(w_cpu_rden) waitcount <= 22;	// Read.Delay
						else           waitcount <= 10;	// Write.Delay
					end else begin
						psmd <= 0; waitcount <= 6;		// Cache.Hit
					end
				end
				
				if(cmd_en) cmd_en <= 0;
				//
				if(waitcount[2])
					if(w_cpu_rden) rcadr[24:5] = {1'b1, psaddr[23:5]};	// Cache.Addr set
					else if(rcmatch) rcadr[24] <= 0;					// Cache.Addr discard 
				//
				ps_wrdt <= {psbd,psbd,psbd,psbd};						// Write.DataSet(64bit)
				if(rd_valid) mlb[psbp] <= ps_rddt;
				if((w_cpu_wren && psbp<4) || rd_valid) psbp <= psbp + 3'd1;
				if(waitcount==2) psmd <= 0;
			end
		end
	end

	wire [15:0] psramdo =   mbp[2:1]==2'h0 ? mlb[mbp[4:3]][15: 0] :
							mbp[2:1]==2'h1 ? mlb[mbp[4:3]][31:16] :
							mbp[2:1]==2'h2 ? mlb[mbp[4:3]][47:32] :
							                 mlb[mbp[4:3]][63:48];
	//assign w_q_dram[15:0] = psramdo[15:0];
	assign w_q_dram[15:8] = w_cpu_bena[1] ? psramdo[15:8] : 8'h00;
	assign w_q_dram[ 7:0] = w_cpu_bena[0] ? psramdo[ 7:0] : 8'h00;

	wire [23:0] ps_addr = {psaddr[23:5], 4'h0};
	wire [7:0]  ps_mask = psaddr[4:3]==psbp ? ps_mptn : 8'hff;
	wire [7:0]  ps_mptn = ~({3'b000,w_cpu_bena[1],3'b000,w_cpu_bena[0]} << psaddr[2:1]);
	wire [15:0]  psbd    = w_cpu_wdata; 

	wire        rd_valid, clk_out, error;
	reg         cmd, cmd_en;
	reg  [63:0] ps_wrdt; 
	wire [63:0] ps_rddt;
	PSRAM_Memory_Interface_HS_Top u_psram_top(
		.rst_n(~rst), .clk(clk27M), .memory_clk (clksdr), .pll_lock(locked),
		.O_psram_ck(O_psram_ck), .O_psram_ck_n(O_psram_ck_n),
		.IO_psram_rwds(IO_psram_rwds), .IO_psram_dq(IO_psram_dq),
		.O_psram_reset_n(O_psram_reset_n), .O_psram_cs_n(O_psram_cs_n),
		.addr(ps_addr[21:1]), .wr_data(ps_wrdt), .rd_data(ps_rddt),
		.cmd(cmd), .cmd_en(cmd_en), .data_mask(ps_mask),
		.rd_data_valid(rd_valid), .clk_out(clk_out), .init_calib(init_calib)
		);
    // ========================================================================
    // 256W(16bit) SD_card R/W RAM
    // ========================================================================
	wire        srwen;
    Gowin_SP_8x256B sdcramL(
        .reset(1'b0), .clk(clk), .oce(1'b1), .ce(srben[0]), .wre(srwen),
        .ad(srmad[7:0]), .din(srwpt[ 7:0]), .dout(w_q_scram[ 7:0]) );
    Gowin_SP_8x256B sdcramH(
        .reset(1'b0), .clk(clk), .oce(1'b1), .ce(srben[1]), .wre(srwen),
        .ad(srmad[7:0]), .din(srwpt[15:8]), .dout(w_q_scram[15:8]) );
    // ========================================================================
    // SD Controller
    // ========================================================================
	wire [7:0]   stout;
	reg  sdrd,sdwr,sdcbusy,mrwe;
	reg  [23:0] sdadr;
	reg  [2:0]  sdra;
	reg  [7:0]  sdin,mrdi;
	wire [7:0]  mrdo;
	reg  [13:0] mradr;      // Buffer.Point 
	wire [7:0]  sdrdt,sdout,sdled;
	reg [9:0] sdbbcnt;

	reg         rdd,wrd;
	reg  [2:0]  rseq,wseq,aseq,aseqc,rmseq,wmseq,sdmode;
	reg  [23:0] secct;

	 reg         sdwen;
	 wire [1:0]  srben,sdben;
	 wire [12:0] srmad,sdmad;
	 wire [15:0] srwpt,sdwpt;
	 wire sdacc = aseq!=0 || rseq!=0 || wseq!=0; // SD.Access = 1
	 assign srwen = sdacc ? sdwen : w_cpu_wren && w_scram_cs;
	 assign srben = sdacc ? sdben : w_cpu_bena;
	 assign srmad = sdacc ? sdmad : w_cpu_addr[13:1];
	 assign srwpt = sdacc ? sdwpt : w_cpu_wdata;
	 
	 assign sdben = 2'b11;
	 assign sdmad = mradr[13:1];
	 assign sdwpt = {whdat,sdout};
	 
	reg  [7:0]  whdat;
	reg         mrwed;

	always @(posedge rst or posedge clkspi) begin
		if(rst) begin
			rseq <= 3'h0; wseq <= 3'h0; aseq <= 3'h0;
			rmseq <= 3'h0; wmseq <= 3'h0; sdcbusy <= 0;
			sdra <= 3'b000; mrwe <= 1'b0; 
			sdrd <= 0; sdwr <= 0; sdwen <= 0;
		end else begin
			if(sdcd_req && ~sdacc && scctl_cmd[1:0]!=2'b11) begin 
				if(scctl_cmd[0]) begin sdmode <= 0; end
				if(scctl_cmd[1]) begin sdmode <= 1; end
				aseq <= 1;
			end
			//
			case(rseq)
				3'h1: begin sdbbcnt <= 0; rseq <= 3'h2; end
				3'h2: if(stout[5] && !stout[4]) rseq <= 3'h3; // INIT & BLOCK Not.Busy 
				3'h3: begin sdra <= 3'b000; rseq <= 3'h4; end
				3'h4: if(!stout[5]) begin sdcbusy <= 0; rseq <= 0; end // Read(512B).End
						else
						if(stout[6]) begin rseq <= 3'h5; end 
				3'h5: begin sdrd <= 1'b1; rseq <= 3'h6; end
				3'h6: begin
					  sdrd <= 1'b0; mrdi <= sdout; 
					  if(sdbbcnt<512)
						if(mradr[0]==0) whdat <= sdout;
						else            sdwen <= 1'b1; 
					  rseq <= 3'h7;
					end
				3'h7: begin 
					  sdwen <= 1'b0; sdbbcnt <= sdbbcnt + 10'd1;  
					  if(sdbbcnt<512) mradr <= mradr + 14'h1; 
					  rseq <= 3'h3;  
					end
			endcase;
			//
			case(wseq)
				3'h1: begin sdwen <= 0; wseq <= 3'h2; end
				3'h2: if(stout[5] && !stout[4]) wseq <= 3'h3; 
				3'h3: begin sdra <= 3'b000; wseq <= 3'h4; end
				3'h4: if(!stout[5]) begin sdcbusy <= 0; wseq <= 0; end // Write(512B).End
					  else
						if(stout[7] && !stout[6]) begin 
							if(mradr[0]==0) sdin <= w_q_scram[15:8];
							else            sdin <= w_q_scram[7:0];
							wseq <= 3'h5;
						end 
				3'h5: begin sdwr <= 1'b1; wseq <= 3'h6; end
				3'h6: begin sdwr <= 1'b0; mradr <= mradr + 14'h1; wseq <= 3'h3; end
			endcase;
			//
			case(aseq)
				3'h1: begin sdra <= 3'b010; aseqc <= 3'h0; aseq <= 3'h2; end
				3'h2: begin  aseq <= 3'h3; end
				3'h3: begin  
						case(aseqc)
							3'h0: begin sdcbusy <= 1; sdra <= 3'b010; sdin <= sdadr[ 7: 0]; end
							3'h1: begin sdra <= 3'b011; sdin <= sdadr[15: 8]; end
							3'h2: begin sdra <= 3'b100; sdin <= sdadr[23:16]; end
							3'h3: begin if(sdmode) sdin <= 8'h01;
										else       sdin <= 8'h00;
										sdra <= 3'b001; 
									end
							default: ;
						endcase
						aseq <= 3'h4;
					end
				3'h4: begin sdwr <= 1'b1; aseq <= 3'h5; end 
				3'h5: begin 
						sdwr <= 1'b0;
						aseqc <= aseqc + 3'h1;
						if(aseqc<3'h3) aseq <= 3'h2;
						else           aseq <= 3'h7; // Address Set.End
					end
				3'h7: begin
						if(sdmode) wseq <= 1;
						else       rseq <= 1; 
						mradr <= 14'h0; aseq <= 3'h0; 
					end
				default: ;
			endcase

		end
    end

// regAddr dataOut   n_rd(Rise)   n_wr(Rise)
//  000    <= sdout  Data.Read    Data.Write              
//  001    <= status              Start.Read(0)/Write(1)  0/1=DataIn/Out
//  010 - 100 Block.Adr SDHC(7:0-15:8-23:16) SDSC(16:9-24:17-31:25)  
//	status(7) <= '1' tx empty  status(6) <= '0' rx ready
//	status(5) <= block_busy;   status(4) <= init_busy;
	sd_controller	sd1 (
		.clk(clkspi), .n_reset(!rst), .regAddr(sdra),
		.n_wr(!sdwr), .n_rd(!sdrd),
		.dataIn(sdin), .dataOut(sdout), .status(stout),
		.sdCS(SD_CS), .sdMOSI(SD_CMD), .sdMISO(SD_DAT0), .sdSCLK(SD_SCK),
		.driveLED()
	);
   // ========================================================================
    // Serial clock
    // ========================================================================
    reg [15:0]	serialClkCount;
	wire [15:0] serialClkSet = 2416*500/405; // 405(40,5)=cpu.clock(MHz)
    always@(posedge clk) begin : SERIAL_CLOCK
		if (rst) begin serialClkCount <= 0; r_ser_clk <= 0; end
			else       serialClkCount	<= serialClkCount + serialClkSet;

			r_ser_clk	<= serialClkCount[15]; 
	 end
    // ========================================================================
    // ACIA-A at $A000 / $A002 (Load port)
    // ========================================================================
    acia_6850 U_acia_6850_a (
        .reset(rst), .clk(clk), .e_clk(r_eclk[3]),
        .cs(w_acia_a_cs), .rw_n(w_cpu_rw_n), .rs(w_cpu_addr[1]),
        .data_in(w_cpu_wdata[15:8]), .data_out(w_aciaa_data_out),
        .data_en(w_aciaa_data_en), .irq_n(w_irq_1_n),
        .txclk(r_ser_clk), .rxclk(r_ser_clk),
        .rxdata(r_uart0_rxd[2]), .txdata(w_uart0_txd),
        .cts_n(uart0_cts_n), .dcd_n(uart0_dcd_n), .rts_n(uart0_rts_n)
    );
    always@(posedge clk) r_uart0_rxd <= { r_uart0_rxd[1:0], uart0_rxd };
    always@(posedge clk) r_uart0_txd <= { r_uart0_txd[1:0], w_uart0_txd };
    assign uart0_txd = r_uart0_txd[2];
    // ========================================================================
    // ACIA-B at $C000 / $C002 (Terminal)
    // ========================================================================
    acia_6850 U_acia_6850_b(
        .reset(rst), .clk(clk), .e_clk(r_eclk[3]),
        .cs(w_acia_b_cs), .rw_n(w_cpu_rw_n), .rs(w_cpu_addr[1]),
        .data_in(w_cpu_wdata[15:8]), .data_out(w_aciab_data_out),
        .data_en(w_aciab_data_en), .irq_n(w_irq_2_n),
        .txclk(r_ser_clk), .rxclk(r_ser_clk),
        .rxdata(r_uart1_rxd[2]), .txdata(w_uart1_txd),
        .cts_n(uart1_cts_n), .dcd_n(uart1_dcd_n), .rts_n(uart1_rts_n)
    );
    always@(posedge clk) r_uart1_rxd <= { r_uart1_rxd[1:0], uart1_rxd };
    always@(posedge clk) r_uart1_txd <= { r_uart1_txd[1:0], w_uart1_txd };
    assign uart1_txd = r_uart1_txd[2];
  
endmodule
//`default_nettype wire

