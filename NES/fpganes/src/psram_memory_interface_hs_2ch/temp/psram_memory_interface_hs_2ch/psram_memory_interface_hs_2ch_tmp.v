//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.09 Education
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Sat Feb 04 09:39:07 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	PSRAM_Memory_Interface_HS_2CH_Top your_instance_name(
		.clk(clk_i), //input clk
		.rst_n(rst_n_i), //input rst_n
		.memory_clk(memory_clk_i), //input memory_clk
		.pll_lock(pll_lock_i), //input pll_lock
		.O_psram_ck(O_psram_ck_o), //output [1:0] O_psram_ck
		.O_psram_ck_n(O_psram_ck_n_o), //output [1:0] O_psram_ck_n
		.IO_psram_rwds(IO_psram_rwds_io), //inout [1:0] IO_psram_rwds
		.O_psram_reset_n(O_psram_reset_n_o), //output [1:0] O_psram_reset_n
		.IO_psram_dq(IO_psram_dq_io), //inout [15:0] IO_psram_dq
		.O_psram_cs_n(O_psram_cs_n_o), //output [1:0] O_psram_cs_n
		.init_calib0(init_calib0_o), //output init_calib0
		.init_calib1(init_calib1_o), //output init_calib1
		.clk_out(clk_out_o), //output clk_out
		.cmd0(cmd0_i), //input cmd0
		.cmd1(cmd1_i), //input cmd1
		.cmd_en0(cmd_en0_i), //input cmd_en0
		.cmd_en1(cmd_en1_i), //input cmd_en1
		.addr0(addr0_i), //input [20:0] addr0
		.addr1(addr1_i), //input [20:0] addr1
		.wr_data0(wr_data0_i), //input [31:0] wr_data0
		.wr_data1(wr_data1_i), //input [31:0] wr_data1
		.rd_data0(rd_data0_o), //output [31:0] rd_data0
		.rd_data1(rd_data1_o), //output [31:0] rd_data1
		.rd_data_valid0(rd_data_valid0_o), //output rd_data_valid0
		.rd_data_valid1(rd_data_valid1_o), //output rd_data_valid1
		.data_mask0(data_mask0_i), //input [3:0] data_mask0
		.data_mask1(data_mask1_i) //input [3:0] data_mask1
	);

//--------Copy end-------------------
