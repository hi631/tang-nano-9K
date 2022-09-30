//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.03
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Mon Sep 19 09:57:48 2022

module Gowin_pROM_inst (dout, clk, oce, ce, reset, ad);

output [19:0] dout;
input clk;
input oce;
input ce;
input reset;
input [10:0] ad;

wire [23:0] prom_inst_0_dout_w;
wire [23:0] prom_inst_1_dout_w;
wire [27:0] prom_inst_2_dout_w;
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
defparam prom_inst_0.INIT_RAM_00 = 256'h10D15A864AFFCCA2BF232010008C5882D104434F87434F874600524747040058;
defparam prom_inst_0.INIT_RAM_01 = 256'h91FE8485103C2042144228422C10D1CCAF4987498749874987A2BF460C104224;
defparam prom_inst_0.INIT_RAM_02 = 256'h9A5A8C525A2BC94F5A8F8A379A5A018A4F5A8F8A339A5AF08AD1CCA2BF464445;
defparam prom_inst_0.INIT_RAM_03 = 256'h33952BF08A3B9A4A8C524A2BC94F4A8F8A379A4A018A4F4A8F8A339A4AF08A3B;
defparam prom_inst_0.INIT_RAM_04 = 256'h8A3B951A008C520A2B37950A018A33950AF08A3B953E008C522E2B37952B018A;
defparam prom_inst_0.INIT_RAM_05 = 256'h426A82426A825888AA336AA48A52104A82524A82588A52104A5252F052104AF0;
defparam prom_inst_0.INIT_RAM_06 = 256'h8A339A6AF08A425A82425A825888AA335AA48A424B82424B825888AA334BA48A;
defparam prom_inst_0.INIT_RAM_07 = 256'h2E2B52952B018A52952BF08A3B9A6A8C526A2BC94F6A8F8A379A6A018A4F6A8F;
defparam prom_inst_0.INIT_RAM_08 = 256'hAB5884C184445A8084445A8484E3B9AB5884B48417E3AB84A08452953E008C52;
defparam prom_inst_0.INIT_RAM_09 = 256'h01815212819A585258126B9A58F04044588444445884E3D3AB5884CE842EE3C6;
defparam prom_inst_0.INIT_RAM_0A = 256'h3A47003A3E003A478F3BD53C52003C001237D53C000133D53C00F07401749A58;
defparam prom_inst_0.INIT_RAM_0B = 256'h7A527A12379A7A01339A7AF04F013B953C52002C1237952C0133952CF0500000;
defparam prom_inst_0.INIT_RAM_0C = 256'h8A40905840905840905840580A8080AF49814980B33133D0CE00F0C94F013B9A;
defparam prom_inst_0.INIT_RAM_0D = 256'h874487C1C1318A405A404BB79A588000DF52C04887ADADDB8A52C04487A5A531;
defparam prom_inst_0.INIT_RAM_0E = 256'h58525812529A5801529A58F0409A31520080DF52C048874887CBCBDB8A52C044;
defparam prom_inst_0.INIT_RAM_0F = 256'h52C047844784FEFE318ADFE85200C04731470084F1F1318A335A809A58F0529A;
defparam prom_inst_0.INIT_RAM_10 = 256'h81814382438341854185428143814343904182418349498181B38A428858DFF6;
defparam prom_inst_0.INIT_RAM_11 = 256'h4581AA31304F85B3421C02AF44854585B3C9304F85B3C9284F8A41418E8E4E4E;
defparam prom_inst_0.INIT_RAM_12 = 256'h0A018833950AF08845814580314218525242185200524B2B4F9A84013E314480;
defparam prom_inst_0.INIT_RAM_13 = 256'h37952B018833952BF088411A008100410A81883B951A0052000A8C124C883795;
defparam prom_inst_0.INIT_RAM_14 = 256'h527A4009808A9B3EFF3E0097413B008100412B81883B953E0052002E8C124C88;
defparam prom_inst_0.INIT_RAM_15 = 256'h33C044C044449A310088528A52B588A9AAB18485444590B18485B1A98A84859A;
defparam prom_inst_0.INIT_RAM_16 = 256'h4AF0520A4AF0522E06D93B024A0F524A0F5245D0CE623D44D0CE84809A5A84F0;
defparam prom_inst_0.INIT_RAM_17 = 256'h048484375802019A5A84525A84123BF283F29A5A840137EA44EA58032E60E52E;
defparam prom_inst_0.INIT_RAM_18 = 256'h002C3184842C29375802010C5252898A14045252E00BE049004B4A0244449214;
defparam prom_inst_0.INIT_RAM_19 = 256'h2BF08444952B84F04444922C121404523C52002C238484444492121404523C52;
defparam prom_inst_0.INIT_RAM_1A = 256'h684D44D53B00848037952B018444952B840145D53B00623D44D53B0084803395;
defparam prom_inst_0.INIT_RAM_1B = 256'hD53B008480443B0084803B953E0084522E841244953B0084442B841241D53B00;
defparam prom_inst_0.INIT_RAM_1C = 256'h2B84F09412453B0085452B855231000141D5453B000BDF89883B00898807DB44;
defparam prom_inst_0.INIT_RAM_1D = 256'h9A6A84F052953B0085522B855231000152953B0084522B841252952B84015295;
defparam prom_inst_0.INIT_RAM_1E = 256'h0BDF8584858407DB3B9A6A84526A841252952B6505379A6A840152952B5FF433;
defparam prom_inst_0.INIT_RAM_1F = 256'h4A0F524A0F5245D0FA623D44D0FA84809A4A84F033EC44ECB41252953B00522B;
defparam prom_inst_0.INIT_RAM_20 = 256'h4A8401371D441D525203182B52A00A4AF0520A4AF05252520A10092B520A1A02;
defparam prom_inst_0.INIT_RAM_21 = 256'h848481819A4A84524A84123B358335454541418585818144444040848480809A;
defparam prom_inst_0.INIT_RAM_22 = 256'h2C64522C615801848A8B5252F053C0004B4A0049449A5844584C018444444141;
defparam prom_inst_0.INIT_RAM_23 = 256'h8345D51A00623D44D51A008480950A84F0336F446F449A3C00442C4C2C465246;
defparam prom_inst_0.INIT_RAM_24 = 256'h80951A0084520A84123B97839741D51A00684D44D51A008480950A8401378344;
defparam prom_inst_0.INIT_RAM_25 = 256'h450A855231000141D5451A000BDF89881A00898807DB44D51A008480441A0084;
defparam prom_inst_0.INIT_RAM_26 = 256'h088880DF84809C09C0D80A8880D584809C09C0CE0A8880CB8480BD12451A0085;
defparam prom_inst_0.INIT_RAM_27 = 256'h80000A8880FD84809C0580F60A8880F384809C09C0EC0A8880E984809C09C0E2;
defparam prom_inst_0.INIT_RAM_28 = 256'h9909C01E0A88801B84809C0980140A88801184809C09800A0888800784809C09;
defparam prom_inst_0.INIT_RAM_29 = 256'h84809909C03C0A88803984809909C0320888802F84809909C0280A8880258480;
defparam prom_inst_0.INIT_RAM_2A = 256'h806184809909805A088880578480990980500A88804D8480990580460A888043;
defparam prom_inst_0.INIT_RAM_2B = 256'h809409C07D0A8880807A8480809409C071880A80806F840A8080990980640A88;
defparam prom_inst_0.INIT_RAM_2C = 256'hA10A8880809E84808094C009950A888080928480809409C08908888080868480;
defparam prom_inst_0.INIT_RAM_2D = 256'hC4840A8080940980B908888080B6848080940980AD0A888080AA848080940580;
defparam prom_inst_0.INIT_RAM_2E = 256'h958000013799C000013799C000013799C000013799C00001948009C6880A8080;
defparam prom_inst_0.INIT_RAM_2F = 256'hFC80F680F280ED80E3DF84DB80DB308D37998000013799800001379980000137;
defparam prom_inst_0.INIT_RAM_30 = 256'h528888DBDF8484DB5EDB8282508D80FC80F680F280ED80E3DF84DB80DB408D80;
defparam prom_inst_0.INIT_RAM_31 = 256'h708DCA9A5240413A8044413670608D8C124C8A4C8A5EFC5EF65EF25EED5EE3DF;
defparam prom_inst_0.INIT_RAM_32 = 256'h07DF484852DBDF4444DB9ADB4242908D40E3DF44DB40DB808D40E3DF44DB40DB;
defparam prom_inst_0.INIT_RAM_33 = 256'h180B4507410745314500B08E41180B45074107A08E0B89070B85070B89070B85;
defparam prom_inst_0.INIT_RAM_34 = 256'h8A1A00319F520A008A1A0031520A00880B494952070B454507CA074646C08E41;
defparam prom_inst_0.INIT_RAM_35 = 256'hBB4F834F834E834E83428343834382438349854984B3AF498F49854984B31A00;
defparam prom_inst_0.INIT_RAM_36 = 256'h80418140819081814660448745874F5A004AFF8F58C5BB438E438E438F438FB7;
defparam prom_inst_0.INIT_RAM_37 = 256'h908684854041908A8485408A418A404131008A40419752D8864041D88A418141;
defparam prom_inst_0.INIT_RAM_38 = 256'h975204864243048A428A438A424331008A458345824385428590858540419752;
defparam prom_inst_0.INIT_RAM_39 = 256'hDF88DB8AFFFDFBF980E7F73DF4F2008242439752908684854243908A84854243;
defparam prom_inst_0.INIT_RAM_3A = 256'h80848A8A292725235EE7211C18161414DF88DB8A100E0C0A80E7084D05038282;
defparam prom_inst_0.INIT_RAM_3B = 256'hDF48DB40ED40F27B40E7457D4240004200000000FCF6F2ED00E7E3DBDBDB0000;
defparam prom_inst_0.INIT_RAM_3C = 256'h9AED9AE34044F29E9AE79C5A56545252DF48DB40ED40F28B40E74E8D4B490042;
defparam prom_inst_0.INIT_RAM_3D = 256'h0B4907410F4114BB411C7FBD7C7A76460B4907410F4114AB411C72AD6F6D0044;
defparam prom_inst_0.INIT_RAM_3E = 256'h00000000000000000000585858585858CA0FCA18414514CECA1CCC8B87858383;
defparam prom_inst_0.INIT_RAM_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

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
defparam prom_inst_1.INIT_RAM_00 = 256'hE0E634543420E6E6E600D0B8F0540405E6273404553505553400340405000004;
defparam prom_inst_1.INIT_RAM_01 = 256'hE6FF545400E000E000E000E000E0E6E6E63554355435543554E6E63400E0E000;
defparam prom_inst_1.INIT_RAM_02 = 256'h083A554436E6E634345455E60836E65530305055E60832E555E6E6E6E6343434;
defparam prom_inst_1.INIT_RAM_03 = 256'hE60A32E555E6083A554436E6E634345455E60836E65530305055E60832E555E6;
defparam prom_inst_1.INIT_RAM_04 = 256'h55E60A3A10554436E6E60A36E655E60A32E555E60A3A10554436E6E60A36E655;
defparam prom_inst_1.INIT_RAM_05 = 256'h3539553435545454E0E631E05534083B5534375454553408335454E5340833E5;
defparam prom_inst_1.INIT_RAM_06 = 256'h55E60832E5553539553435545454E0E631E0553539553435545454E0E631E055;
defparam prom_inst_1.INIT_RAM_07 = 256'h36E6340836E655340832E555E6083A554436E6E634345455E60836E655303050;
defparam prom_inst_1.INIT_RAM_08 = 256'hE05450E0503434595D3534595DE6E0E05450E050E1E6E050E05034083A105534;
defparam prom_inst_1.INIT_RAM_09 = 256'hE6E644E6E6080A4406E6E60802E5393D5454393D5455E6E0E05450E050E1E6E0;
defparam prom_inst_1.INIT_RAM_0A = 256'h01E60001E60001E654E60A0A44100620E6E60A0620E6E60A0220E5E6E6E60806;
defparam prom_inst_1.INIT_RAM_0B = 256'h0A4406E6E60806E6E60802E530E6E60A0A441006E6E60A06E6E60A02E5E60000;
defparam prom_inst_1.INIT_RAM_0C = 256'h5530080234080635080A3406085554E635543554E6E6E608E200E5E634E6E608;
defparam prom_inst_1.INIT_RAM_0D = 256'h5435554901E6553434343491080254FFE6344435544901E655344435544901E6;
defparam prom_inst_1.INIT_RAM_0E = 256'h0A3406E6340806E6340802E5350854345056E63444355535544901E655344435;
defparam prom_inst_1.INIT_RAM_0F = 256'h3444345535554901E655E6E134084435543450554901E655E630000802E53408;
defparam prom_inst_1.INIT_RAM_10 = 256'h54553454355434553555345434553435E60454055435355455E605E05404E6E1;
defparam prom_inst_1.INIT_RAM_11 = 256'h3454E6E6E23055E6E0008AE634553455E6E6E23455E6E6BA3455353454553534;
defparam prom_inst_1.INIT_RAM_12 = 256'h36E654E60A32E55435543454E6E0003434E0003409343236920856E6E2E63454;
defparam prom_inst_1.INIT_RAM_13 = 256'hE60A36E654E60A32E554353A10550034365454E60A3A0044103654E63454E60A;
defparam prom_inst_1.INIT_RAM_14 = 256'h340604045405AAE600E600A2353A10550034365454E60A3A0044103654E63454;
defparam prom_inst_1.INIT_RAM_15 = 256'hE6E230E23435085450563405341A56E2E6E254543434E6E25454AAE205545412;
defparam prom_inst_1.INIT_RAM_16 = 256'h3400443434004434002A36243400543400543108E2E6E73008E25050083250E5;
defparam prom_inst_1.INIT_RAM_17 = 256'hE35455100608E6083A55443654E6E6E2E6E2083654E6E6E234E2060634002A36;
defparam prom_inst_1.INIT_RAM_18 = 256'h10062B5457042B100608E60834345654830834344A034A040034340835340883;
defparam prom_inst_1.INIT_RAM_19 = 256'h32E550300A3250E5353408062383E3440A4410062B54573534082383E3440A44;
defparam prom_inst_1.INIT_RAM_1A = 256'hE6E7340A36205454E60A36E654340A3654E6310A3220E6E7300A32205050E60A;
defparam prom_inst_1.INIT_RAM_1B = 256'h0A3A1055553436205454E60A3A1055443654E6350A3A1055343654E6350A3620;
defparam prom_inst_1.INIT_RAM_1C = 256'h3250E5E3E635381055343654445450E6350A353A10E7E6555536205555E7E635;
defparam prom_inst_1.INIT_RAM_1D = 256'h083250E534083A1055343654445450E634083A1055343654E634083654E63408;
defparam prom_inst_1.INIT_RAM_1E = 256'hE7E655555555E7E6E6083A55443654E6340836E6E6E6083654E6340832E6E5E6;
defparam prom_inst_1.INIT_RAM_1F = 256'h3600543400543108E3E6E73008E35050083250E5E6E330E3E3E634083A103436;
defparam prom_inst_1.INIT_RAM_20 = 256'h3654E6E6E434E436440624365400343400443434004434443400243654003424;
defparam prom_inst_1.INIT_RAM_21 = 256'h54555455083A55443654E6E6E4E6E43534353454555455353435345455545508;
defparam prom_inst_1.INIT_RAM_22 = 256'h042C46042C06E65454543434480448080404003435080A3406E4E65435343534;
defparam prom_inst_1.INIT_RAM_23 = 256'hE4310A3220E6E7300A322050500A3250E5E6E430E435080A103406E4042C46E4;
defparam prom_inst_1.INIT_RAM_24 = 256'h540A3A1055443654E6E6E4E6E4350A3620E6E7340A362054540A3654E6E6E434;
defparam prom_inst_1.INIT_RAM_25 = 256'h343654445450E6350A353A10E7E6555536205555E7E6350A3A10555534362054;
defparam prom_inst_1.INIT_RAM_26 = 256'h205450E45450E10A420C085450E45450E14A420C685450E45450E4E635381055;
defparam prom_inst_1.INIT_RAM_27 = 256'h420D085450E45450E10A420C085450E45450E140420C605450E45450E11A420C;
defparam prom_inst_1.INIT_RAM_28 = 256'hE152460D705454E55454E148420D685450E55450E11A420D205450E55450E10A;
defparam prom_inst_1.INIT_RAM_29 = 256'h5454E140460D605454E55454E11A460D205454E55454E10A460D085454E55454;
defparam prom_inst_1.INIT_RAM_2A = 256'h54E55454E11A460D205454E55454E10A460D085454E55454E10A460D085454E5;
defparam prom_inst_1.INIT_RAM_2B = 256'h55E10A4A0D08545455E5545455E1724A0D54705455E554705455E150460D7054;
defparam prom_inst_1.INIT_RAM_2C = 256'h0D08545455E5545455E14A400D60545455E5545455E11A4A0D20545455E55454;
defparam prom_inst_1.INIT_RAM_2D = 256'hE554705455E11A4A0D20545455E5545455E10A4A0D08545455E5545455E10A4A;
defparam prom_inst_1.INIT_RAM_2E = 256'h0A4608E6E6084640E6E60A4620E6E60A4608E6E60A4650E6E14A700D54705455;
defparam prom_inst_1.INIT_RAM_2F = 256'hE651E651E651E651E6E651E651E6F754E6084650E6E60A4620E6E60A4608E6E6;
defparam prom_inst_1.INIT_RAM_30 = 256'h445555E6E65555E6E7E65455F75455E655E655E655E655E6E655E655E6F75451;
defparam prom_inst_1.INIT_RAM_31 = 256'hF754E757663535566731315667F75454E634553555E7E6E7E6E7E6E7E6E7E6E6;
defparam prom_inst_1.INIT_RAM_32 = 256'hE7E6353544E6E63535E6E7E63435F75435E6E635E635E6F75431E6E631E631E6;
defparam prom_inst_1.INIT_RAM_33 = 256'hE7E735E735E735543450F75431E7E731E731E7F754E755E7E755E7E751E7E751;
defparam prom_inst_1.INIT_RAM_34 = 256'h55381054764436505438105444365054E7353544E7E73535E7E7E73435F75435;
defparam prom_inst_1.INIT_RAM_35 = 256'hC63454355534543555345434553454355435543554E6E6355435543554E63810;
defparam prom_inst_1.INIT_RAM_36 = 256'h5434553454E65455340034553455343420347F5404CEE63454355534543555E6;
defparam prom_inst_1.INIT_RAM_37 = 256'hE60554543434E60554543455345534345450553434E644E6053434E605355434;
defparam prom_inst_1.INIT_RAM_38 = 256'hE644E7053434E7053455345534345450553554345434553454E654553434E644;
defparam prom_inst_1.INIT_RAM_39 = 256'hE651E655E5E5E5E551E6E5E7E5E5E0503434E644E60554543434E60554543434;
defparam prom_inst_1.INIT_RAM_3A = 256'h55555555E6E6E6E6E7E6E6E6E6E6E6E6E655E655E6E6E6E655E6E6E7E6E65454;
defparam prom_inst_1.INIT_RAM_3B = 256'hE631E631E631E6E731E6E6E7E6E6E030E0E0E0E0E6E6E6E6E0E6E6E6E6E6E0E0;
defparam prom_inst_1.INIT_RAM_3C = 256'hE7E6E7E63535E6E7E7E6E7E6E6E6E6E6E635E635E635E6E735E6E6E7E6E6E034;
defparam prom_inst_1.INIT_RAM_3D = 256'hE735E735E735E7E735E7E6E7E6E6E634E731E731E731E7E731E7E6E7E6E6E030;
defparam prom_inst_1.INIT_RAM_3E = 256'h00000000000000000000040404040404E7E7E7E73535E7E7E7E7E7E6E6E6E6E6;
defparam prom_inst_1.INIT_RAM_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

