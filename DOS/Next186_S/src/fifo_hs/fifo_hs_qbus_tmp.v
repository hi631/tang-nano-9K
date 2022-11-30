//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.03
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Thu Oct 13 12:44:51 2022

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	FIFO_HS_qbus your_instance_name(
		.Data(Data_i), //input [16:0] Data
		.WrClk(WrClk_i), //input WrClk
		.RdClk(RdClk_i), //input RdClk
		.WrEn(WrEn_i), //input WrEn
		.RdEn(RdEn_i), //input RdEn
		.Almost_Empty(Almost_Empty_o), //output Almost_Empty
		.Almost_Full(Almost_Full_o), //output Almost_Full
		.Q(Q_o), //output [16:0] Q
		.Empty(Empty_o), //output Empty
		.Full(Full_o) //output Full
	);

//--------Copy end-------------------
