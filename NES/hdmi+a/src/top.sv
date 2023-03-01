module top (
  input clk27M,
  // HDMI
  output       tmds_clk_n,
  output       tmds_clk_p,
  output [2:0] tmds_d_n,
  output [2:0] tmds_d_p,
  // I/O
  input  [1:0]	BTN,
  output [5:0]  gpio,
  output [5:0]	LED
);

  assign gpio [5:0] = 6'b000000;
  assign LED  [5:0] = ~{5'b00000,sound_on};  
  wire reset = ~BTN[1];

  logic clk_pixel;		//  25.175MHz
  logic clk_pixel_x5;	// 125.875MHz
  logic clk_audio;		// 24.5KHz = 25.175/1024

  wire pll_lock;
  Gowin_rPLL2 u_pll (.clkin(clk27M), .clkout(clk_pixel_x5), .lock(pll_lock) );
  Gowin_CLKDIV u_div_5 ( .clkout(clk_pixel), .hclkin(clk_pixel_x5), .resetn(pll_lock) );

  logic [9:0] audio_clk_div;
  always_comb clk_audio = audio_clk_div[9];
always_ff @(posedge clk_pixel) begin
    if (reset) audio_clk_div <= 0;
    else       audio_clk_div <= audio_clk_div + 1;
end

logic [15:0] audio_sample_word [1:0] = '{16'd0, 16'd0};
logic [12:0] tinterval;
wire sound_on = (BTN[0] && tinterval[11]) || (~BTN[0] && tinterval[10]);
always @(posedge clk_audio) begin
  tinterval <= tinterval + 1;
  if(sound_on) begin
    audio_sample_word[0][12:8] <= audio_sample_word[0][12:8] + 5'h1; 
    audio_sample_word[1][12:8] <= audio_sample_word[1][12:8] - 5'h1;
  end
end

logic [23:0] rgb = 24'd0;
logic [9:0] cx, cy, screen_start_x, screen_start_y, frame_width, frame_height, screen_width, screen_height;
// Border test (left = red, top = green, right = blue, bottom = blue, fill = black)
always @(posedge clk_pixel)
  rgb <= {cx == 0 ? ~8'd0 : 8'd0, cy == 0 ? ~8'd0 : 8'd0, cx == screen_width - 1'd1 || cy == screen_width - 1'd1 ? ~8'd0 : 8'd0};

// 640x480 @ 59.94Hz
hdmi #(.VIDEO_ID_CODE(1), .VIDEO_REFRESH_RATE(59.94), .AUDIO_RATE(48000), .AUDIO_BIT_WIDTH(16)) hdmi(
  .clk_pixel_x5(clk_pixel_x5),
  .clk_pixel(clk_pixel),
  .clk_audio(clk_audio),
  .reset(reset),
  .rgb(rgb),
  .audio_sample_word(audio_sample_word),
  //.tmds(tmds),
  //.tmds_clock(tmds_clock),
  .tmds_clk_n(tmds_clk_n),
  .tmds_clk_p(tmds_clk_p),
  .tmds_d_n(tmds_d_n),
  .tmds_d_p(tmds_d_p),
  .cx(cx),
  .cy(cy),
  .frame_width(frame_width),
  .frame_height(frame_height),
  .screen_width(screen_width),
  .screen_height(screen_height)
);

endmodule
