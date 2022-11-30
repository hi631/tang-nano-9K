//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.03
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Wed Nov 30 22:31:45 2022

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_pROM_bios your_instance_name(
        .dout(dout_o), //output [31:0] dout
        .clk(clk_i), //input clk
        .oce(oce_i), //input oce
        .ce(ce_i), //input ce
        .reset(reset_i), //input reset
        .ad(ad_i) //input [10:0] ad
    );

//--------Copy end-------------------
