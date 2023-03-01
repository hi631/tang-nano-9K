// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

module VgaDriver(input clk, input clk_pixel,
                 input [9:0] cx,
                 output reg [9:0] vga_ch, vga_cv,
                 output reg vga_h, output reg vga_v,
                 output reg [3:0] vga_r, output reg[3:0] vga_g, output reg[3:0] vga_b,
                 output [9:0] vga_hcounter,
                 output [9:0] vga_vcounter,
                 output [9:0] next_pixel_x, // The pixel we need NEXT cycle.
                 output hblnk, 
                 output vblnk,
                 input [14:0] pixel,        // Pixel for current cycle.
                 input sync,
                 output hsync0,vsync0,
                 input border);
parameter hoffset = 64;
// Horizontal and vertical counters
assign hsync0 = vga_ch==0;
assign vsync0 = vga_cv==0;
reg [9:0] vga_cv;
wire hpicture = (vga_ch>=hoffset) && (vga_ch < 512+hoffset);  // 512 lines of picture
wire hblnk = ~hpicture;
wire hsync_on  = (vga_ch == 512 + 128 + 24);       // HSync ON, 128+24 pixels front porch
wire hsync_off = (vga_ch == 512 + 128 + 24 + 96);  // Hsync off, 96 pixels sync
wire hend = (vga_ch == 800);                       // End of line, 800 pixels.

wire vpicture = (vga_cv < 480);                    // 480 lines of picture
wire vsync_on  = hsync_on && (vga_cv == 480 + 10); // Vsync ON, 10 lines front porch.
wire vsync_off = hsync_on && (vga_cv == 480 + 12); // Vsync OFF, 2 lines sync signal
wire vend = (vga_cv == 525-1);                       // End of picture, 524 lines. (Should really be 525 according to NTSC spec)
wire inpicture = hpicture && vpicture;
wire vblnk = ~vpicture; 
assign vga_hcounter = vga_ch;
assign vga_vcounter = vga_cv;
wire [9:0] new_h = (hend || sync) ? 0 : vga_ch + 1;
assign next_pixel_x = {sync ? 1'b0 : hend ? !vga_cv[0] : vga_cv[0], new_h[8:0] - hoffset};

//reg  vga_ch, vga_cv;
always @(posedge clk_pixel) begin
  if (sync) begin
    vga_ch <= 0; vga_h <= 0;
    vga_cv <= 0; vga_v <= 0;
  end else begin
    vga_ch <= hend ? 0 : vga_ch + 1;
    if (hend) vga_cv <= vend ? 0 : vga_cv + 1;
    vga_h <= hsync_on ? 0 : hsync_off ? 1 : vga_h;
    vga_v <= vsync_on ? 0 : vsync_off ? 1 : vga_v;
    vga_r <= pixel[4:1]; vga_g <= pixel[9:6]; vga_b <= pixel[14:11];
    if (border && (vga_ch == 0+hoffset || vga_ch == 511+hoffset || vga_cv == 1 || vga_cv == 479)) begin
      vga_r <= 4'b0000; vga_g <= 4'b0000;  vga_b <= 4'b0111;
    end
    if (!inpicture) begin
      vga_r <= 4'b0000; vga_g <= 4'b0000; vga_b <= 4'b0000;
    end
  end
end
endmodule
