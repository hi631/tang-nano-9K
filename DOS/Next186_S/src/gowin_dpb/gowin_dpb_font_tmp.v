//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.03
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Thu Oct 13 13:33:28 2022

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_DPB_font your_instance_name(
        .douta(douta_o), //output [7:0] douta
        .doutb(doutb_o), //output [7:0] doutb
        .clka(clka_i), //input clka
        .ocea(ocea_i), //input ocea
        .cea(cea_i), //input cea
        .reseta(reseta_i), //input reseta
        .wrea(wrea_i), //input wrea
        .clkb(clkb_i), //input clkb
        .oceb(oceb_i), //input oceb
        .ceb(ceb_i), //input ceb
        .resetb(resetb_i), //input resetb
        .wreb(wreb_i), //input wreb
        .ada(ada_i), //input [11:0] ada
        .dina(dina_i), //input [7:0] dina
        .adb(adb_i), //input [11:0] adb
        .dinb(dinb_i) //input [7:0] dinb
    );

//--------Copy end-------------------
