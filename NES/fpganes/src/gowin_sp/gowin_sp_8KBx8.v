//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.03
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Mon Dec 05 23:17:24 2022

module Gowin_SP_8KBx8 (dout, clk, oce, ce, reset, wre, ad, din);

output [7:0] dout;
input clk;
input oce;
input ce;
input reset;
input wre;
input [12:0] ad;
input [7:0] din;

wire [29:0] sp_inst_0_dout_w;
wire [29:0] sp_inst_1_dout_w;
wire [29:0] sp_inst_2_dout_w;
wire [29:0] sp_inst_3_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

SP sp_inst_0 (
    .DO({sp_inst_0_dout_w[29:0],dout[1:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[1:0]})
);

defparam sp_inst_0.READ_MODE = 1'b0;
defparam sp_inst_0.WRITE_MODE = 2'b00;
defparam sp_inst_0.BIT_WIDTH = 2;
defparam sp_inst_0.BLK_SEL = 3'b000;
defparam sp_inst_0.RESET_MODE = "SYNC";
defparam sp_inst_0.INIT_RAM_00 = 256'h00FF00FF003000FFF40BF409000BFFFFFE000000F8FFFFC0A0000000FF00A0FF;
defparam sp_inst_0.INIT_RAM_01 = 256'hA000A000000000BF03FC000001FFFFFF00AF00A0F3FFFC0F80000800F000AFD0;
defparam sp_inst_0.INIT_RAM_02 = 256'h00000000FF1DFFFF000000000FFFFFFF00020000F8FFFF0280000000FC0083FC;
defparam sp_inst_0.INIT_RAM_03 = 256'h00000000AF80AFFF00BF0ABFFF831FFCFA8BFA88FFFF803AE0000200FFC0057F;
defparam sp_inst_0.INIT_RAM_04 = 256'h00FF00FF00300BFFF400F400002FFFFF0AAF0AA5E3FFFC0AFFFEFF20F0000FF0;
defparam sp_inst_0.INIT_RAM_05 = 256'h0000000000BFFFFF000000000A400AFF00000000003FFFFF02EF0020F7FFFC0F;
defparam sp_inst_0.INIT_RAM_06 = 256'h000000003FF0C22F00000000503F5BFF08000000FFC00EFC020002FF3F800000;
defparam sp_inst_0.INIT_RAM_07 = 256'h0F8F2FF500000000FFF073BF00000000F3E2FC3F7FF0C22F000A0000000403FB;
defparam sp_inst_0.INIT_RAM_08 = 256'h00000000001D0FFF00020000201D2FFF0FD40FD400BEFFFF2FFF27C000000000;
defparam sp_inst_0.INIT_RAM_09 = 256'h00210BDF000000BF80008000FFFFFF000000000B000FFFFF00000000002F0FFF;
defparam sp_inst_0.INIT_RAM_0A = 256'h0000000000F4000B000000000AC0F500020009F003F0BFFF0000BFFCB5560000;
defparam sp_inst_0.INIT_RAM_0B = 256'h03FF03FF000003FF0AFC0AFC000001FF3D73FFFC000003FFFAABFA28FFFFFF01;
defparam sp_inst_0.INIT_RAM_0C = 256'hFD0007D0FF900BFF02802FF802802FF8000000000000000000000000FE80FE80;
defparam sp_inst_0.INIT_RAM_0D = 256'h3003FFFF00F0FF0000F0FF0018BFFF4AE00000001ABFFD6AE8000000D000FE00;
defparam sp_inst_0.INIT_RAM_0E = 256'hE800E8005FFFFFFF2FF82D5800000000002F282F3FFF800DE800E800CFFF7FFF;
defparam sp_inst_0.INIT_RAM_0F = 256'hD55F2AA07FFF00005000A540FC20FE9800000000F50EF5FE00B500BFFFFD003F;
defparam sp_inst_0.INIT_RAM_10 = 256'hFFFCFFFF3F2AFFFF3F2BFFFC09B80BF800800000000897FB000000002AE07FB4;
defparam sp_inst_0.INIT_RAM_11 = 256'h8000BFFF02C2FD3E5FF5FFF500020002002F0BD2000000007FFC87D300080008;
defparam sp_inst_0.INIT_RAM_12 = 256'h000000003FF5FFF050007FFF0205FDFD0BF80B000005FFFFFD3EFD000014FFFF;
defparam sp_inst_0.INIT_RAM_13 = 256'h009F0F7CFFF038AF02300D8833FC0FFB00000000FFD4FFC0008C03620CFF03FE;
defparam sp_inst_0.INIT_RAM_14 = 256'h2FF72FFF6240FFF0AA00AA00000000004D8943FF083F083F1890FFFC6A00EA00;
defparam sp_inst_0.INIT_RAM_15 = 256'hC000E8000A00FFFC000002FE38003FFF3000BA000280FFFF8000800036240FFF;
defparam sp_inst_0.INIT_RAM_16 = 256'h70030FFCE0241FF4080E082C70000FFFD7802800FEA4015480000BFAE000FFFF;
defparam sp_inst_0.INIT_RAM_17 = 256'hE000FFFCF600F6005FF8A02C2CFD93025FF8A02FA80056AAAB6FD4BF00000000;
defparam sp_inst_0.INIT_RAM_18 = 256'h0E00000B0BC0FC3F033FFD2F02F0FF00C0553FAA27F805F87FA17EDE002B0002;
defparam sp_inst_0.INIT_RAM_19 = 256'h3FFF000FCED7FED480BF7F40FFB0DF4FE000000B01F93FFE00AB0080FFB40F4B;
defparam sp_inst_0.INIT_RAM_1A = 256'h05FF7FE0FC3F0FF0FA10FFC4A800A800BC2FBFD2000000007FFCAFD3FFF002FF;
defparam sp_inst_0.INIT_RAM_1B = 256'hAAF80007AAAB0000F2830D7CFFFF000900000000FFFFF2FF0000F555F0FF0F00;
defparam sp_inst_0.INIT_RAM_1C = 256'h2000D8008828FA80200000000BFD0BFF5FFFA3FF000000000000FFFF0000FFA0;
defparam sp_inst_0.INIT_RAM_1D = 256'hFCFCFFC0FD55FD552020AAAA0208AAAAFD55FD55001F3FE00000002FA0307FCC;
defparam sp_inst_0.INIT_RAM_1E = 256'hB5560000B5560000000BFFFF01D03FBF0000000000A0000F00A0000F0AA0F00F;
defparam sp_inst_0.INIT_RAM_1F = 256'h0000000000A80B503C00C2A80000000000000000B5560000B5560000B5560000;
defparam sp_inst_0.INIT_RAM_20 = 256'h00B400BE2D082F882D082F882CA82EA82D0C2F8E30D038F8300038002D502FF8;
defparam sp_inst_0.INIT_RAM_21 = 256'h020C020EC20CE20E2D402FE0B030B838B4D0BEF8D540FFE02D502FF82D302FB8;
defparam sp_inst_0.INIT_RAM_22 = 256'hD554FFFED554FFFEC000E000C02CE02EB554BFFEC00CE00ED554FFFED50CFF8E;
defparam sp_inst_0.INIT_RAM_23 = 256'h0B540BFEB554BFFE000C000EB420BE20C350E3F84D506FF80B500BF8B550BFF8;
defparam sp_inst_0.INIT_RAM_24 = 256'hFFFFFFFFFFFF00000000FFFF00000000C0B4E0BE00D400FED0B4F8BED554FFFE;
defparam sp_inst_0.INIT_RAM_25 = 256'hFFF7C00B00000000C0BFFF4080037FFF02A802A8FFFFFFFF202020200D000F80;
defparam sp_inst_0.INIT_RAM_26 = 256'h5600FE002003DFFF0003FFFFFFFF02A8E0006000C000C000FC000C00FFFD0009;
defparam sp_inst_0.INIT_RAM_27 = 256'h00BF000080000F0000000000021802B830203FDF24F02F0F031803E79580BF80;
defparam sp_inst_0.INIT_RAM_28 = 256'hFFFFC0D5FFFF0000FFFCC0D7FFFC00035555FFFF5555FFFF6C009300FFFFAAAA;
defparam sp_inst_0.INIT_RAM_29 = 256'hF4002FFF24002FFF0003FFFF24002FFF0003FFFFFFFF5555FFFC5556FFFC0003;
defparam sp_inst_0.INIT_RAM_2A = 256'hFFFF0003D555FFFFC145FEBA5556FFFCABC3FF3CFFFF000025552FFF55A0FFA0;
defparam sp_inst_0.INIT_RAM_2B = 256'hFFFFC0002AAA2AAA3FFC3003002A55550000F800BFFF9555FFFFC000FFFE5556;
defparam sp_inst_0.INIT_RAM_2C = 256'h35553FFFFFFFF000F555FAAAF000FFFF5577FFDFFFF3000F5573AA8F0003FFFF;
defparam sp_inst_0.INIT_RAM_2D = 256'hFDA057A00BFFF4030003FFFF50FFAF03BFFF4003000000000000FFFFFFFF0000;
defparam sp_inst_0.INIT_RAM_2E = 256'hFF00FFFF7555DFFF60009FFFB55FBFF5C000FFFFC0AAFF55C5FFFA00C000FFFF;
defparam sp_inst_0.INIT_RAM_2F = 256'h002500020000000A55551112000055685554AAB0BFFF9555FFFF00FFFFFFC000;
defparam sp_inst_0.INIT_RAM_30 = 256'hFFFEFFFE3C03C3FFFFFDAF5FFF9F407EFFDFBD60FF0C00F303C003304000BFFF;
defparam sp_inst_0.INIT_RAM_31 = 256'hFFFFFFFFFFFC0003FFFFAAA00C00F3FFFFFFFFFF0300FCFFFFFF0000F00C0FFC;
defparam sp_inst_0.INIT_RAM_32 = 256'hFFFFC0FFFFFFC002FFFFC0FFFFFF0000309B3F64BFFFBFFFC19FFE60FFFF0AAA;
defparam sp_inst_0.INIT_RAM_33 = 256'h200002AAFFFCC0030000C000FFFFFAD5FFFFFFFF0000000000000F00FFFFC002;
defparam sp_inst_0.INIT_RAM_34 = 256'h0C00FFFF000000000300FCF0ABFFFF50000000000000555503C003300055FFAA;
defparam sp_inst_0.INIT_RAM_35 = 256'h00000000FFFF9FFFFFFDFFFFFFFFFF00FF0000FFFFFCC0033FFFC0D500000000;
defparam sp_inst_0.INIT_RAM_36 = 256'hFFFFB555F7FF9F00DFFD7956FFFC00030A950ABF56A0FEA09302BFFFA003FFFF;
defparam sp_inst_0.INIT_RAM_37 = 256'h000000009000FFFF002A002AF000FFFF5555FFFF0000FFFFA000A0000030FFF0;
defparam sp_inst_0.INIT_RAM_38 = 256'hFF0CFFFFFC30FFFCFFFF00000C00FFFFFFFF0000000FFCF0CAA3F55F00A455F5;
defparam sp_inst_0.INIT_RAM_39 = 256'h00002558D5537FFCFFFFAAAAF12ACED5EA00800083FF7CFFCFFFFFFFFD6CFBFF;
defparam sp_inst_0.INIT_RAM_3A = 256'hFFFF0002FFFF00FFFFD5BFFA0000FFFF5FFFA0FEE000FFFF57FFA8000000FFFF;
defparam sp_inst_0.INIT_RAM_3B = 256'h5FD5BFFF0000FFFFFFFF00FFFFFFA8FF5555FFFF5555FFAAFFD5BFFF5555FFAA;
defparam sp_inst_0.INIT_RAM_3C = 256'h5555FFAA5555FFAF5FFFA0FFE000FFFF5555FFFAFFFF0002FFFF00FF5555FFFA;
defparam sp_inst_0.INIT_RAM_3D = 256'hFFFF0000FFFF001FFFFF02FF8000FFFFF9FF06A07FDBA02D3FEAF5FF0002FFFD;
defparam sp_inst_0.INIT_RAM_3E = 256'h0000000003C0000003C0000003C0000002BF0000FE800000F3FF0000FF4F0080;
defparam sp_inst_0.INIT_RAM_3F = 256'hFFFFFFFC2AA02AA0AAACAAAF28A028A04AA87AA8000000000000000000000000;

SP sp_inst_1 (
    .DO({sp_inst_1_dout_w[29:0],dout[3:2]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[3:2]})
);

defparam sp_inst_1.READ_MODE = 1'b0;
defparam sp_inst_1.WRITE_MODE = 2'b00;
defparam sp_inst_1.BIT_WIDTH = 2;
defparam sp_inst_1.BLK_SEL = 3'b000;
defparam sp_inst_1.RESET_MODE = "SYNC";
defparam sp_inst_1.INIT_RAM_00 = 256'h00FF00FF820683FFC035EA9F0A3FF5FF742FA00FFC7FFF60FC0000C0FF0057FC;
defparam sp_inst_1.INIT_RAM_01 = 256'hFA00FAAF000000FF83FFAA800005FFFF03FF00F059FFFD80E0000C00F0003F40;
defparam sp_inst_1.INIT_RAM_02 = 256'h000200023D403D5F0000BF8001FFFFFF00BF003CF4FFFF81F0000300FC005FF0;
defparam sp_inst_1.INIT_RAM_03 = 256'h00000000FFE0FFFF00FF3FFFFDC00DFFFF7FFFCE7FFD80BFFA0801C21FC0EABC;
defparam sp_inst_1.INIT_RAM_04 = 256'h00FF00FF000C0FFFC022EA8A02FFFD5FFFFFFDB0F3FFFE85F3FF3F14F0007FC0;
defparam sp_inst_1.INIT_RAM_05 = 256'h00A02AA00BFFFFFF00000000150015FF00A0AAA00005FFFF2FFF003049FFFD80;
defparam sp_inst_1.INIT_RAM_06 = 256'h0B800808DFF0C97D002E000000AD0FD5BF0030303F403A50AF80AFFF0FF02000;
defparam sp_inst_1.INIT_RAM_07 = 256'hF3C7FFF88B808800CFF0383D0000000051FF57FFDFF0C97D0FDF0FD8800F8FFF;
defparam sp_inst_1.INIT_RAM_08 = 256'h0A800000BC01BFF5000F000050015FF500820F6A083FFFFFFF457170000A000A;
defparam sp_inst_1.INIT_RAM_09 = 256'hF0AFFF7FFC01FFFEF82FF80FAA7FFFA0FF00FFFF0040FFBF00000000BCFDBFFD;
defparam sp_inst_1.INIT_RAM_0A = 256'h00AA000000EB0014AA8000008FC0700003F00F3803706FFF00007DF415540000;
defparam sp_inst_1.INIT_RAM_0B = 256'h03FC03FE000001FF7FF87FF80000007F3003FC0CFAF8F90F4AFFFF3C557FBFE0;
defparam sp_inst_1.INIT_RAM_0C = 256'h7500FFD8FD80ABFC2F50F6FF07F83F9FAA805568AAA82AA80000FFE8A9F8FFF8;
defparam sp_inst_1.INIT_RAM_0D = 256'h46247FFF6B40F4006B40F4000BFFFC00F00040000BFFFC40FF8058000000D800;
defparam sp_inst_1.INIT_RAM_0E = 256'h3F00FF8003F4FFF4FFFFD00009600000003FFF3F07FFF82CFD80FF80A9F457F4;
defparam sp_inst_1.INIT_RAM_0F = 256'h41E3BE1C07FF00000000D000FFF4F80B00008000FD0DFFFD003800FF7F7000BF;
defparam sp_inst_1.INIT_RAM_10 = 256'hFFFCFFFF3F3FFFFF3F3FFFFC9BDBBFFF00C00000080CF7FFAAAA000000CAFF34;
defparam sp_inst_1.INIT_RAM_11 = 256'h50005FFF0505FAF5FD00FD00000300030B3C0FCF0000000005D0FAAFE00EE00E;
defparam sp_inst_1.INIT_RAM_12 = 256'hFF402A00A500550038003FFF2D2CD2FC00FC0FA800007FFF003FFC2A00001FF4;
defparam sp_inst_1.INIT_RAM_13 = 256'h0AA00FFFFFF0AFA4E09BEF6C385207FDFD00A8009400540008260BDBFE14F1FF;
defparam sp_inst_1.INIT_RAM_14 = 256'hA87FA87D2600FFF0EAF81500000A000A8E9881FFBE07BE070980FFFCF578DFD0;
defparam sp_inst_1.INIT_RAM_15 = 256'hC000FF803D00FBF02A0401FBAE000FFFB000FFE00F40FEFCF82BF82B3A6007FF;
defparam sp_inst_1.INIT_RAM_16 = 256'h00031FFCFE0001003EB60FFD00001FFFD78228627FFC8000F81207EF38003FFF;
defparam sp_inst_1.INIT_RAM_17 = 256'h40BCFFC0F400DC00FFFF00FF3FBFC040FFFF00FFFFFE00BF2BCDD43D0000FE00;
defparam sp_inst_1.INIT_RAM_18 = 256'h8F400AFFC5423FBD001FFFF481507F4040B8BF47AA1C2A0C0155BFFF002B000B;
defparam sp_inst_1.INIT_RAM_19 = 256'h07F5F80F03FFFFFCFD0C02F03FD1012FFE00AEBF0005BFFF03EB03CBFFD1FD2F;
defparam sp_inst_1.INIT_RAM_1A = 256'h00BFAFFEFEBF0FF05540D540FD20FF98FF3CFFCF000000003DD0FFAFFF40AFFD;
defparam sp_inst_1.INIT_RAM_1B = 256'hA5FC048305550444FC3333CCFFF40A500000AAAAFF74F1BF00003F80C2FC3D03;
defparam sp_inst_1.INIT_RAM_1C = 256'h6E00918020207FFE5B20A0002FFF2FFF05D5FAFF0003000300800BE0006002FE;
defparam sp_inst_1.INIT_RAM_1D = 256'h33FC3CC339E03FE021013FFF2080FFF439E03FE000033FFE000002FFD030BFCC;
defparam sp_inst_1.INIT_RAM_1E = 256'h1554000015540000002CFFFC00000FFF80028002A550A54F0B500B4F0D70FC3F;
defparam sp_inst_1.INIT_RAM_1F = 256'h24002C000303ACAC1FFFA0000000000000000000155400001554000015540000;
defparam sp_inst_1.INIT_RAM_20 = 256'h2B482BFF308C3DFF308C3DFF10001FFF30843DFF33483FFF31543FFE30083D5F;
defparam sp_inst_1.INIT_RAM_21 = 256'h030C03CFC30CF3CFD000FD5EC008F40FC208F7DF08001F5E32083FDF30883DFF;
defparam sp_inst_1.INIT_RAM_22 = 256'h00001FD50A001FFDC000F00040D07EFDC000F557C554FFFF020017D5C00CF5CF;
defparam sp_inst_1.INIT_RAM_23 = 256'hB400BFD5C000F555D554FFFFC210F7DE41087FDFD008FF5F0C080F5FC008F55F;
defparam sp_inst_1.INIT_RAM_24 = 256'hFFFFFFFFFFFF00000000FFFF00000000CB40FBFFD500FFD500401FFD00001FD5;
defparam sp_inst_1.INIT_RAM_25 = 256'h1FA41AF425562FFEC3FFFC00F0030FFF4501CFFFFFFFFFFF06401ED00C000FC0;
defparam sp_inst_1.INIT_RAM_26 = 256'h0240FF4090246FF40009FFFDFFFF07FDFE000600F0003000F4002400FFD00090;
defparam sp_inst_1.INIT_RAM_27 = 256'h03FF002EF0000F000000000009010BFFC2C0FD3FC3C0FC3F01A101FE01A8FFA8;
defparam sp_inst_1.INIT_RAM_28 = 256'hFFFFC0C0FFFF0000FFFCC0C3FD7C0F830000FFFF0000FFFFBFA84056FFFFFFFF;
defparam sp_inst_1.INIT_RAM_29 = 256'hC000FFFFC000FFFF0003FFFFC000FFFF0003FFFFFFFF0000FD7C0F83FFFC0003;
defparam sp_inst_1.INIT_RAM_2A = 256'hFFFF0003C400FFFFC000FFFF0013FFFC7F43C0BCFFFF00A8C000FFFF0006FFFE;
defparam sp_inst_1.INIT_RAM_2B = 256'hFD7FCF803FFC300335543AAB02FF0008E0001F00FFFFC400FFFFC000FFFF0013;
defparam sp_inst_1.INIT_RAM_2C = 256'hF888F777FFFFF000FAAAF555FFFFF00088B3774FFFF3000FAAB3554FFFF3000F;
defparam sp_inst_1.INIT_RAM_2D = 256'hFF0600FE3FFFC003F80307FF00FFFF03FFFF00035555FFFF5555AAAA0000FFFF;
defparam sp_inst_1.INIT_RAM_2E = 256'hFD005555C0003FFF2400DBFFC03FFFC0C000FFFFEFFFD000C000FFFFC003FFFC;
defparam sp_inst_1.INIT_RAM_2F = 256'h029000040000001A0000000B0000FFE90000FFF8FD7FCF80557F0055FFFFC000;
defparam sp_inst_1.INIT_RAM_30 = 256'h3C03C3FF3C03C3FFFD6BD2BFFFCC0033FFF3F00CF5240ADB03C003305555AAAA;
defparam sp_inst_1.INIT_RAM_31 = 256'hFFFC0003FFFC00030C05F3FF0C00F3FF0300FCFF0300FCFFF6A05FFFF00C0FFC;
defparam sp_inst_1.INIT_RAM_32 = 256'hFFFFC07FFFFFC0BFFFFFC0FF0A9FFFF5309B3F64C19FFE60C19FFE60FFFF5000;
defparam sp_inst_1.INIT_RAM_33 = 256'h303A03C0FFFCC0030000C000FFFFFFF8FFFFFFFD0000AAAA00000F00FFFFC0BF;
defparam sp_inst_1.INIT_RAM_34 = 256'h01557EAAA800A8005400ABD0FFFFC00A000000000000000003C003305555AAAA;
defparam sp_inst_1.INIT_RAM_35 = 256'hA000A000FFFFF9FFFFD0FFFFFFFFFF00FF0000FFFFFCC0033FFFC0C002AA02AA;
defparam sp_inst_1.INIT_RAM_36 = 256'hFFFFC000F3FFCF00CFFC3C03FFFC00039010BFFF0006FFFEC040FFFF0003FFFF;
defparam sp_inst_1.INIT_RAM_37 = 256'h000000009EAADFFF0B400BFF7C007FFF0000FFFF0000FFFF0600FE0000C0FFC0;
defparam sp_inst_1.INIT_RAM_38 = 256'hA820FFFDFC30FFFCFFFF02AA80007EAAFFFFA800002FABD01FF4100403000300;
defparam sp_inst_1.INIT_RAM_39 = 256'h0000C823FFF3000CFFFFF555FF15C0EAFFFA57A0AFFF50FF22AA7FFF555BFFFF;
defparam sp_inst_1.INIT_RAM_3A = 256'hFFFF00BFFFFF007FD400FFFF0000FFFF007FFFFFF800FFFF0017FFE80000FFFF;
defparam sp_inst_1.INIT_RAM_3B = 256'h0100FFFF0000FFFFFFFF00FFC003FFFF0000FFFF0000FFFFD400FFFF0000FFFF;
defparam sp_inst_1.INIT_RAM_3C = 256'h0000FFFF0000FFFF007FFFFFF800FFFF0000FFFFFFFF00BFFFFF00FF0000FFFF;
defparam sp_inst_1.INIT_RAM_3D = 256'hFFFF0000FFFF0000FFD4BFFFFA007FFFFE7F0180C6BF3F509FFC782302BFFD40;
defparam sp_inst_1.INIT_RAM_3E = 256'hAA00000003C0000003EA0000ABC000002F5A0000A5F800003E5F000050B4A508;
defparam sp_inst_1.INIT_RAM_3F = 256'hFFFFFFFCD008F55E8208975DD248F7DE82A087F50028002800AA0000AAAA0000;

SP sp_inst_2 (
    .DO({sp_inst_2_dout_w[29:0],dout[5:4]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[5:4]})
);

defparam sp_inst_2.READ_MODE = 1'b0;
defparam sp_inst_2.WRITE_MODE = 2'b00;
defparam sp_inst_2.BIT_WIDTH = 2;
defparam sp_inst_2.BLK_SEL = 3'b000;
defparam sp_inst_2.RESET_MODE = "SYNC";
defparam sp_inst_2.INIT_RAM_00 = 256'h0055007FFFE8FFFD401FFFFFFFFF00FFE83FFE0FF41FF41EFF2880C2FD00A950;
defparam sp_inst_2.INIT_RAM_01 = 256'hFF09FFFF03FF03FF0FFCFFFF002B557F8BFF80F4507D507DF3408CB040004000;
defparam sp_inst_2.INIT_RAM_02 = 256'hA3EFA3EF000000008BFDF407002A7FFFE8FFE83EA47FF47AFCA00308F400A540;
defparam sp_inst_2.INIT_RAM_03 = 256'h000200021FC01FC4A03FFFFFFC00AC1FF83FFFC70542CFF7FF144EEBFFFC607C;
defparam sp_inst_2.INIT_RAM_04 = 256'h000000FF0AA90FFD001EFFFF2FFF500397FFFCF8F1FFF1EAF1540FA0D0009500;
defparam sp_inst_2.INIT_RAM_05 = 256'h0017FFFFBFF541F50000000B03FF03FF0015FFFF00055405BFFFBEF4507D507D;
defparam sp_inst_2.INIT_RAM_06 = 256'h3FE00E0CC540C540803E8BEA2D502D40FFC036B8000000007FD07FD50FF8FFFE;
defparam sp_inst_2.INIT_RAM_07 = 256'hF401F45FFFE0C70C0FF4D17438063AFA001500550540054000070FEFF80BFF43;
defparam sp_inst_2.INIT_RAM_08 = 256'h01F800AA53405340002F00BF2FC02FC0000E2FFF3DBF3D3FFFC036B8003F02BF;
defparam sp_inst_2.INIT_RAM_09 = 256'hD3FDD00DFC28FF5055BFFF8FF41FF41EFF00FFFFBFFF40FF002A002A53F05310;
defparam sp_inst_2.INIT_RAM_0A = 256'h00FF000000FF0000DFC02000FFC800080BF03F3E0300FFFF000004D0B5560000;
defparam sp_inst_2.INIT_RAM_0B = 256'h000003FF000000050D500FFF000000053003FC0CFFFFF02FBFFFFD3DFFCFFFFF;
defparam sp_inst_2.INIT_RAM_0C = 256'h0000D6006100FFF11D00FFC9003485FFFFD4000000000000AA947FD4FFF456F4;
defparam sp_inst_2.INIT_RAM_0D = 256'h006005FFB4004000BFE04BE092FFFD004000000090F7FF00FFF8000000000000;
defparam sp_inst_2.INIT_RAM_0E = 256'hFC00FFF80B40FF40FFFFCE000690000003FFFC1C003F143F56F8ABF8FE40FF40;
defparam sp_inst_2.INIT_RAM_0F = 256'h04A3FB5C007F000000004000FC0057FFA800FF80700577F5BFBF287F003800FF;
defparam sp_inst_2.INIT_RAM_10 = 256'hFFDCFFFF2A3FFFFF2A3FFFFCB9B9FFFD00C00000015506A6000000000240DDB4;
defparam sp_inst_2.INIT_RAM_11 = 256'h0E280F7F28B0FDF0FC00FC0000072AA2BFD1BF2F0BFC0BFC8918FFF7FE07FEA2;
defparam sp_inst_2.INIT_RAM_12 = 256'hF400F400FE00F80000E201FF8B00FF4000FE3FFE00000540003FFEBF00000000;
defparam sp_inst_2.INIT_RAM_13 = 256'h07FC07FD07F40540FD07F6FFFE0FF1FFD000D000F800E000BF41BDBF1F831C7F;
defparam sp_inst_2.INIT_RAM_14 = 256'hFFFF57FF6C40D3D0FFD0AA802FDD2D2AFF81FC7FFFEB15EB9B10F4F4FFFD8000;
defparam sp_inst_2.INIT_RAM_15 = 256'h0000FFF00000FF40FF550BFF7F0003FF4000FFFC0000FFD0FF77F4A8FE06F1FF;
defparam sp_inst_2.INIT_RAM_16 = 256'h1EA31FF4FF000000FF4105FEBE80BFD4FF4F00BF055000007D552FFFFC000FFF;
defparam sp_inst_2.INIT_RAM_17 = 256'h007FFFF87A808500FF7D00FD1FDF6020FFFD007DFFFF00FF15406A901578FFF8;
defparam sp_inst_2.INIT_RAM_18 = 256'hFD020FFDA80FD7FEBF5440ABC5001000A0FD5FE8FFF0FFF2BE0041FF005C002F;
defparam sp_inst_2.INIT_RAM_19 = 256'h00D0FF0F2E2DFE125EA0A1503FC2343FFD02DFFDBE0041FF03CC0FEFFFC2F43F;
defparam sp_inst_2.INIT_RAM_1A = 256'h00151FFF3FFC03C000004000FFD0FC2F5DD25F2F000000009918FFF75000FFD0;
defparam sp_inst_2.INIT_RAM_1B = 256'h7FFD000015FF0088F94584107F4050002A02D5FFF41AFF5F00001FF8C3F43C00;
defparam sp_inst_2.INIT_RAM_1C = 256'h0000FFF001001FFF8470FFA8F541F5418918FFF7000B2AA100C00FFC003003FF;
defparam sp_inst_2.INIT_RAM_1D = 256'h1BD01CC31F9C1FFC004405FF2000F5001F9C1FFC02AA17FF000A0FF5AA80FDD4;
defparam sp_inst_2.INIT_RAM_1E = 256'hF0960000FAAA00000030FFF0000001FF1FF414140000000FB400340F0C30FC3F;
defparam sp_inst_2.INIT_RAM_1F = 256'h00003C003FFF40003AAAC55400000000B556000097960000B5830000AFAA0000;
defparam sp_inst_2.INIT_RAM_20 = 256'h102C1F6F32CC3EFF30CC3CFF0C900FBD304C3C7F312C3FFF30003D5D32AC3EAF;
defparam sp_inst_2.INIT_RAM_21 = 256'hAB2CABEFCB2CFBEFCAACFAAF42B47ABFCB2CFBEFACB4AFBF332C3FEF32CC3EFF;
defparam sp_inst_2.INIT_RAM_22 = 256'hAA00ABF8AA00ABF8C554FFFEA828AFF8C800F801C000F557AB28ABE842B47ABF;
defparam sp_inst_2.INIT_RAM_23 = 256'h00281FA8CAA8FAA800001557C32CF3EFA8ACAFAFCAACFBAFACACAFAFCAACFAAF;
defparam sp_inst_2.INIT_RAM_24 = 256'hFFFFFFFFFFFF00000000FFFF00000000C40CFFDF001415FEB400BFF8B428BFF8;
defparam sp_inst_2.INIT_RAM_25 = 256'h0000000000003FFFC1FFFE00D0032FFF000045FDFFFFFFFF24602DE00C000FC0;
defparam sp_inst_2.INIT_RAM_26 = 256'h2058DFF80A90FFD00210FF50FFFFAA00FFE00060F8001800F0003000FD000900;
defparam sp_inst_2.INIT_RAM_27 = 256'h01FF0004D0002F002FF8255824002FFFC3C0FC3F60E07F1F000600070009FFFD;
defparam sp_inst_2.INIT_RAM_28 = 256'hFFFFD5C0FFFF0000FFFCD5C3FEBC01430000FFFF0000FFFF5FD0A024FFFFFFFF;
defparam sp_inst_2.INIT_RAM_29 = 256'hC000FFFFC000FFFF0003FFFFC000FFFF000BFFFFFFFF0000FEBC0143FFFC0003;
defparam sp_inst_2.INIT_RAM_2A = 256'hFFFF0023C003FFFFC800FFFFFE0355FC0023FFFCFFFF1500C000FFFF0003FFFF;
defparam sp_inst_2.INIT_RAM_2B = 256'hFEBFC1403FFC30032AAA2AAA03FF001DF0000F00FFFFC000FFFFC800FFFF0003;
defparam sp_inst_2.INIT_RAM_2C = 256'hF999F666FFFFF000F000FFFFF000FFFF99B3664FFFF3000F0003FFFF0033FFCF;
defparam sp_inst_2.INIT_RAM_2D = 256'hFD0302FF3FFFC003FC0303FF00FFFF03FFFD0009888877770000FFFFAAAAFFFF;
defparam sp_inst_2.INIT_RAM_2E = 256'hFF00FFFF1800E7FFC0003FFFC01FFFE0C000FFFFFFFFC000C000FFFF60037FFC;
defparam sp_inst_2.INIT_RAM_2F = 256'h2900004000000003000A002F0000FFF40028FFFEFEBFC140FFFF00FFFFFFC000;
defparam sp_inst_2.INIT_RAM_30 = 256'h3C03C3FF3C03C3FFF3FFCFDFF4BCEB43FFD2C02FAAD0552FFFFF555503C00330;
defparam sp_inst_2.INIT_RAM_31 = 256'hFFFC0003FFFC00030C00F3FF0C00F3FF0300FCFF0300FCFFF00E0FFFF00C0FFC;
defparam sp_inst_2.INIT_RAM_32 = 256'hFFFFC001FFFFC0FFFFFFC0FFB09BFF64309B3F64C19FFE60C19FFE60FFFF0000;
defparam sp_inst_2.INIT_RAM_33 = 256'h302003D50000D555AAA8D557FFFFFFFEFFFFFFF40000555500000F00FFFFC0FF;
defparam sp_inst_2.INIT_RAM_34 = 256'h0000015557E0FFE0000054003FFFF5500000000000000000FFFF555503C00330;
defparam sp_inst_2.INIT_RAM_35 = 256'h40007C00FFFFFF00FF0000FFFD00FFFF0060FF9F2AAAD5D5AAA8D557BD55BFFF;
defparam sp_inst_2.INIT_RAM_36 = 256'hFFF5C00AFCFFC3C04D56B7A9FFFC0003C080FFFF0003FFFF60207FFF0009FFFD;
defparam sp_inst_2.INIT_RAM_37 = 256'h6D55EFFF00000000FC00FFFF078007FF0000FFFF0000FFFF00C0FFC00900FD00;
defparam sp_inst_2.INIT_RAM_38 = 256'hFC30FFFCFF5CFFFEFD55BFFFFEAA015557FFFFE0ABFF54009FF6B00E01A001A0;
defparam sp_inst_2.INIT_RAM_39 = 256'h0000C693FFFF0000FF2AC0D5FFFFFAAA5FFFA0FFFF50ABF5FFFFAAA79FFFBFFF;
defparam sp_inst_2.INIT_RAM_3A = 256'hFFFF00FFFFFF00010000FFFFE8007FFF001FFFFFFE005FFF0000FFFF002BFFD4;
defparam sp_inst_2.INIT_RAM_3B = 256'h0000FFFF0000FFFFFFFF00FFC003FFFF0000FFFF0000FFFF0000FFFF0000FFFF;
defparam sp_inst_2.INIT_RAM_3C = 256'h0000FFFF0000FFFF001FFFFFFE005FFF0000FFFFFFFF00FFFFFF00FF0000FFFF;
defparam sp_inst_2.INIT_RAM_3D = 256'hFFFF002FFFFF0000F500FFFFFFE8017FF5BF0AE9F3FF0F00FBFF0750017FFE80;
defparam sp_inst_2.INIT_RAM_3E = 256'h57C0000003C000000055000055000000B6FF0000FF9E000007FA0000AD400290;
defparam sp_inst_2.INIT_RAM_3F = 256'hFFFFFFFC45547FFFC30CF3CF45147FFF05081F5E00D000FF03D5000055550000;

SP sp_inst_3 (
    .DO({sp_inst_3_dout_w[29:0],dout[7:6]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[7:6]})
);

defparam sp_inst_3.READ_MODE = 1'b0;
defparam sp_inst_3.WRITE_MODE = 2'b00;
defparam sp_inst_3.BIT_WIDTH = 2;
defparam sp_inst_3.BLK_SEL = 3'b000;
defparam sp_inst_3.RESET_MODE = "SYNC";
defparam sp_inst_3.INIT_RAM_00 = 256'h0000003F17F017F00010FFEF7FF500F507FFFF0740054005FF100EEF40004000;
defparam sp_inst_3.INIT_RAM_01 = 256'h5524557F2FFF2FFF07FFFFFF000000009FFFF01000000000F0005FF000000000;
defparam sp_inst_3.INIT_RAM_02 = 256'hFA7FFAFF00000000FFFCF00B0000000007FFFC1C00050005FC403BBC00000000;
defparam sp_inst_3.INIT_RAM_03 = 256'h000300AC01F801F8FF077FFF00000000FEFF55E100030000FF0020FFFF504010;
defparam sp_inst_3.INIT_RAM_04 = 256'h0000003FBFFCBFFC0040FFBF1BFF002F5FFFFC70D050D050F000AFF000000000;
defparam sp_inst_3.INIT_RAM_05 = 256'h010AFEFFF50000000000002F2FFC2FFC010BFEFF00000000FFFFFF1000000000;
defparam sp_inst_3.INIT_RAM_06 = 256'hFFF0C45F00000000F03EFFFF00000000FFC0003C000000000000000007FFFFFF;
defparam sp_inst_3.INIT_RAM_07 = 256'h140014002FF0F01F01400000BC89BF770000000000000000000107FF143F1400;
defparam sp_inst_3.INIT_RAM_08 = 256'h007F0BFF00000000003F03FF0000000000473FBF51F45004FFC0003C083F0FFF;
defparam sp_inst_3.INIT_RAM_09 = 256'h00000000407F4000FFFFFF0740054005F000F0545FFD00FD00950B7F00400000;
defparam sp_inst_3.INIT_RAM_0A = 256'h00E1001E000055550FC0F000001D555D0FC07FFC01307FFC000000C015540000;
defparam sp_inst_3.INIT_RAM_0B = 256'h000003FF00000000000003FF000000003EB3FEBCC17FC6FFFFFFFC04FD40FD40;
defparam sp_inst_3.INIT_RAM_0C = 256'h000000000000F48400001521000026D4000000000000000000000000FD40FD40;
defparam sp_inst_3.INIT_RAM_0D = 256'h00040005F0000000F15401541FD45000000000001014550051F4000000000000;
defparam sp_inst_3.INIT_RAM_0E = 256'hFE0BFFFFD400D4001FF40150000000002FFF500E001F001FCFFFBFFFD400D400;
defparam sp_inst_3.INIT_RAM_0F = 256'hC14B3EB40007000000000000F4907F6CE80AFFFA00000040FFFF403F007F007F;
defparam sp_inst_3.INIT_RAM_10 = 256'h5554FFFD3F3FFFFF3F3FFFFC1BD01FD000C00000004000000000000000006D40;
defparam sp_inst_3.INIT_RAM_11 = 256'h0014001414001400140014000BEAFFF5FFC0FF1F3F503FFF3150FE047FEAFFF5;
defparam sp_inst_3.INIT_RAM_12 = 256'h2FA0FA00554055000001000140004000007FFFFF00000000007FFFBF00000000;
defparam sp_inst_3.INIT_RAM_13 = 256'h000000000150000032F80FC7D301D0D5BE80E800550054005CBE53F100C00035;
defparam sp_inst_3.INIT_RAM_14 = 256'h4005FE854000550055005500FF01F4FF15C115159055FFA51000550055405540;
defparam sp_inst_3.INIT_RAM_15 = 256'h0000FFFC0000400034003FFF030003550000FFFE000050003C0613FFD304D055;
defparam sp_inst_3.INIT_RAM_16 = 256'h0054005414000000FD0002FF17E017E0000DFFFD00000000D000FFFFDC000D55;
defparam sp_inst_3.INIT_RAM_17 = 256'h000154000540FAA05400A9000015056A5400A950AFF4501F000000003FCFC03F;
defparam sp_inst_3.INIT_RAM_18 = 256'hFE2D7FD274D040400003FFFF00000000F0108FF47FD67FD3D7EA2815B017A02F;
defparam sp_inst_3.INIT_RAM_19 = 256'h0400F9000F500F4F0140FC0037C03015FE2DC3D2D7EA281503C72FEF47C04015;
defparam sp_inst_3.INIT_RAM_1A = 256'h0000005507D0000000000000FC082BF700C0011F0A000AAF3150FE0400005400;
defparam sp_inst_3.INIT_RAM_1B = 256'h07F40484000000000000000034000000FF6BBCBF100010000000005CC1001400;
defparam sp_inst_3.INIT_RAM_1C = 256'h80607F9C0044017F2100FD50000000003150FE0400ABFFFF01000F50000000F4;
defparam sp_inst_3.INIT_RAM_1D = 256'h07C007C1005B005F0000000000000000005B005F00003FFF003F3FC00030FFCC;
defparam sp_inst_3.INIT_RAM_1E = 256'hF9090000500400000030557000000001000000000000000F5000000F0FF0F41F;
defparam sp_inst_3.INIT_RAM_1F = 256'h000004000AAAB554355D400000000000155400006A590000F0EB00000FAA0000;
defparam sp_inst_3.INIT_RAM_20 = 256'h0010001F000007FD0040077F040007D00000070110101F5D00000400000007FD;
defparam sp_inst_3.INIT_RAM_21 = 256'h40007FFF40007FFF40007FFF000007F440007FFF40007FF40000047D000007DD;
defparam sp_inst_3.INIT_RAM_22 = 256'h40007FFF40007FFF0000155540007FFF00001F000000100140007FFF000007F4;
defparam sp_inst_3.INIT_RAM_23 = 256'h000001FF00001FFF0000000100001C7D40007FFF00001FFD40007FFF00001FFD;
defparam sp_inst_3.INIT_RAM_24 = 256'hFFFFFFFFFFFF00000000FFFF0000000040047D070000001540007D1F40007FFF;
defparam sp_inst_3.INIT_RAM_25 = 256'h0000000000000554C015FFEA02ABFD57000000005555FFFF0000101000000140;
defparam sp_inst_3.INIT_RAM_26 = 256'h0403FBFF9000D00069007D00FFFF5500FFFE0006FC000C00C000C000D0009000;
defparam sp_inst_3.INIT_RAM_27 = 256'h0015AAAA0000F400FFFFC00318001FFF30793F8618341FCB00000000001AFFFA;
defparam sp_inst_3.INIT_RAM_28 = 256'hFFFFC0C05555AAAAFFFCC0C35554AAA90000FFFFAAAA55FFDB0024C0FFFFFFFF;
defparam sp_inst_3.INIT_RAM_29 = 256'hE0007FFF60007FFF0003FFFF1AAA1FFFAAD4FFD4FFFF0000FFFC0003FFFC0003;
defparam sp_inst_3.INIT_RAM_2A = 256'hFFFDAAA9CFBFFD75EAAAD555D7C32A3CAAA95554FFFF000018001FFF0003FFFF;
defparam sp_inst_3.INIT_RAM_2B = 256'h55556AAA35543AAB3FFC3003007F000040000F00FFFFC0007FFF6AAAFFFF0003;
defparam sp_inst_3.INIT_RAM_2C = 256'hFBBBF444FFFFF000F000FFFF3AAA3FFFBBB3444FFFF3000F0003FFFFAABBFFEF;
defparam sp_inst_3.INIT_RAM_2D = 256'h5003AFFF07FFF803FC2B03D70017FFEBFF50AA50999966660000FFFF00000000;
defparam sp_inst_3.INIT_RAM_2E = 256'hFD00555590006FFFBAAAEFFFC001FFFEC000FFFFFFFFC000C000FFFF1AAB1FFE;
defparam sp_inst_3.INIT_RAM_2F = 256'hC0002400AAAAAAAB00000001AAA8FFF85540FFD4FFFFC000557F0055FFFFC000;
defparam sp_inst_3.INIT_RAM_30 = 256'h3C03C3FFBEABEBFFD3FFED00FF7C0583D4156BFEFF8B95F47FFD800203F00300;
defparam sp_inst_3.INIT_RAM_31 = 256'hFFFC0003FFFEAAAB0C00F3FF0C00F3FF0300FCFFABAAFEFFF00C0FFCF00C0FFC;
defparam sp_inst_3.INIT_RAM_32 = 256'hFFFFC000FFFFC055FFFFC000309B3F64309B3F64C19FFE60EBBFFEEAFFFF0000;
defparam sp_inst_3.INIT_RAM_33 = 256'h301503EA0000C000FFFCC003FFFFFFFFFFFFF5C00000000000000F00FFFFC0FF;
defparam sp_inst_3.INIT_RAM_34 = 256'h00000000A810FFF000000000EFFF15E80000AAAA000000005555AAAA03F00300;
defparam sp_inst_3.INIT_RAM_35 = 256'h00000000FFFFFF00FF0000FFD000FFFF0006FFF93FFFC0C0FFFCC00342AAFFFF;
defparam sp_inst_3.INIT_RAM_36 = 256'h55AFEAF5D5356AFAFFFD55575556AAA963017FFF5003FFFF056A057FA950FD50;
defparam sp_inst_3.INIT_RAM_37 = 256'h6154FFFF00000000F000FFFF001500150000FFFFAAAAFFFF0030FFF050005000;
defparam sp_inst_3.INIT_RAM_38 = 256'hFC30FFFC5504FFFF42AAFFFFFFFF0000A81FFFF0FFFF0000C003FFFF0004AAAE;
defparam sp_inst_3.INIT_RAM_39 = 256'h00001AA4FFFF0000F215CDEA5555FFFF43FFBCFF5000F500FFDCF6BF4555FFFF;
defparam sp_inst_3.INIT_RAM_3A = 256'hFFFF00FFFFFF00000000FFFFFFEA00158007FFFFFFFA00050000FFFFABFF5400;
defparam sp_inst_3.INIT_RAM_3B = 256'h0000FFFFAAAA5555FFFF00FFC0037FFFAAAA55550000FFFF0000FFFFAAAA5555;
defparam sp_inst_3.INIT_RAM_3C = 256'hAAAA5555AAAA55558007FFF8FFFA0005AAAA55FFFFFF0055FFFF0000AAAA5555;
defparam sp_inst_3.INIT_RAM_3D = 256'hFFFF00FFFFFF00004000FFFFFFFF0000A97FFF80F16A0FBFFFFF00540001FFFE;
defparam sp_inst_3.INIT_RAM_3E = 256'h03C0000003C000000000000000000000F3FF0000FFCF00000015000040001400;
defparam sp_inst_3.INIT_RAM_3F = 256'hFFFFFFFC55507FF845147FFFB554BFFE54547FFF0000001003C0000000000000;

endmodule //Gowin_SP_8KBx8