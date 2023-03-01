`timescale 1ns/1ps

module hdmi_test (
  input clk,
  input resetn,

  output       tmds_clk_n,
  output       tmds_clk_p,
  output [2:0] tmds_d_n,
  output [2:0] tmds_d_p,

  output [5:0]  gpio,
  output [5:0]	LED
);
 assign LED = ~(6'b000001);

  wire sys_resetn;
  wire clk_p, clk_p5, pll_lock2;

  Gowin_rPLL2 u_pll (.clkin(clk), .clkout(clk_p5), .lock(pll_lock2) );
  Gowin_CLKDIV u_div_5 ( .clkout(clk_p), .hclkin(clk_p5), .resetn(pll_lock2) );

  wire ext_reset = resetn & pll_lock2;
  reg [3:0] reset_cnt = 0;
  always @(posedge clk_p or negedge ext_reset) begin
     if (~ext_reset) reset_cnt <= 4'b0;
     else            reset_cnt <= reset_cnt + !sys_resetn;
  end
  assign sys_resetn = &reset_cnt;

svo_hdmi_top u_hdmi (
	.clk(clk_p),
	.resetn(sys_resetn),
	// video clocks
	.clk_pixel(clk_p),
	.clk_5x_pixel(clk_p5),
	.locked(pll_lock2),
	// output signals
	.tmds_clk_n(tmds_clk_n),
	.tmds_clk_p(tmds_clk_p),
	.tmds_d_n(tmds_d_n),
	.tmds_d_p(tmds_d_p),
	.tmds_ts(gpio[5:0])
);

endmodule