pROM prom_inst_2 (
    .DO({prom_inst_2_dout_w[27:0],dout[19:16]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .AD({gw_gnd,ad[10:0],gw_gnd,gw_gnd})
);

defparam prom_inst_2.READ_MODE = 1'b0;
defparam prom_inst_2.BIT_WIDTH = 4;
defparam prom_inst_2.RESET_MODE = "SYNC";
defparam prom_inst_2.INIT_RAM_00 = 256'h2488434343434322288888888228432432C8C422233328C824AA8AA884CAA04C;
defparam prom_inst_2.INIT_RAM_01 = 256'h36C2836CACC238C8836C289C8836C2836CACC238C8836C289C8836C283222888;
defparam prom_inst_2.INIT_RAM_02 = 256'hBCAACAC823C28D6CACCAC8D6CCC2D6C2836C6ACC236C2836C2836C6ACC236C28;
defparam prom_inst_2.INIT_RAM_03 = 256'hC2D6C28D6C2836CACC238C8836C289C8836C28BCAACAC823C28BCAACAC823C28;
defparam prom_inst_2.INIT_RAM_04 = 256'h23C236CCC236C298CA88CA232CA3A3232CA3ABC88AC88232CA3A323A3AD6C6AC;
defparam prom_inst_2.INIT_RAM_05 = 256'hCCC236C236C29236CC6C236C236C234463463463836CC6C6236C6236C623236C;
defparam prom_inst_2.INIT_RAM_06 = 256'hA8A3028BCBC36CA43CC8A3028DC8A3028B6CB6CB6CAC6AA38888223624238236;
defparam prom_inst_2.INIT_RAM_07 = 256'hDCA8A8302832D6CACA6830283C46C2D6CCC2D6C2D6C2B6CC6A3CC8A8A3028DC8;
defparam prom_inst_2.INIT_RAM_08 = 256'h88223882343388882328823388BAAABAAAB8A8A8A88A8ABA2A8A888AA2838D32;
defparam prom_inst_2.INIT_RAM_09 = 256'h36C2836C28BC6A4ACA836C4C6CA2A836C2836C28B8A8234CC34C6D3C36A23298;
defparam prom_inst_2.INIT_RAM_0A = 256'h32B2BA6C68D9C3832288982288338883CCACA9334343BC6A4ACA836C4C6CA2A8;
defparam prom_inst_2.INIT_RAM_0B = 256'h2AA3C627CACCA232327CA232B2D6C43CC4CCC4CC43C6C4CC4C96222B62AA7CA2;
defparam prom_inst_2.INIT_RAM_0C = 256'hC2AB6CA2BA6C332CCC6C3AABA6332CCC6C3AAC33C627CC9836CCC0C84886BA63;
defparam prom_inst_2.INIT_RAM_0D = 256'h6C6AAAC6AA36C6ACCA2B6C6AACA296C622B6C6AA36C2AB6CA296C622B6C6AA36;
defparam prom_inst_2.INIT_RAM_0E = 256'h6CA2D6C6ACCACC62D6C6ACCA2D6CA2D6CA232BC6AACACC62968C62288C68822B;
defparam prom_inst_2.INIT_RAM_0F = 256'hC4CC4C96222B62AA7CA232B232D6C6CC2288882236CACCA2D6C2236CA2D6C223;
defparam prom_inst_2.INIT_RAM_10 = 256'hAAAA7CACCA23232BAAAAAAABAAAAAAA7CA232B2DC63CC4CC4CCC4CCCC43CC4C6;
defparam prom_inst_2.INIT_RAM_11 = 256'h296C622B6C6AA7CA232B2B6C6AC2C3C3C3CC3C2A98CCC0C68848B6CAC22ABAAA;
defparam prom_inst_2.INIT_RAM_12 = 256'hACACC62968C62288C68822B6C6AAAC6AA7C6ACCA2323296C622B6C6AA7CA232B;
defparam prom_inst_2.INIT_RAM_13 = 256'hC068A3AA36C068A3AA36C068A3AA36C068A3AA36C068A3AA36C068A3AA32BC6A;
defparam prom_inst_2.INIT_RAM_14 = 256'hAA36C068A3AA36C068A3AA36C068A3AA36C068A3AA36C068A3AA36C068A3AA36;
defparam prom_inst_2.INIT_RAM_15 = 256'hA36C068AA3AAA36C086AA3A6AA36C068A3AA36C068A3AA36C068A3AA36C068A3;
defparam prom_inst_2.INIT_RAM_16 = 256'h3A6AA36C068AA3AAA36C068AA3AAA36C068AA3AAA3C6068AA3AAA36C068AA3AA;
defparam prom_inst_2.INIT_RAM_17 = 256'h292929292382923836C6236C6236C6236C6236C6236C6236C6236C623C6086AA;
defparam prom_inst_2.INIT_RAM_18 = 256'h383339933993338B2A8A832323232323C882388232BA38929292929238292389;
defparam prom_inst_2.INIT_RAM_19 = 256'h238292BCA638923829238382382382382388C2388232BA389238292389238292;
defparam prom_inst_2.INIT_RAM_1A = 256'h3BAAABAAA9A8AB8A88888238888882D6AD6C3CC6AD6CCC68388C2388232BA389;
defparam prom_inst_2.INIT_RAM_1B = 256'h2888982888988898C68982C289828B8A89A8A3AA9488888D4C48D32BAAABAAA2;
defparam prom_inst_2.INIT_RAM_1C = 256'h382933339233333B982C2888982888982C289828988898C68B8A89A8A3AA982C;
defparam prom_inst_2.INIT_RAM_1D = 256'h382929239233333B3333333333333333989833333233333338293333923333BB;
defparam prom_inst_2.INIT_RAM_1E = 256'h382929239233333B382929239233333B3232982332333333382929239233333B;
defparam prom_inst_2.INIT_RAM_1F = 256'h444444444444444444444444444444444444444444CCCCCC3232982332333333;

endmodule //Gowin_pROM_inst
