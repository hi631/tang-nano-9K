//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.03
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Wed Nov 30 22:31:45 2022

module Gowin_pROM_bios (dout, clk, oce, ce, reset, ad);

output [31:0] dout;
input clk;
input oce;
input ce;
input reset;
input [10:0] ad;

wire [23:0] prom_inst_0_dout_w;
wire [23:0] prom_inst_1_dout_w;
wire [23:0] prom_inst_2_dout_w;
wire [23:0] prom_inst_3_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

pROM prom_inst_0 (
    .DO({prom_inst_0_dout_w[23:0],dout[7:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_0.READ_MODE = 1'b0;
defparam prom_inst_0.BIT_WIDTH = 8;
defparam prom_inst_0.RESET_MODE = "SYNC";
defparam prom_inst_0.INIT_RAM_00 = 256'hE7E6E6E633B0018EFC0D657442530D4320657275616931295320436E6543314E;
defparam prom_inst_0.INIT_RAM_01 = 256'h5429C74C33C7449BC72424C71C44A58B02BF04076A3C754000268033F0C0E715;
defparam prom_inst_0.INIT_RAM_02 = 256'hA7AE00000B84003E8384630F1E1E02C7C6440480F6076AD0C2C7687CC76012C7;
defparam prom_inst_0.INIT_RAM_03 = 256'hE6E68AE4B0FB80B03C07F8E81913B4C6A8AD9674DAABE80015F8E81914FF1419;
defparam prom_inst_0.INIT_RAM_04 = 256'h540D6465206F531603CD136304F6E07406E813D11378E807A3F8ECD2FB012100;
defparam prom_inst_0.INIT_RAM_05 = 256'h088B50300D692032444D4D0D62627A3349284D363850316820666D3065206F2D;
defparam prom_inst_0.INIT_RAM_06 = 256'h759617E4061FCDCDA8FEA8B4CDC6470700137F57831F1E1F8906B03C07C07524;
defparam prom_inst_0.INIT_RAM_07 = 256'h803CE2920275758020773C000001740C8A3CC9F00175EB0501F580D1078AC540;
defparam prom_inst_0.INIT_RAM_08 = 256'h5254E85CE2FBE10275EB81CA80C114E98486F7EBF7741E31CA08C90275EB0551;
defparam prom_inst_0.INIT_RAM_09 = 256'h02F62EDFF6C1118A590EB9BF088AC25B52008020750AF6C0001AA106108AC25B;
defparam prom_inst_0.INIT_RAM_0A = 256'h000FB3327510C5C0E1800515B48B00D58A0E838B030608B3C280750A0E80C21A;
defparam prom_inst_0.INIT_RAM_0B = 256'h2EBE5701F94F59C0A50ABEEB4F030D77CFF001078BFC4F40FC3280D4F309CF00;
defparam prom_inst_0.INIT_RAM_0C = 256'h6C4E00000000565883CBEF080A83018B9C0EDCEB0AFB1E808ACD8ACDFF7502EB;
defparam prom_inst_0.INIT_RAM_0D = 256'hE96914BEB800C74A0642432E58FF05B0B8080FC487870202E6A0000001687444;
defparam prom_inst_0.INIT_RAM_0E = 256'hBF4C28C775EB0402BA000006DF75742000220000068FF9C73CF9C74C28C7141A;
defparam prom_inst_0.INIT_RAM_0F = 256'h7559FF8E0059000050EFEF07B0EF8B07DCB82449F6B9F806000006DFC74AF806;
defparam prom_inst_0.INIT_RAM_10 = 256'hC150EFEFB0C50485605010BBCD81CD694010750606B4231100B02EEEC00375CD;
defparam prom_inst_0.INIT_RAM_11 = 256'h4C0A12E70A04CDCDE700777349A22460C30E8B07C3EFEF8ABAC0C0753A0050E3;
defparam prom_inst_0.INIT_RAM_12 = 256'hF0D1FA6B33EBF741F7C379038AE3CCF2F3032A843ED200E8CAC3E7B0D4A3D808;
defparam prom_inst_0.INIT_RAM_13 = 256'h3C3C3C00065B02E8E38BB78AC3E207E8E35BAB07E8535803C7D88BB807508B53;
defparam prom_inst_0.INIT_RAM_14 = 256'h429B9B9B9B01EC9BC09B00000080A05A331636B853763AB2B2D280594A10B93C;
defparam prom_inst_0.INIT_RAM_15 = 256'h8A42030352892432E6EE24E3A0B0EC6079108AF260C78AEC60940377C3A48A72;
defparam prom_inst_0.INIT_RAM_16 = 256'hEC038A61EEE7C058502ED0752EC0DA6103EEBAC3C18A42BA52B70010AACDB3C3;
defparam prom_inst_0.INIT_RAM_17 = 256'hF5BACBC3CF10CED11CB569F2C1B02BEF07E71E3AC30352EE936C6B93FA58C88A;
defparam prom_inst_0.INIT_RAM_18 = 256'h0733ED2E600B08C33C3C3C7274747474582E10BABA0110E60000F7B86AA84B26;
defparam prom_inst_0.INIT_RAM_19 = 256'hC177C3C47C0001848561DC10C87400006084F70EB8723EB884ACF6E344893310;
defparam prom_inst_0.INIT_RAM_1A = 256'h89BB8A3CCD74445850004546A85003F3E3C389243275C30F8875C8BAD8C305F6;
defparam prom_inst_0.INIT_RAM_1B = 256'h19BD78A20001200C6133022400AB893300753EBB0001B70210BBB82180ABEDC3;
defparam prom_inst_0.INIT_RAM_1C = 256'hD0F63626871E81E8AA0122EC1AFB001F1E136A00405770575757158ECD57BC80;
defparam prom_inst_0.INIT_RAM_1D = 256'h006A80FF8D921F06B4859475EFF0EFEFEFF0EEEFEFEFF0EFEFEFEFEFEFEE5D46;
defparam prom_inst_0.INIT_RAM_1E = 256'h1EEAC194CB80AA80743ED2E2BA3FD2C1E1C3D8C02B51E860C14A808403BD6474;
defparam prom_inst_0.INIT_RAM_1F = 256'h086C040B00ED8E9475C38061025E1E085C8B36508069F6EBC3013FC0FE03F1B9;
defparam prom_inst_0.INIT_RAM_20 = 256'h4AC5EEEEE8B817C0EC8A525E5174088B7F8B14F26AC30000166C890A106C0C6C;
defparam prom_inst_0.INIT_RAM_21 = 256'h8B14648A72BA87F02E06D8EF033D0B830B837540EDEB83A8EB8AFBECC3ECECEE;
defparam prom_inst_0.INIT_RAM_22 = 256'h4F5EE46187164A02FF85E8748BA4F3A40174C005DBFFF7778BC9071FFF4A0474;
defparam prom_inst_0.INIT_RAM_23 = 256'h7426150700C3F9A0B48900038C89E70021801ECAB80362C09290E258862227C4;
defparam prom_inst_0.INIT_RAM_24 = 256'h00C62CB0C7B8A3A174743C727401E6A1A177B47D9DA1A164B8001F1E08C07BEB;
defparam prom_inst_0.INIT_RAM_25 = 256'hE502EB72C8028AA602E9FF00128AC202F2E877C5E858F9F32E8806EB8893E8A1;
defparam prom_inst_0.INIT_RAM_26 = 256'h0004360C36CAAD3B8B1A80723B3674B45E75747474743CA874C46A0000083CAA;
defparam prom_inst_0.INIT_RAM_27 = 256'hC32A327424FADA5A26E88A110E99530023E8E31FE77597A0E4260277A000B736;
defparam prom_inst_0.INIT_RAM_28 = 256'hB82E293A66703228326E6E61656C61692062F0EA460D018AE8C00142B8B00135;
defparam prom_inst_0.INIT_RAM_29 = 256'hFEE440FC705080C5A0731E001BA040EB0E16CA00C60000160140CD0013BB0001;
defparam prom_inst_0.INIT_RAM_2A = 256'h74EB2A320228BA75385B73E808E8FAC0B9801F8353ACB474AD000000000CF0A0;
defparam prom_inst_0.INIT_RAM_2B = 256'h0ACD9203F52E00F52E8B400020E3F52EE67406757209E860C32A320128BAE6E6;
defparam prom_inst_0.INIT_RAM_2C = 256'hDA5201B2500368FF74E8C4B9C3F60AC953F083FF88E9E2ACACED9090FFEB7426;
defparam prom_inst_0.INIT_RAM_2D = 256'h1FEFDA5201B250C5E85835ECE81101759DFF5602FEAC8303E81FE483FF1FD9EF;
defparam prom_inst_0.INIT_RAM_2E = 256'hFE0EEFE200DA5277ECE8FEB0FD4BD09880FED5E802E874FE8303E81FE4F383FF;
defparam prom_inst_0.INIT_RAM_2F = 256'h595EE8E7C18B1FE114801CFE0E28A8E88BB1F874A2BEFE0E548091FC04CCE870;
defparam prom_inst_0.INIT_RAM_30 = 256'h2824201814110B08053F3F3F3F3F152A152A2A2A00FF0000FF4000FF00019500;
defparam prom_inst_0.INIT_RAM_31 = 256'h000F0B0703271F3F3F1F273F1F002F3F00003F2F001F3F10003F3F00103F3832;
defparam prom_inst_0.INIT_RAM_32 = 256'h2A2A002A152A2A2A003F3F3F3F3F153F3F3F3F3F152A152A2A2A002A152A2A2A;
defparam prom_inst_0.INIT_RAM_33 = 256'h003F2A2A3F2A002A2A2A2A2A00171307033F3F3F3F3F153F3F3F3F3F152A152A;
defparam prom_inst_0.INIT_RAM_34 = 256'h3F3F152A3F3F2A3F153F2A3F3F2A152A2A3F2A2A153F3F2A3F3F002A3F2A2A3F;
defparam prom_inst_0.INIT_RAM_35 = 256'h00004600000019001700140010000B000800030000002D2A263F3B07033F3F3F;
defparam prom_inst_0.INIT_RAM_36 = 256'h20202D2D2E2E11111E1E1F1F2C2C10100000584E4A7D726B5A00560025001C00;
defparam prom_inst_0.INIT_RAM_37 = 256'h181817172525161624243232151522222323303031311313141421212F2F1212;
defparam prom_inst_0.INIT_RAM_38 = 256'h68546A566C58004C004900510048004D0050005300520047004B004F19192626;
defparam prom_inst_0.INIT_RAM_39 = 256'h7E287D087C0639397A047B05792878022929000F6B576D596F5B715D8C886955;
defparam prom_inst_0.INIT_RAM_3A = 256'h0E0E2B1B1B1A1C1C83071A292809820D270DA4E035353434800B810033337F0A;
defparam prom_inst_0.INIT_RAM_3B = 256'h994937374A4AA1514E4E8B87010198489D4D705CA050A353A25297479B4B9F4F;
defparam prom_inst_0.INIT_RAM_3C = 256'h0000000000000000000000000000000000000000000C00000000002B6E5A4646;
defparam prom_inst_0.INIT_RAM_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam prom_inst_0.INIT_RAM_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam prom_inst_0.INIT_RAM_3F = 256'h3930F0EA00000000000000000000000000000000000000000000000000000000;

pROM prom_inst_1 (
    .DO({prom_inst_1_dout_w[23:0],dout[15:8]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_1.READ_MODE = 1'b0;
defparam prom_inst_1.BIT_WIDTH = 8;
defparam prom_inst_1.RESET_MODE = "SYNC";
defparam prom_inst_1.INIT_RAM_00 = 256'h06216140C0366AD0B80A646520320A615300616D65633720204220206C683865;
defparam prom_inst_1.INIT_RAM_01 = 256'h00F00600EE0600E50600E30600083344B9F50033001602423315F3FF1F078CB8;
defparam prom_inst_1.INIT_RAM_02 = 256'hE6E6CD10C68940C78480D40EC78383444408F8F333334001F40600F40600F306;
defparam prom_inst_1.INIT_RAM_03 = 256'h6064E06020E826A700E83CB54972FF13E6E600051375E114B43CF14972F8E200;
defparam prom_inst_1.INIT_RAM_04 = 256'h610A0D63647532CD3314B8E27406E80696C3BEE8A1E2D7BE94E8B4CDB440E6E7;
defparam prom_inst_1.INIT_RAM_05 = 256'h8AEC533A0A74314D52423A0A756920365031482030550D6962696F32723E2D4E;
defparam prom_inst_1.INIT_RAM_06 = 256'h1F0000606ACF097420CC01041C4702007581020207BB535B46408006251AF7F8;
defparam prom_inst_1.INIT_RAM_07 = 256'hCA59FD75EB0524F674C0830034C70380E2712075EB05F4803C10F511B3E51074;
defparam prom_inst_1.INIT_RAM_08 = 256'hE8BB0EBBFBEBFB741373CA04C9027504C006FD048008F63C08EB08741348803C;
defparam prom_inst_1.INIT_RAM_09 = 256'hB3C2D7BBC120244575070C1DE9D30472E8BB707505F6C1E9CD00807175D30472;
defparam prom_inst_1.INIT_RAM_0A = 256'h898900E80BF624E8DCE6CD734FC8EB0A2648F8870398740404F302F63CF34077;
defparam prom_inst_1.INIT_RAM_0B = 256'hA58FB97501EBB4F3B10064E8B872743C3CED2E81F01C741F1EF3F9C3328A3207;
defparam prom_inst_1.INIT_RAM_0C = 256'h6169F000F0014558E0ED5AE884E004C3FA6800B3DF2549E73E10C310230A3DDD;
defparam prom_inst_1.INIT_RAM_0D = 256'hAE008F20B910060008E6B0B03CEFEF0301EFEF030000C00000004007FF657275;
defparam prom_inst_1.INIT_RAM_0E = 256'h28000006193B00FFC400C74AB420E3BFC9C700C74AB4F8061CF8060000068F75;
defparam prom_inst_1.INIT_RAM_0F = 256'h088051C380F605F30033B8121397C7BAFF090B00D000BB6900C74AB40074EB69;
defparam prom_inst_1.INIT_RAM_10 = 256'hEB535A400ABA03000052070110C2100000331F89CD0111CDEE13A28A03ECEC10;
defparam prom_inst_1.INIT_RAM_11 = 256'h00E7758A00EB10108BE72519006207E8B4605783535A58E0D45086180603800E;
defparam prom_inst_1.INIT_RAM_12 = 256'hA08AB2F8C0B9DAE8D9FDF6FACB93790326F7E3DB4E03B8472B60480D034EC1F7;
defparam prom_inst_1.INIT_RAM_13 = 256'h0A0807751858CD080757001E50F983C50E078787D951C3D86B335FC18D8107E8;
defparam prom_inst_1.INIT_RAM_14 = 256'hEBEAEAEAEAEBEAEAEAEAC38A8A0A875BC94A840152E636000000EAC30042010D;
defparam prom_inst_1.INIT_RAM_15 = 256'hF8EC8AEC50002006C02EF703A110BABAF54E7CB3B0EEC3BABA56F609EBEBEBEB;
defparam prom_inst_1.INIT_RAM_16 = 256'h8AEEC3C38A0272EBB0A2CF11A00303C3F342C860EEC58AC89200AA7543100060;
defparam prom_inst_1.INIT_RAM_17 = 256'hEFCBC16075FEB08A0300D24DEA156002750FA1FFB3EC9393BA61C9EEBAC35AE8;
defparam prom_inst_1.INIT_RAM_18 = 256'h24D2B98BBBED2E60302421EB1E1726AFC3A2EEC0DA7532322E8848904010756E;
defparam prom_inst_1.INIT_RAM_19 = 256'hEE0E802E001F770000C3CD48B003D80E0600F185E01049C80E0C8EAB7E6CF607;
defparam prom_inst_1.INIT_RAM_1A = 256'h1E08C401100450E2E845260002B4F6C131B00008060F80BB000B80000000ED2E;
defparam prom_inst_1.INIT_RAM_1B = 256'hE9E8E8E6000100608AC0AA07C0AB00C0AB03490113800003720808003CBEAB60;
defparam prom_inst_1.INIT_RAM_1C = 256'h5EDC9274EE2EE5C1EBEB762676FC08805500401F1FE8EDE8E8E8EDEAE9E8E9E9;
defparam prom_inst_1.INIT_RAM_1D = 256'hC3EBFAB986001FC1FDC90029805726A2EDFB26CD575726570857575708FE1F08;
defparam prom_inst_1.INIT_RAM_1E = 256'h8306E000B3B4C37405940003C1033FEAC08A61D4C8FF12B43FB4FAC0BDE4F600;
defparam prom_inst_1.INIT_RAM_1F = 256'hFF06FF00C7C75E008580E458011F568B044C8E6075F6EB08BDFE8BE0037648C1;
defparam prom_inst_1.INIT_RAM_20 = 256'h4A244242830004E90CE8515A4E4374C6EEF08303401EC302C71444C1C10E3F0A;
defparam prom_inst_1.INIT_RAM_21 = 256'h7C8A1F440682260E8C1EF0C32D0083F825F8028325F1C201E8C483A852864A59;
defparam prom_inst_1.INIT_RAM_22 = 256'h74FFEB1F26D2EF00EBF6530DC8E8A549000F4303002BD802C61333686893E812;
defparam prom_inst_1.INIT_RAM_23 = 256'hF9F672338306F500010EA3C2061E037584F46A0200743C727272743C72743C3C;
defparam prom_inst_1.INIT_RAM_24 = 256'h3206038A38F500007527054033FA64FB0CE701FF5AE824F9A704F652F30EEBAA;
defparam prom_inst_1.INIT_RAM_25 = 256'h02778284E872D80272F975EBC7F80272F9EBDF80F372E8508AC1B4E63EBB1BB4;
defparam prom_inst_1.INIT_RAM_26 = 256'hB08B82461C02FB3636000004361AF9111F0256083D7B03EF3E4840001000500A;
defparam prom_inst_1.INIT_RAM_27 = 256'h0EF8C70A58A003EB9788E300B401320880287F0A059280170C962CA81848891A;
defparam prom_inst_1.INIT_RAM_28 = 256'h010D203130733031332067692C617663646F4E004B018AFC18BE8EE600B4E8F4;
defparam prom_inst_1.INIT_RAM_29 = 256'h06601F6058330F1E00149EE881001FEA6E6C02F506A08B8B771F187C72006A00;
defparam prom_inst_1.INIT_RAM_2A = 256'h040CF8C774E4DAF8E80AF50200E4E4E852BA61C4FF5000120BBE88753A882C67;
defparam prom_inst_1.INIT_RAM_2B = 256'h001005E885F75200FF1E75BF2EF52E8F640496F704E8BCC3A8F8C775E4DA6064;
defparam prom_inst_1.INIT_RAM_2C = 256'h038B74518A683C7405B0FF06E8F6DCFF320BC78825E8F6E8E8C39090B4F404AC;
defparam prom_inst_1.INIT_RAM_2D = 256'hC68B038B74588A2B2C33FF7381F874D772E89C5E75FFE7C6048B75C4E8C68B8B;
defparam prom_inst_1.INIT_RAM_2E = 256'hFE1FBEFBE80356FF73B0E8FD0175ECE8FC80FED8E8E20283E6C7048B758BC4E8;
defparam prom_inst_1.INIT_RAM_2F = 256'h1F5A1433084DE88BB1FCE80A1FBE4064FC04E8EBFE17E81FBEFCFE162B75C6BE;
defparam prom_inst_1.INIT_RAM_30 = 256'h2D24201C14110E08050015153F15151500002A00000000007700004C00AA4800;
defparam prom_inst_1.INIT_RAM_31 = 256'h00000C0804002F1F3F3F1F1F3F2F001F3F00003F3F00103F1F003F3F00003832;
defparam prom_inst_1.INIT_RAM_32 = 256'h2A00000000002A00000015153F15151515153F15151500002A00000000002A00;
defparam prom_inst_1.INIT_RAM_33 = 256'h150015002A15000000002A0000001410040015153F15151515153F1515150000;
defparam prom_inst_1.INIT_RAM_34 = 256'h3F15151500153F00151515003F15001500003F00001515152A15150000152A00;
defparam prom_inst_1.INIT_RAM_35 = 256'h00000000430040001800150011000C000900040000002E0027003C3804001515;
defparam prom_inst_1.INIT_RAM_36 = 256'h650464187803631777016113731A7A11710000504B3F746C4A005753211E1D00;
defparam prom_inst_1.INIT_RAM_37 = 256'h6C0F6F09690B6B15750A6A0D6D19790767086802620E6E127214740666167605;
defparam prom_inst_1.INIT_RAM_38 = 256'h000000000000000000000000000000000000000000000000000000000010700C;
defparam prom_inst_1.INIT_RAM_39 = 256'h3800371E36003520200033003400320031006000090000000000000000000000;
defparam prom_inst_1.INIT_RAM_3A = 256'h007F081C5D1D5B0A0D005E1B40003A1F2D003B002F002F002E00390030002C00;
defparam prom_inst_1.INIT_RAM_3B = 256'h000000002A002D0000002B00001B1B0000000000000000000000000000000000;
defparam prom_inst_1.INIT_RAM_3C = 256'h000000000000000000000000000000000000000000005C00000000005C000000;
defparam prom_inst_1.INIT_RAM_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam prom_inst_1.INIT_RAM_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam prom_inst_1.INIT_RAM_3F = 256'hFF32315B00000000000000000000000000000000000000000000000000000000;

pROM prom_inst_2 (
    .DO({prom_inst_2_dout_w[23:0],dout[23:16]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_2.READ_MODE = 1'b0;
defparam prom_inst_2.BIT_WIDTH = 8;
defparam prom_inst_2.RESET_MODE = "SYNC";
defparam prom_inst_2.INIT_RAM_00 = 256'hE8E6F6E6E7E600BC30000D6364200072444D6369206F20322849505365613678;
defparam prom_inst_2.INIT_RAM_01 = 256'h7AC7503CC7482AC7406AC720F4C7F608FE8CC7F61F75043CC0BAA5B933686815;
defparam prom_inst_2.INIT_RAM_02 = 256'h646410B884000984820003C744444413107803ABC0FF1FF0C7C096C764FDC758;
defparam prom_inst_2.INIT_RAM_03 = 256'hB88AB00CE6C710E674ACAA13E315E873646400C63C071372F2AA13E323E8FBE8;
defparam prom_inst_2.INIT_RAM_04 = 256'h6E3C0A7465732019DBB8E3E80610B6BE00133AE894E813000046021403E7A170;
defparam prom_inst_2.INIT_RAM_05 = 256'h07C51E2048203648202020527374334D53387A31313A0A367965643220203961;
defparam prom_inst_2.INIT_RAM_06 = 256'hF63C8B8B406058EB747574E4FB0400000D3F1800016C6A580803C075C7C0803C;
defparam prom_inst_2.INIT_RAM_07 = 256'h0175EB0563803CC102F674FF1206E9FC8075EB05EB803CC9E0E940EB00807514;
defparam prom_inst_2.INIT_RAM_08 = 256'h05100140FE628008F63C04EB0474130174193381E280C19102378008F63CE2D9;
defparam prom_inst_2.INIT_RAM_09 = 256'h0203339902757F0B7CF200FB8B807422C520E806F6C202A31BA300003EF67421;
defparam prom_inst_2.INIT_RAM_0A = 256'h0E16E8B40CC507048AF71604F98A14A219780A35D8C102F67402B3C22502740A;
defparam prom_inst_2.INIT_RAM_0B = 256'hB1E609F401CF00AB76F3E65100372401055EFFE6C177168056C37580E6E6F81F;
defparam prom_inst_2.INIT_RAM_0C = 256'h6563088B0278539D072C586CFF078A8350E5EB81B774008087EBB4EB868D026B;
defparam prom_inst_2.INIT_RAM_0D = 256'h00C9C70700BB4C50C74200B60640B8EF00B2B8B850D0D060F0B00007FF00616D;
defparam prom_inst_2.INIT_RAM_0E = 256'h8F00C74AB43CEFEF03A0060001BF3C28F90640060001BF6975EB6900C74AB419;
defparam prom_inst_2.INIT_RAM_0F = 256'h96FFF3967506CDABB9C018EFEF8AB0D450403C50E880000000060001BF031E00;
defparam prom_inst_2.INIT_RAM_10 = 256'h078A588A8AD4C910F6896100B0C0B00E8BDBB80010B9CD10B8EEA1C4B058BA3C;
defparam prom_inst_2.INIT_RAM_11 = 256'hC18B02400213B8B4B48AB83C3C008AFC000050E3C15BB0B00303C65262753E89;
defparam prom_inst_2.INIT_RAM_12 = 256'h00C35050868AF706036007FEF3B0F3FAA58A727400FF0700CA06EFEF8A00E0E3;
defparam prom_inst_2.INIT_RAM_13 = 256'h747474F800C31000B45003625359C3FF5358FBFBFF8A5003C0C050EB87E35B04;
defparam prom_inst_2.INIT_RAM_14 = 256'h9B311B9B9B9B189B9BAC9C3E260600EBCD000006B7FE84FEEBEB01EB733A0074;
defparam prom_inst_2.INIT_RAM_15 = 256'h584AC3BABA613089E0A23232E6EEC0DA61FE0F0F0061EEC0DACA2E8B3CAD9B9B;
defparam prom_inst_2.INIT_RAM_16 = 256'hE042BA50C7B0030C10A1D002A184EC60266B038B5AEEC4038AC361F3808AB08B;
defparam prom_inst_2.INIT_RAM_17 = 256'h5103E992D9C310EED66B978A08CD8AC303C0E62E1493BA5AC6C30342C7608AEC;
defparam prom_inst_2.INIT_RAM_18 = 256'h1006002E00EB8BBB747674743CA8A8A8A8A158030311C7C7A03EA2011F74F659;
defparam prom_inst_2.INIT_RAM_19 = 256'h088BFF0C72C40E808A8B10BD21BD3C07B9614800017400000101DE1EC37C8E61;
defparam prom_inst_2.INIT_RAM_1A = 256'h7900747761B4A8E88B898A742609FFEE6000B03089F6FB03838AFBC8DCBA0E8B;
defparam prom_inst_2.INIT_RAM_1B = 256'h59C0AD5800EF000DC4F3B1ABE8A024AB93BB0003743EB874140200F312498CB8;
defparam prom_inst_2.INIT_RAM_1C = 256'h088B00001FFFFEED14140880108074366A1F1FCFA11E815757573C3E445757A6;
defparam prom_inst_2.INIT_RAM_1D = 256'h8AE98001DF0880E2C1748B8BFAEFF0EFEEEEF0EEEFEFF0EFEFEFEFEFEFEECFF6;
defparam prom_inst_2.INIT_RAM_1E = 256'hDA830A8B000780988000C3C13ECA8308ECC58C03F7D500007404807469F6EBC3;
defparam prom_inst_2.INIT_RAM_1F = 256'h00C703C74404088B50FA041A442BFF548B025F8BB48003BD6433C80686033D3E;
defparam prom_inst_2.INIT_RAM_20 = 256'h321F428AC2037405804A8A1F744E0DC142ECC2F61F52B458448912E8648900C7;
defparam prom_inst_2.INIT_RAM_21 = 256'h1A7C8A1C1F00D41716600000F402C00CFF0C33F8FF75FB7452EEC2208AE08A5A;
defparam prom_inst_2.INIT_RAM_22 = 256'h34803807D4F02EEFBCE8FF850B7473D174F7A4C891C8838B3BDBDB0000E8B5E8;
defparam prom_inst_2.INIT_RAM_23 = 256'h5B0707DB6A531FCD889E9C839A98E722260140008665C2090C116B881D298380;
defparam prom_inst_2.INIT_RAM_24 = 256'hE46772E0E702EB8C893C72743C7258B010503C8A1F87EF9C0375066AEB07A8B8;
defparam prom_inst_2.INIT_RAM_25 = 256'hE79A805A988BE87297E81FA5A2F672B3E8E953FF02CBFAB4A7EB028068AA03F6;
defparam prom_inst_2.INIT_RAM_26 = 256'h0136004600005E1C1AEB898B8200FACDCFB03C3C3C3C727440A81F1E44FC6414;
defparam prom_inst_2.INIT_RAM_27 = 256'h077324FB3897B7C000013272185BDBB40E00B4DF8052FC000A00840400EB3600;
defparam prom_inst_2.INIT_RAM_28 = 256'h020A2E30302C30313252207420626165656F6F017588DCE80100D842F0E6B8E8;
defparam prom_inst_2.INIT_RAM_29 = 256'h678BB41E1FC0809800C600032E01F61E0000001F70700E1612801E00057C00BA;
defparam prom_inst_2.INIT_RAM_2A = 256'hB08473240B6403C3E4E481D0EC424202FADACF085CACACFB44A33E21069C0300;
defparam prom_inst_2.INIT_RAM_2B = 256'hB45A30F1C036330026E3F68384BB8906C3B000C33CDCFF1A2073240A64035A8A;
defparam prom_inst_2.INIT_RAM_2C = 256'hB4F40183C227F6F580FF3300BBDB472ADBC00265E8DFC3E9EDD1909001C3CD0A;
defparam prom_inst_2.INIT_RAM_2D = 256'h44E9B4F40183C2C3FFC0EB05FF0E1183034FE8FF29800F8E8CC74106C044E9FB;
defparam prom_inst_2.INIT_RAM_2E = 256'hCCE8FFB49BB9571EF9FEB3E874C673C704E4E8FEEAFEB0FD0F8E8CC6CADD064C;
defparam prom_inst_2.INIT_RAM_2F = 256'hC38BFEC041F63FFC12FE7EE4E80B58FE162B95BEFEF863E81DAA581FE166FE05;
defparam prom_inst_2.INIT_RAM_30 = 256'h2D28201C18110E0B05003F3F15153F152A2A00002A0000FF0000FF0000870000;
defparam prom_inst_2.INIT_RAM_31 = 256'h2A000D0905013F371F373F1F003F3F00103F10003F3F00003F2F002F3F003F32;
defparam prom_inst_2.INIT_RAM_32 = 256'h00002A002A2A00002A003F3F15153F153F3F15153F152A2A00002A002A2A0000;
defparam prom_inst_2.INIT_RAM_33 = 256'h2A152A3F00003F002A2A00002A00151105013F3F15153F153F3F15153F152A2A;
defparam prom_inst_2.INIT_RAM_34 = 256'h15153F153F2A15152A153F3F00153F003F2A00152A002A3F15003F152A2A1500;
defparam prom_inst_2.INIT_RAM_35 = 256'h00004700445E1A3D3B3A3800120E0D353306050001002F2B284F3D3905013F3F;
defparam prom_inst_2.INIT_RAM_36 = 256'h1220202D2D2E2E11111E1E1F1F2C2C10100000514C4575705A002454221F001B;
defparam prom_inst_2.INIT_RAM_37 = 256'h26181817172525161624243232151522222323303031311313141421212F2F12;
defparam prom_inst_2.INIT_RAM_38 = 256'h3C5E3B603D623F8F4C844976518D48744D9150935392527747734B754F191926;
defparam prom_inst_2.INIT_RAM_39 = 256'h09000807070006393900040005030300020029940F613E6340654267448A865F;
defparam prom_inst_2.INIT_RAM_3A = 256'h4F0E0E2B1B1B1A1C1C00071A0300270C0C002795E000350034000A000B003300;
defparam prom_inst_2.INIT_RAM_3B = 256'h46844996378E4A7651904E898501018D48744D66439150935392527747734B75;
defparam prom_inst_2.INIT_RAM_3C = 256'h000000000000000000000000000000000000000000002B00000000002B644146;
defparam prom_inst_2.INIT_RAM_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam prom_inst_2.INIT_RAM_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam prom_inst_2.INIT_RAM_3F = 256'hFF2F35E000000000000000000000000000000000000000000000000000000000;

pROM prom_inst_3 (
    .DO({prom_inst_3_dout_w[23:0],dout[31:24]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd})
);

defparam prom_inst_3.READ_MODE = 1'b0;
defparam prom_inst_3.BIT_WIDTH = 8;
defparam prom_inst_3.RESET_MODE = "SYNC";
defparam prom_inst_3.INIT_RAM_00 = 256'h3FA1D04007439D0000FA0A74654B506420426874446C4E30434F436F6F6D2074;
defparam prom_inst_3.INIT_RAM_01 = 256'hF10600EE0600EE0600E30600E20689F3004C04BF1EF3060CEF80E800F6000000;
defparam prom_inst_3.INIT_RAM_02 = 256'hB9B0B0039671C787001E8344601C1A802403C7C7B1331EF40601F40600F30600;
defparam prom_inst_3.INIT_RAM_03 = 256'h00C46003641300640913757210B1D9FBE8B0B00683E83C0EE875721EB115B403;
defparam prom_inst_3.INIT_RAM_04 = 256'h6720006574654D50CD0500A9BE00134710F6E0B000D1BEE00E1572D03301E6E6;
defparam prom_inst_3.INIT_RAM_05 = 256'h435E55004420627A3744314129203248204D2038382043332064692032764B6E;
defparam prom_inst_3.INIT_RAM_06 = 256'hC5FA0E161F1E5B0204F60E64500100C7C7B07583830040CF5DC3E80200223FD8;
defparam prom_inst_3.INIT_RAM_07 = 256'hEB055A803CCA12020CC1EEFFEA721E0CE418E2803CC9E10275C18003E8E40CF6;
defparam prom_inst_3.INIT_RAM_08 = 256'h017E7358EB81E280C19401798008F63C1200C0E2F7E10275EB81CA80C111FE75;
defparam prom_inst_3.INIT_RAM_09 = 256'h3C74DBFA756FF6EB26AEFC5100CE05F60077CCBBC2037500331CA380C6C745F6;
defparam prom_inst_3.INIT_RAM_0A = 256'h9617EAED40587432C28059B4CDC45119001F77FB2EE0B3C202F6022077EB13F6;
defparam prom_inst_3.INIT_RAM_0B = 256'h77F30051B481B05F332EB95701743C72741F94FEEE0E80FC6AFB02FF320A7561;
defparam prom_inst_3.INIT_RAM_0C = 256'h206F00E600E641CB920A9D0F750492E052E5ADC30006808A00C900D1E08702C3;
defparam prom_inst_3.INIT_RAM_0D = 256'h3CF906BF4000000006B8E6E677EF07B0EFCE0402BA0E1606803C004099016369;
defparam prom_inst_3.INIT_RAM_0E = 256'hC7000600412658B8B8504C50C728245D3C69EB4C50C72800193F0020060011BF;
defparam prom_inst_3.INIT_RAM_0F = 256'h40A0AB33168710B808BFFF58B8E012031E800351A233A029C74C50C750E93C29;
defparam prom_inst_3.INIT_RAM_10 = 256'h83C7C3E1E503FE74060EC3CD1300020716B91208F60710B814B0E6EE10BADA08;
defparam prom_inst_3.INIT_RAM_11 = 256'hEBA1B03CC7B8000203400A0313A0F80CC35B8B0EEB580E0F50C26B33001E4957;
defparam prom_inst_3.INIT_RAM_12 = 256'hC3692A03C6D8DE00CA0661CFAB2002FE03C80F13910302684187618AE3BA028B;
defparam prom_inst_3.INIT_RAM_13 = 256'h22181A5108F75AB40AC1DB00525B028851C359F31EE306DB50868E070000C300;
defparam prom_inst_3.INIT_RAM_14 = 256'hEAEBEBEAEAEAEBEAEAEAEA624A4924CC104A8A8A07CE00C6F0F480FC1016CD18;
defparam prom_inst_3.INIT_RAM_15 = 256'h5AEEEEC0DAC3060002A1C3C3C02E0303C3CBCD268BC38A0303C3FFF01BEBEBEA;
defparam prom_inst_3.INIT_RAM_16 = 256'hEC42C752EE14C002EEE6D8C0E6DBBABA6EC993F2588AEEEEC350C3B0FBC707FA;
defparam prom_inst_3.INIT_RAM_17 = 256'hF38B108761FECD8A03C900D56B10F9E3C0EB808AE85AC6C30352F342038BF48A;
defparam prom_inst_3.INIT_RAM_18 = 256'hCD0E011110092E007A60373020EBEDEEEFE6EEB0EC50A80CA18584F650316140;
defparam prom_inst_3.INIT_RAM_19 = 256'h03F30701182E6AFF160E0700CD0023BD08C3A299890313801F8C8933608CDEC3;
defparam prom_inst_3.INIT_RAM_1A = 256'hED2E030CC302018FFC545E058A5074088BC3120600D83100E10E1000000007AC;
defparam prom_inst_3.INIT_RAM_1B = 256'hE9E8E8E8000C0400C3AB06B004872FA0AB080D800D49000FBBB0ABA4B900C8E0;
defparam prom_inst_3.INIT_RAM_1C = 256'hD0EC0880889601078BB4B4FC80FC139240CFA11E106AEDE8E8E8EDECEAE8E8E9;
defparam prom_inst_3.INIT_RAM_1D = 256'h26B47500B4EB360AE91FD10E80D9269DA75726FB57575726570D6657030DFBDC;
defparam prom_inst_3.INIT_RAM_1E = 256'h00E8C1D0A175FAB4FA008383F749E16B068AD88ED959595018F675E7F6EB08BD;
defparam prom_inst_3.INIT_RAM_1F = 256'h89448944021A33ECA18007E40244D50A44C41ADC06FABDE4F6C0BA0CC4B8FEF7;
defparam prom_inst_3.INIT_RAM_20 = 256'hC0EE8AC4FDD305B8EE4AC8CF33744EEE4224038B8B5601B4186C890610448944;
defparam prom_inst_3.INIT_RAM_21 = 256'h8B175C8AFCE3F02ED2FA0000017206720175C0120125ECFBEC5AFB74E0EBE042;
defparam prom_inst_3.INIT_RAM_22 = 256'h86FCE932F02E8E48B84D4AFFC30401E902C649337983D3C7C742032010B0FFBB;
defparam prom_inst_3.INIT_RAM_23 = 256'h0780F4CD4AB8EB70260000D1000070B8A0741FCFFBF572743C3C3C72743C7272;
defparam prom_inst_3.INIT_RAM_24 = 256'hEB00A4E8732A15061E06635D031C3CADE6E407C4E903E6E4E61610409FBB3360;
defparam prom_inst_3.INIT_RAM_25 = 256'hEBB4FF50028A9F92E8C5B48468D8AEE8E1B4B403EBF902F3010877FF000072F9;
defparam prom_inst_3.INIT_RAM_26 = 256'h3B80723B898B1F0000E0363600AD8B16F42492120905781CFCEF86560000C828;
defparam prom_inst_3.INIT_RAM_27 = 256'hBEEC08ECE000C8BAF780DB07E872E8F397720080E3C005EBE0808A7424B01C74;
defparam prom_inst_3.INIT_RAM_28 = 256'hB9002E303020623520536F69776C692076742000F724E812FA018EE7E64301F9;
defparam prom_inst_3.INIT_RAM_29 = 256'h00D8006ACFE75B00530600839C74066AF98989FB00006E6C74FC6A00EACD0780;
defparam prom_inst_3.INIT_RAM_2A = 256'hD4DBF108ECA8B7524242E9DCC0E80272EC03B407F9505006FC0067B368A4778B;
defparam prom_inst_3.INIT_RAM_2B = 256'h0EC30EFF74FCD200E1F52EEB9F001EE1CFAE10F6FAFF72DBE4F108ECA8B7C3C4;
defparam prom_inst_3.INIT_RAM_2C = 256'h01BA42F950F6EBC3FC46F6E8FF5BE225E8C3E201DAFFD1FFFFE99090EEB010C0;
defparam prom_inst_3.INIT_RAM_2D = 256'h051601BA42F950C38BEFF7E8D01FBEFD4BFF52D6B5FCE8D8DEC1060AFF05168B;
defparam prom_inst_3.INIT_RAM_2E = 256'h75D3F701FE0ABA51E9D0FEB88983F9FE750ED2E8FEB5FC01B0D8DFC1060A8BFF;
defparam prom_inst_3.INIT_RAM_2F = 256'h40C15FEF8BC1FE162B75FE757CF874581FE1FE23CCE8FEA8F87558E88BB1FEF8;
defparam prom_inst_3.INIT_RAM_30 = 256'h2D28241C18140E0B08003F3F153F15152A2A002A0000007A0000690000490000;
defparam prom_inst_3.INIT_RAM_31 = 256'h00000E0A06021F3F3F1F2F3F10003F3F00003F1F002F3F00003F3F001F3F3F38;
defparam prom_inst_3.INIT_RAM_32 = 256'h002A00002A2A002A00003F3F153F15153F3F153F15152A2A002A00002A2A002A;
defparam prom_inst_3.INIT_RAM_33 = 256'h00002A2A152A00152A2A002A0000161206023F3F153F15153F3F153F15152A2A;
defparam prom_inst_3.INIT_RAM_34 = 256'h153F15153F3F003F15002A3F152A15152A3F002A15003F2A153F00153F2A003F;
defparam prom_inst_3.INIT_RAM_35 = 256'h480000450042413E3C163913370F360A340732023100302C29003E3A14023F3F;
defparam prom_inst_3.INIT_RAM_36 = 256'h45004400580043005700410053005A00510000554D497A71690059235220005B;
defparam prom_inst_3.INIT_RAM_37 = 256'h4C004F0049004B0055004A004D0059004700480042004E005200540046005600;
defparam prom_inst_3.INIT_RAM_38 = 256'h0000000000000006350A390433093807360332002E0130083705340231005000;
defparam prom_inst_3.INIT_RAM_39 = 256'h2800270026002520200023002400220021007E00000000000000000000000000;
defparam prom_inst_3.INIT_RAM_3A = 256'h000008007D007B000D007E0060002A003D002B002F003F003E00290000003C00;
defparam prom_inst_3.INIT_RAM_3B = 256'h000000002A002D0000002B0000001B0000000000000000000000000000000000;
defparam prom_inst_3.INIT_RAM_3C = 256'h000000000000000000000000000000000000000000005F00000000007C000000;
defparam prom_inst_3.INIT_RAM_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam prom_inst_3.INIT_RAM_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam prom_inst_3.INIT_RAM_3F = 256'h00312F0000000000000000000000000000000000000000000000000000000000;

endmodule //Gowin_pROM_bios
