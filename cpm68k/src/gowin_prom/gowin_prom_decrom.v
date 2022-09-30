//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.03
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Sun Aug 21 16:11:43 2022

module Gowin_pROM_decrom (dout, clk, oce, ce, reset, ad);

output [35:0] dout;
input clk;
input oce;
input ce;
input reset;
input [7:0] ad;

wire gw_gnd;

assign gw_gnd = 1'b0;

pROMX9 promx9_inst_0 (
    .DO(dout[35:0]),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,ad[7:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd})
);

defparam promx9_inst_0.READ_MODE = 1'b0;
defparam promx9_inst_0.BIT_WIDTH = 36;
defparam promx9_inst_0.RESET_MODE = "SYNC";
defparam promx9_inst_0.INIT_RAM_00 = 288'h203000E00203000E00203000E00203000E00203000E00203000E00203000E00203000E00;
defparam promx9_inst_0.INIT_RAM_01 = 288'h203000E00203000E00203000E00203000E00203000E00203000E00203000E00203000E00;
defparam promx9_inst_0.INIT_RAM_02 = 288'h205000E00205000E00205000E00205000E00205000E00205000E00205000E00205000E00;
defparam promx9_inst_0.INIT_RAM_03 = 288'h212000E00212000E00212000E00212000E00212000E00212000E00212000E00212000E00;
defparam promx9_inst_0.INIT_RAM_04 = 288'h21E000E0021E000E0021E000E0021E000E0021E000E0021E000E0021E000E0021E000E00;
defparam promx9_inst_0.INIT_RAM_05 = 288'h222000E00222000E00222000E00222000E00222000E00222000E00222000E00222000E00;
defparam promx9_inst_0.INIT_RAM_06 = 288'h238000E00235000E0022F000E0003B00000022A000E00226000E00202000E00000000E00;
defparam promx9_inst_0.INIT_RAM_07 = 288'h03B00000003B00000003B00000003B00000003B00000003B00000003B00000003B000000;
defparam promx9_inst_0.INIT_RAM_08 = 288'h03B00000007400030006A005B00061005B0003B00000005A000300050005B00047005B00;
defparam promx9_inst_0.INIT_RAM_09 = 288'h03B00000009700030009200030008D00030003B00000008500030008000030007B000300;
defparam promx9_inst_0.INIT_RAM_0A = 288'h03B0000000ED0003000E3005B000DA005B000CD1043000C01043000B310430009F2CBA00;
defparam promx9_inst_0.INIT_RAM_0B = 288'h03B00000003B00000003B00000003B00000003B0000000FE0003000F90003000F4000300;
defparam promx9_inst_0.INIT_RAM_0C = 288'h03B00000015F00030015C00030015900030015700030014F00030014A000300145000300;
defparam promx9_inst_0.INIT_RAM_0D = 288'h182000C0017C000300178000300174000300172000C0016B000300167000300163000300;
defparam promx9_inst_0.INIT_RAM_0E = 288'h1E20003001DC0003001D80003001D40003001B954A10019F44810018A1C0800185000300;
defparam promx9_inst_0.INIT_RAM_0F = 288'h24200070023C00070003B00000003B0000001F600A9001E800C90003B00000003B000000;
defparam promx9_inst_0.INIT_RAM_10 = 288'h4E4000E004DA000E004D0000E004C6000E004E7000E004DD000E004D3000E004C9000E00;
defparam promx9_inst_0.INIT_RAM_11 = 288'h50C000E00502000E004F8000E004EE000E0050F000E00505000E004FB000E004F1000E00;
defparam promx9_inst_0.INIT_RAM_12 = 288'h534000E0052A000E00520000E00516000E00537000E0052D000E00523000E00519000E00;
defparam promx9_inst_0.INIT_RAM_13 = 288'h55C000E00552000E00548000E0053E000E0055F000E00555000E0054B000E00541000E00;
defparam promx9_inst_0.INIT_RAM_14 = 288'h58B000E0057F000E00573000E00566000E0058F000E00583000E00577000E0056B000E00;
defparam promx9_inst_0.INIT_RAM_15 = 288'h5BB000E005AF000E005A3000E00597000E005C0000E005B3000E005A7000E0059B000E00;
defparam promx9_inst_0.INIT_RAM_16 = 288'h2B6000E002A51C0E0003B00000003B00000013F100D00136180D00132000C0003B000000;
defparam promx9_inst_0.INIT_RAM_17 = 288'h033000E0003B00000003B00000003B00000003B000000035000E0003B00000003B000000;
defparam promx9_inst_0.INIT_RAM_18 = 288'h315000C002F00002002E80002002BE18B5002F9000C002EE000C002E6000C002BC000C00;
defparam promx9_inst_0.INIT_RAM_19 = 288'h39B000D0036D25450035314B50033D14B500390000D00364000D0034E000D00338000C00;
defparam promx9_inst_0.INIT_RAM_1A = 288'h29400550028000B50027B01050027600030029400550026200B50025D010500258000300;
defparam promx9_inst_0.INIT_RAM_1B = 288'h3E6000D003D00085003C60055003BC0055003B0000D003A7000D003A2000D0039D000C00;
defparam promx9_inst_0.INIT_RAM_1C = 288'h458000C0043300940041B18E5003EA18B500444000C00431000C00419000C003E8000C00;
defparam promx9_inst_0.INIT_RAM_1D = 288'h4C4000D0049529550048118C50046D18C5004B9000D00493000D0047F000D0046B000C00;
defparam promx9_inst_0.INIT_RAM_1E = 288'h5EB0002005D70002005E60002005D20002005E10002005CD0002005DC0002005C8000200;
defparam promx9_inst_0.INIT_RAM_1F = 288'h253000700244000C0003B00000003B00000012308650011B08650010C086500106084D00;

endmodule //Gowin_pROM_decrom
