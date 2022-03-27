//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.03
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9C
//Created Time: Sun Mar 13 21:49:57 2022

module Gowin_SP (dout, clk, oce, ce, reset, wre, ad, din);

output [7:0] dout;
input clk;
input oce;
input ce;
input reset;
input wre;
input [13:0] ad;
input [7:0] din;

wire [30:0] sp_inst_0_dout_w;
wire [30:0] sp_inst_1_dout_w;
wire [30:0] sp_inst_2_dout_w;
wire [30:0] sp_inst_3_dout_w;
wire [30:0] sp_inst_4_dout_w;
wire [30:0] sp_inst_5_dout_w;
wire [30:0] sp_inst_6_dout_w;
wire [30:0] sp_inst_7_dout_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

SP sp_inst_0 (
    .DO({sp_inst_0_dout_w[30:0],dout[0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD(ad[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[0]})
);

defparam sp_inst_0.READ_MODE = 1'b0;
defparam sp_inst_0.WRITE_MODE = 2'b00;
defparam sp_inst_0.BIT_WIDTH = 1;
defparam sp_inst_0.BLK_SEL = 3'b000;
defparam sp_inst_0.RESET_MODE = "SYNC";

SP sp_inst_1 (
    .DO({sp_inst_1_dout_w[30:0],dout[1]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD(ad[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[1]})
);

defparam sp_inst_1.READ_MODE = 1'b0;
defparam sp_inst_1.WRITE_MODE = 2'b00;
defparam sp_inst_1.BIT_WIDTH = 1;
defparam sp_inst_1.BLK_SEL = 3'b000;
defparam sp_inst_1.RESET_MODE = "SYNC";

SP sp_inst_2 (
    .DO({sp_inst_2_dout_w[30:0],dout[2]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD(ad[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[2]})
);

defparam sp_inst_2.READ_MODE = 1'b0;
defparam sp_inst_2.WRITE_MODE = 2'b00;
defparam sp_inst_2.BIT_WIDTH = 1;
defparam sp_inst_2.BLK_SEL = 3'b000;
defparam sp_inst_2.RESET_MODE = "SYNC";

SP sp_inst_3 (
    .DO({sp_inst_3_dout_w[30:0],dout[3]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD(ad[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[3]})
);

defparam sp_inst_3.READ_MODE = 1'b0;
defparam sp_inst_3.WRITE_MODE = 2'b00;
defparam sp_inst_3.BIT_WIDTH = 1;
defparam sp_inst_3.BLK_SEL = 3'b000;
defparam sp_inst_3.RESET_MODE = "SYNC";

SP sp_inst_4 (
    .DO({sp_inst_4_dout_w[30:0],dout[4]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD(ad[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[4]})
);

defparam sp_inst_4.READ_MODE = 1'b0;
defparam sp_inst_4.WRITE_MODE = 2'b00;
defparam sp_inst_4.BIT_WIDTH = 1;
defparam sp_inst_4.BLK_SEL = 3'b000;
defparam sp_inst_4.RESET_MODE = "SYNC";

SP sp_inst_5 (
    .DO({sp_inst_5_dout_w[30:0],dout[5]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD(ad[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[5]})
);

defparam sp_inst_5.READ_MODE = 1'b0;
defparam sp_inst_5.WRITE_MODE = 2'b00;
defparam sp_inst_5.BIT_WIDTH = 1;
defparam sp_inst_5.BLK_SEL = 3'b000;
defparam sp_inst_5.RESET_MODE = "SYNC";

SP sp_inst_6 (
    .DO({sp_inst_6_dout_w[30:0],dout[6]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD(ad[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[6]})
);

defparam sp_inst_6.READ_MODE = 1'b0;
defparam sp_inst_6.WRITE_MODE = 2'b00;
defparam sp_inst_6.BIT_WIDTH = 1;
defparam sp_inst_6.BLK_SEL = 3'b000;
defparam sp_inst_6.RESET_MODE = "SYNC";

SP sp_inst_7 (
    .DO({sp_inst_7_dout_w[30:0],dout[7]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD(ad[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[7]})
);

defparam sp_inst_7.READ_MODE = 1'b0;
defparam sp_inst_7.WRITE_MODE = 2'b00;
defparam sp_inst_7.BIT_WIDTH = 1;
defparam sp_inst_7.BLK_SEL = 3'b000;
defparam sp_inst_7.RESET_MODE = "SYNC";

endmodule //Gowin_SP
