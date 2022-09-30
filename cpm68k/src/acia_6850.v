module acia_6850
(
  input        clk,
  input        reset,
  input        cs,
  input        e_clk,
  input        rw_n,
  input        rs,
  input  [7:0] data_in,
  output [7:0] data_out,
  output       data_en,
  input        txclk,
  input        rxclk,
  input        rxdata,
  input        cts_n,
  input        dcd_n,
  output       irq_n,
  output       txdata,
  output       rts_n
);

  wire [7:0] w_data_rx;
  wire       w_data_rx_en;
  wire [7:0] w_data_ctrl;
  wire       w_data_ctrl_en;
  wire       w_rdrf;
  wire       w_tdre;
  wire       w_fe;
  wire       w_ovr;
  wire       w_pe;
  wire       w_mclr;
  wire [1:0] w_cds;
  wire [2:0] w_ws;
  wire [1:0] w_tc;
  wire       w_irq_n;

  assign data_en  = cs & rw_n & e_clk;
  assign data_out = w_data_rx | w_data_ctrl;
  assign irq_n    = w_irq_n;

  acia_6850_ctl U_acia_6850_ctl
  (
    .clk(clk),
    .reset(reset),
    .cs(cs),
    .e_clk(e_clk),
    .rw_n(rw_n),
    .rs(rs),
    .data_in(data_in),
    .data_out(w_data_ctrl),
    .data_en(w_data_ctrl_en),
    .rdrf(w_rdrf),
    .tdre(w_tdre),
    .dcd_n(dcd_n),
    .cts_n(cts_n),
    .fe(w_fe),
    .ovr(w_ovr),
    .pe(w_pe),
    .mclr(w_mclr),
    .rts_n(rts_n),
    .cds(w_cds),
    .ws(w_ws),
    .tc(w_tc),
    .irq_n(w_irq_n)
  );

  acia_6850_rx U_acia_6850_rx
  (
    .clk(clk),
    .reset(reset),
    .mclr(w_mclr),
    .cs(cs),
    .e_clk(e_clk),
    .rw_n(rw_n),
    .rs(rs),
    .data_out(w_data_rx),
    .data_en(w_data_rx_en),
    .ws(w_ws),
    .cds(w_cds),
    .rxclk(rxclk),
    .rxdata(rxdata),
    .rdrf(w_rdrf),
    .ovr(w_ovr),
    .pe(w_pe),
    .fe(w_fe)
  );

  acia_6850_tx U_acia_6850_tx
  (
    .clk(clk),
    .reset(reset),
    .mclr(w_mclr),
    .cs(cs),
    .e_clk(e_clk),
    .rw_n(rw_n),
    .rs(rs),
    .data_in(data_in),
    .cts_n(cts_n),
    .tc(w_tc),
    .ws(w_ws),
    .cds(w_cds),
    .tdre(w_tdre),
    .txclk(txclk),
    .txdata(txdata)
  );

endmodule

module acia_6850_ctl
(
  input        clk,
  input        reset,
  input        cs,
  input        e_clk,
  input        rw_n,
  input        rs,
  input  [7:0] data_in,
  output [7:0] data_out,
  output       data_en,
  // Status register stuff:
  input        rdrf,    // Receive data register full.
  input        tdre,    // Transmit data register empty.
  input        dcd_n,   // Data carrier detect.
  input        cts_n,   // Clear to send.
  input        fe,      // Framing error.
  input        ovr,     // Overrun error.
  input        pe,      // Parity error.
  
  // Control register stuff:
  output       mclr,    // Master clear (high active).
  output       rts_n,   // Request to send.
  output [1:0] cds,     // Clock control.
  output [2:0] ws,      // Word select.
  output [1:0] tc,      // Transmit control.
  output reg   irq_n    // Interrupt request.
);

  reg  [7:0] ctrl_reg;
  wire [7:0] status_reg;
  wire       rie;
  reg        irq_i;
  reg        cts_i_n;
  reg        dcd_i_n;
  reg        dcd_flag_n;
  reg        ovr_lock;
  reg        dcd_lock;
  reg        dcd_trans;
  reg        read_lock;
  reg        dcd_release;


  always @(posedge clk) begin
    cts_i_n <= cts_n; // Sample CTSn on the negative clock edge.
    dcd_i_n <= dcd_n; // Sample DCDn on the negative clock edge.
  end

  assign status_reg[7] = irq_i;
  assign status_reg[6] = pe;
  assign status_reg[5] = ovr;
  assign status_reg[4] = fe;
  assign status_reg[3] = cts_i_n;         // Reflexion of the input pin.
  assign status_reg[2] = dcd_flag_n;
  assign status_reg[1] = tdre & ~cts_i_n; // No TDRE for CTS_n = '1'.
  assign status_reg[0] = rdrf & ~dcd_i_n; // DCD_n = '1' indicates empty.
  
  assign data_out = (cs & rw_n & ~rs) ? status_reg : 8'h00;
  assign data_en  = (cs & rw_n & ~rs) ? e_clk : 1'b0;
  
  assign mclr     = (ctrl_reg[1:0] == 2'b11) ? 1'b1 : 1'b0;
  assign rts_n    = ((ctrl_reg[6:5] != 2'b10) && (tdre)) ? 1'b0 : 1'b1;
  assign cds      = ctrl_reg[1:0];
  assign ws       = ctrl_reg[4:2];
  assign tc       = ctrl_reg[6:5];
  assign rie      = ctrl_reg[7];

  always @(posedge reset or posedge clk) begin
    if (reset) begin
      ovr_lock = 1'b0;
      irq_n   <= 1'b1;
      irq_i   <= 1'b0;
    end else begin
      // Transmitter interrupt:
      if ((tdre) && (ctrl_reg[6:5] == 2'b01) && (!cts_i_n)) begin
        irq_n <= 1'b0;
        irq_i <= 1'b1;
      end
      else if (cs & ~rw_n & rs & e_clk) begin
        irq_n <= 1'b1; // Clear by writing to the transmit data register.
      end
      // Receiver interrupts:
      if ((rdrf) && (rie) && (!dcd_i_n)) begin
        irq_n <= 1'b0;
        irq_i <= 1'b1;
      end
      else if (cs & rw_n & rs & e_clk) begin
        irq_n <= 1'b1; // Clear by reading the receive data register.
      end
      if ((ovr) && (rie)) begin
        irq_n <= 1'b0;
        irq_i <= 1'b1;
        ovr_lock = 1'b1;
      end
      else if (cs & rw_n & ~rs & e_clk) begin
        ovr_lock = 1'b0; // Enable reset by reading the status.
      end
      else if (cs & rw_n & rs & e_clk & ~ovr_lock) begin
        irq_n <= 1'b1; // Clear by reading the receive data register after the status.
      end
      if ((dcd_i_n) && (rie) && (!dcd_trans)) begin
        irq_n <= 1'b0;
        irq_i <= 1'b1;
        // DCD_TRANS is used to detect a low to high transition of DCDn.
        dcd_trans = 1'b1;
      end
      else if (cs & rw_n & rs & e_clk & ~ovr_lock) begin
        irq_n <= 1'b1;
        // Clear by reading the receive data register after the status.
      end
      else if (!dcd_i_n) begin
        dcd_trans = 1'b0;
      end
      // The reset of the IRQ status flag:
      if (cs & ~rw_n & rs & e_clk) begin
        irq_i <= 1'b0; // Clear by writing to the transmit data register.
      end
      else if (cs & rw_n & rs & e_clk & ~ovr_lock) begin
        irq_i <= 1'b0; // Clear by reading the receive data register after the status.
      end
    end
  end

  always @(posedge reset or posedge clk) begin
    if (reset) begin
      ctrl_reg <= 8'b01000000;
    end else begin
      if (cs & ~rw_n & ~rs & e_clk) begin
        ctrl_reg <= data_in;
      end
    end
  end

  // This process is some kind of tricky. Refer to the MC6850 data
  // sheet for more information.
  always @(posedge reset or posedge clk) begin : P1
    if (reset) begin
      dcd_flag_n <= 1'b0;
      // This interrupt source must initialise low.
      read_lock   = 1'b1;
      dcd_release = 1'b0;
    end else begin
      if (mclr) begin
        dcd_flag_n <= dcd_i_n;
        read_lock   = 1'b1;
      end
      else if (dcd_i_n) begin
        dcd_flag_n <= 1'b1;
      end
      else if (cs & rw_n & ~rs & e_clk) begin
        read_lock = 1'b0;
        // Un-READ_LOCK if receiver data register is read.
      end
      else if (cs & rw_n & rs & e_clk & ~read_lock) begin
        // Clear if receiver status register read access.
        // After data register has ben read and READ_LOCK again.
        dcd_release = 1'b1;
        read_lock   = 1'b1;
        dcd_flag_n <= dcd_i_n;
      end
      else if ((!dcd_i_n) && (dcd_release)) begin
        dcd_flag_n <= 1'b0;
        dcd_release = 1'b0;
      end
    end
  end

endmodule

module acia_6850_rx
(
  input        clk,
  input        reset,
  input        mclr,
  input        cs,
  input        e_clk,
  input        rw_n,
  input        rs,
  output [7:0] data_out,
  output       data_en,
  input  [2:0] ws,
  input  [1:0] cds,
  input        rxclk,
  input        rxdata,
  output reg   rdrf,
  output reg   ovr,
  output reg   pe,
  output reg   fe
);

localparam [2:0]
  RX_IDLE       = 3'd0,
  RX_WAIT_START = 3'd1,
  RX_SAMPLE     = 3'd2,
  RX_PARITY     = 3'd3,
  RX_STOP1      = 3'd4,
  RX_STOP2      = 3'd5,
  RX_SYNC       = 3'd6;

  reg [2:0] rcv_state;
  reg [2:0] rcv_next_state;
  reg       rxdata_i;
  reg       rxdata_s;
  reg [7:0] data_reg;
  reg [7:0] shift_reg;
  reg       clk_strb;
  reg [2:0] bitcnt;
  reg       clk_lock;
  reg       strb_lock;
  reg [6:0] clk_divcnt;
  reg       fe_i;
  reg       ovr_i;
  reg       first_read;
  reg       par_tmp;
  reg       pe_i;
  reg [1:0] flt_tmp;

  // This filter provides a synchronisation to the system
  // clock, even for random baud rates of the received data
  // stream.
  always @(posedge clk) begin
    //
    rxdata_i <= rxdata;
    //
    if ((rxdata_i) && (flt_tmp < 2'd2)) begin
      flt_tmp <= flt_tmp + 2'd1;
    end
    else if (rxdata_i) begin
      rxdata_s <= 1'b1;
    end
    else if ((!rxdata_i) && (flt_tmp > 2'd0)) begin
      flt_tmp <= flt_tmp - 2'd1;
    end
    else if (!rxdata_i) begin
      rxdata_s <= 1'b0;
    end
  end

  always @(posedge clk) begin
    if (cds == 2'b00) begin
      // Divider off.
      if ((rxclk) && (!strb_lock)) begin
        clk_strb <= 1'b1;
        strb_lock = 1'b1;
      end
      else if (!rxclk) begin
        clk_strb <= 1'b0;
        strb_lock = 1'b0;
      end
      else begin
        clk_strb <= 1'b0;
      end
    end
    else if (rcv_state == RX_IDLE) begin
      // Preset the CLKDIV with the start delays.
      if (cds == 2'b01) begin
        clk_divcnt = 7'd8; // Half of div by 16 mode.
      end
      else if (cds == 2'b10) begin
        clk_divcnt = 7'd32; // Half of div by 64 mode.
      end
      clk_strb <= 1'b0;
    end
    else begin
      if ((clk_divcnt > 7'd0) && (rxclk) && (!clk_lock)) begin
        clk_divcnt = clk_divcnt - 7'd1;
        clk_strb  <= 1'b0;
        clk_lock   = 1'b1;
      end
      else if ((cds == 2'b01) && (clk_divcnt == 7'd0)) begin
        clk_divcnt = 7'd16; // div by 16 mode.
        //
        if (!strb_lock) begin
          strb_lock = 1'b1;
          clk_strb <= 1'b1;
        end
        else begin
          clk_strb <= 1'b0;
        end
      end
      else if ((cds == 2'b10) && (clk_divcnt == 7'd0)) begin
        clk_divcnt = 7'd64;
        // Div by 64 mode.
        if (!strb_lock) begin
          strb_lock = 1'b1;
          clk_strb <= 1'b1;
        end
        else begin
          clk_strb <= 1'b0;
        end
      end
      else if (!rxclk) begin
        clk_lock  = 1'b0;
        strb_lock = 1'b0;
        clk_strb <= 1'b0;
      end
      else begin
        clk_strb <= 1'b0;
      end
    end
  end

  always @(posedge reset or posedge clk) begin
    if (reset) begin
      data_reg <= 8'h00;
    end else begin
      if (mclr) begin
        data_reg <= 8'h00;
      end
      else if ((rcv_state == RX_SYNC) && (!ws[2]) && (!rdrf)) begin
        // 7 bit data.
        // Transfer from shift- to data register only if
        // data register is empty (RDRF = '0').
        data_reg <= {1'b0, shift_reg[7:1]};
      end
      else if ((rcv_state == RX_SYNC) && (ws[2]) && (!rdrf)) begin
        // 8 bit data.
        // Transfer from shift- to data register only if
        // data register is empty (RDRF = '0').
        data_reg <= shift_reg;
      end
    end
  end

  assign data_out = (cs & rw_n & rs) ? data_reg : 8'h00;
  assign data_en  = (cs & rw_n & rs) ? e_clk : 1'b0;
  
  always @(posedge reset or posedge clk) begin
    if (reset) begin
      shift_reg <= 8'h00;
    end else begin
      if (mclr) begin
        shift_reg <= 8'h00;
      end
      else if ((rcv_state == RX_SAMPLE) && (clk_strb)) begin
        shift_reg <= {rxdata_s, shift_reg[7:1]}; // Shift right.
      end
    end
  end

  always @(posedge clk) begin
    if ((rcv_state == RX_SAMPLE) && (clk_strb)) begin
      bitcnt <= bitcnt + 3'd1;
    end
    else if (rcv_state != RX_SAMPLE) begin
      bitcnt <= 3'd0;
    end
  end

  // This module detects a framing error
  // during stop bit 1 and stop bit 2.
  always @(posedge reset or posedge clk) begin
    if (reset) begin
      fe_i = 1'b0;
      fe  <= 1'b0;
    end else begin
      if (mclr) begin
        fe_i = 1'b0;
        fe  <= 1'b0;
      end
      else if (clk_strb) begin
        if ((rcv_state == RX_STOP1) && (!rxdata_s)) begin
          fe_i = 1'b1;
        end
        else if ((rcv_state == RX_STOP2) && (!rxdata_s)) begin
          fe_i = 1'b1;
        end
        else if ((rcv_state == RX_STOP1) || (rcv_state == RX_STOP2)) begin
          fe_i = 1'b0; // Error resets when correct data appears.
        end
      end
      if (rcv_state == RX_SYNC) begin
        fe <= fe_i; // Update the FE every SYNC time.
      end
    end
  end

  always @(posedge reset or posedge clk) begin
    if (reset) begin
      ovr_i      <= 1'b0;
      ovr        <= 1'b0;
      first_read <= 1'b0;
    end else begin
      if (mclr) begin
        ovr_i      <= 1'b0;
        ovr        <= 1'b0;
        first_read <= 1'b0;
      end
      else if ((clk_strb) && (rcv_state == RX_STOP1)) begin
        // Overrun appears if RDRF is '1' in this state.
        ovr_i <= rdrf;
      end
      if (cs & rw_n & rs & e_clk & ovr_i) begin
        // If an overrun was detected, the concerning flag is
        // set when the valid data word in the receiver data
        // register is read. Thereafter the RDRF flag is reset
        // and the overrun disappears (OVR_I goes low) after
        // a second read (in time) of the receiver data register.
        if (!first_read) begin
          ovr        <= 1'b1;
          first_read <= 1'b1;
        end
        else begin
          ovr        <= 1'b0;
          first_read <= 1'b0;
        end
      end
    end
  end

  always @(posedge reset or posedge clk) begin
    if (reset) begin
      pe   <= 1'b0;
      pe_i <= 1'b0;
    end else begin
      if (mclr) begin
        pe   <= 1'b0;
        pe_i <= 1'b0;
      end
      // Sample parity on clock strobe.
      else if (clk_strb) begin
        if (rcv_state == RX_PARITY) begin
          par_tmp = (^ shift_reg);
          if ((ws == 3'b000) || (ws == 3'b010) || (ws == 3'b110)) begin
            // Even parity.
            pe_i <= par_tmp ^ rxdata_s;
          end
          else if ((ws == 3'b001) || (ws == 3'b011) || (ws == 3'b111)) begin
            // Odd parity.
            pe_i <= ~par_tmp ^ rxdata_s;
          end
          else begin
            // No parity for WS = "100" and WS = "101".
            pe_i <= 1'b0;
          end
        end
      end
      // Transmit the parity flag together with the data
      // In other words: no parity to the status register
      // when RDRF inhibits the data transfer to the
      // receiver data register.
      if ((rcv_state == RX_SYNC) && (!rdrf)) begin
        pe <= pe_i;
      end
      else if (cs & rw_n & rs & e_clk) begin
        pe <= 1'b0; // Clear when reading the data register.
      end
    end
  end

  // Receive data register full flag.
  always @(posedge reset or posedge clk) begin : P1
    if (reset) begin
      rdrf <= 1'b0;
    end else begin
      if (mclr) begin
        rdrf <= 1'b0;
      end
      else if (rcv_state == RX_SYNC) begin
        rdrf <= 1'b1; // Data register is full until now!
      end
      else if (cs & rw_n & rs & e_clk) begin
        rdrf <= 1'b0; // After reading the data register ...
      end
    end
  end

  always @(posedge reset or posedge clk) begin
    if (reset) begin
      rcv_state <= RX_IDLE;
    end else begin
      if (mclr) begin
        rcv_state <= RX_IDLE;
      end
      else begin
        rcv_state <= rcv_next_state;
      end
    end
  end

  always @(*) begin
    case(rcv_state)
      RX_IDLE : begin
        if(rxdata_s == 1'b 0 && cds == 2'b 00) begin
          rcv_next_state = RX_SAMPLE;
          // Startbit detected in div by 1 mode.
        end
        else if(rxdata_s == 1'b 0 && cds == 2'b 01) begin
          rcv_next_state = RX_WAIT_START;
          // Startbit detected in div by 16 mode.
        end
        else if(rxdata_s == 1'b 0 && cds == 2'b 10) begin
          rcv_next_state = RX_WAIT_START;
          // Startbit detected in div by 64 mode.
        end
        else begin
          rcv_next_state = RX_IDLE;
          // No startbit; sleep well :-)
        end
      end
      RX_WAIT_START : begin
        if (clk_strb) begin
          if(rxdata_s == 1'b 0) begin
            rcv_next_state = RX_SAMPLE;
            // Start condition in no div by 1 modes.
          end
          else begin
            rcv_next_state = RX_IDLE;
            // No valid start condition, go back.
          end
        end
        else begin
          rcv_next_state = RX_WAIT_START;
          // Stay.
        end
      end
      RX_SAMPLE : begin
        if (clk_strb) begin
          if(bitcnt < 3'b 110 && ws[2] == 1'b 0) begin
            rcv_next_state = RX_SAMPLE;
            // Go on sampling 7 data bits.
          end
          else if(bitcnt < 3'b 111 && ws[2] == 1'b 1) begin
            rcv_next_state = RX_SAMPLE;
            // Go on sampling 8 data bits.
          end
          else if(ws == 3'b 100 || ws == 3'b 101) begin
            rcv_next_state = RX_STOP1;
            // No parity check enabled.
          end
          else begin
            rcv_next_state = RX_PARITY;
            // Parity enabled.
          end
        end
        else begin
          rcv_next_state = RX_SAMPLE;
          // Stay in sample mode.
        end
      end
      RX_PARITY : begin
        if (clk_strb) begin
          rcv_next_state = RX_STOP1;
        end
        else begin
          rcv_next_state = RX_PARITY;
        end
      end
      RX_STOP1 : begin
        if (clk_strb) begin
          if(rxdata_s == 1'b 0) begin
            rcv_next_state = RX_SYNC;
            // Framing error detected.
          end
          else if(ws == 3'b 000 || ws == 3'b 001 || ws == 3'b 100) begin
            rcv_next_state = RX_STOP2;
            // Two stop bits selected.
          end
          else begin
            rcv_next_state = RX_SYNC;
            // One stop bit selected.
          end
        end
        else begin
          rcv_next_state = RX_STOP1;
        end
      end
      RX_STOP2 : begin
        if (clk_strb) begin
          rcv_next_state = RX_SYNC;
        end
        else begin
          rcv_next_state = RX_STOP2;
        end
      end
      RX_SYNC : begin
        rcv_next_state = RX_IDLE;
      end
      default : begin
        rcv_next_state = RX_IDLE;
      end
    endcase
  end

endmodule

module acia_6850_tx
(
  input        clk,
  input        reset,
  input        mclr,
  input        cs,
  input        e_clk,
  input        rw_n,
  input        rs,
  input  [7:0] data_in,
  input        cts_n,
  input  [1:0] tc,
  input  [2:0] ws,
  input  [1:0] cds,
  input        txclk,
  output reg   tdre,
  output       txdata
);

localparam [2:0]
  TX_IDLE       = 3'd0,
  TX_LOAD_SHIFT = 3'd1,
  TX_START      = 3'd2,
  TX_SHIFTOUT   = 3'd3,
  TX_PARITY     = 3'd4,
  TX_STOP1      = 3'd5,
  TX_STOP2      = 3'd6;

reg [2:0] tr_state;
reg [2:0] tr_next_state;
reg       clk_strb;
reg [7:0] data_reg;
reg [7:0] shift_reg;
reg [2:0] bitcnt;
reg       par_tmp;
reg       parity_i;
reg       tx_lock;
reg       clk_lock;
reg       strb_lock;
reg [6:0] clk_divcnt;

  // The default condition in this statement is to ensure
  // to cover all possibilities for example if there is a
  // one hot decoding of the state machine with wrong states
  // (e.g. not one of the given here).
  assign txdata = (tr_state == TX_IDLE       ) ? 1'b1
                : (tr_state == TX_LOAD_SHIFT ) ? 1'b1
                : (tr_state == TX_START      ) ? 1'b0
                : (tr_state == TX_SHIFTOUT   ) ? shift_reg[0]
                : (tr_state == TX_PARITY     ) ? parity_i
                : (tr_state == TX_STOP1      ) ? 1'b1
                : (tr_state == TX_STOP2      ) ? 1'b1 : 1'b1;
                
  always @(posedge clk) begin
    if (cds == 2'b00) begin
      // divider off
      if ((!txclk) && (!strb_lock)) begin
        // Works on negative TXCLK edge.
        clk_strb  <= 1'b1;
        strb_lock <= 1'b1;
      end
      else if (txclk) begin
        clk_strb  <= 1'b0;
        strb_lock <= 1'b0;
      end
      else begin
        clk_strb <= 1'b0;
      end
      clk_lock  <= 1'b0;
    end
    else if (tr_state == TX_IDLE) begin
      // preset the CLKDIV with the start delays
      if (cds == 2'b01) begin
        clk_divcnt <= 7'd16; // div by 16 mode
      end
      else if (cds == 2'b10) begin
        clk_divcnt <= 7'd64; // div by 64 mode
      end
      clk_strb <= 1'b0;
    end
    else begin
      // Works on negative TXCLK edge:
      if ((clk_divcnt > 7'd0) && (!txclk) && (!clk_lock)) begin
        clk_divcnt <= clk_divcnt - 7'd1;
        clk_strb   <= 1'b0;
        clk_lock   <= 1'b1;
      end
      else if ((cds == 2'b01) && (clk_divcnt == 7'd0)) begin
        clk_divcnt <= 7'd16; // div by 16 mode.
        if (!strb_lock) begin
          strb_lock <= 1'b1;
          clk_strb  <= 1'b1;
        end
        else begin
          clk_strb  <= 1'b0;
        end
      end
      else if ((cds == 2'b10) && (clk_divcnt == 7'd0)) begin
        clk_divcnt <= 7'd64; // div by 64 mode.
        if (!strb_lock) begin
          strb_lock <= 1'b1;
          clk_strb  <= 1'b1;
        end
        else begin
          clk_strb  <= 1'b0;
        end
      end
      else if (txclk) begin
        clk_lock  <= 1'b0;
        strb_lock <= 1'b0;
        clk_strb  <= 1'b0;
      end
      else begin
        clk_strb  <= 1'b0;
      end
    end
  end

    always @(posedge reset or posedge clk) begin
    
        if (reset) begin
            data_reg <= 8'h00;
        end
        else if (e_clk) begin
            if (mclr) begin
                data_reg <= 8'h00;
            end
            else if (cs & ~rw_n & rs) begin
                data_reg[7]   <= data_in[7] & ws[2]; // 7/8 bit data mode
                data_reg[6:0] <= data_in[6:0];
                $display("ACIA TX : %x %c", data_in, data_in);
            end
        end
    end

  always @(posedge reset or posedge clk) begin
    if (reset) begin
      shift_reg <= 8'h00;
    end else begin
      if (mclr) begin
        shift_reg <= 8'h00;
      end
      else if ((tr_state == TX_LOAD_SHIFT) && (!tdre)) begin
        // If during LOAD_SHIFT the transmitter data register
        // is empty (TDRE = '1') the shift register will not
        // be loaded. When additionally TC = "11", the break
        // character (zero data and no stop bits) is sent.
        shift_reg <= data_reg;
      end
      else if ((tr_state == TX_SHIFTOUT) && (clk_strb)) begin
        shift_reg <= {1'b0, shift_reg[7:1]}; // Shift right.
      end
    end
  end

  // Counter for the data bits transmitted.
  always @(posedge clk) begin
    if ((tr_state == TX_SHIFTOUT) && (clk_strb)) begin
      bitcnt <= bitcnt + 3'd1;
    end
    else if (tr_state != TX_SHIFTOUT) begin
      bitcnt <= 3'd0;
    end
  end

  // Transmit data register empty flag.
  always @(posedge reset or posedge clk) begin
    if (reset) begin
      tdre    <= 1'b1;
      tx_lock <= 1'b0;
    end else begin
      if (mclr) begin
        tdre <= 1'b1;
      end
      else if ((tr_next_state == TX_START) && (tr_state != TX_START)) begin
        // Data has been loaded to shift register, thus data register is free again.
        // Thanks to Lyndon Amsdon for finding a bug here. The TDRE is set to one once
        // entering the state now.
        tdre <= 1'b1;
      end
      else if (cs & ~rw_n & rs & e_clk & ~tx_lock) begin
        tx_lock <= 1'b1;
      end
      else if ((!e_clk) && (tx_lock)) begin
        // This construction clears TDRE after the falling edge of E
        // and after the transmit data register has been written to.
        tdre    <= 1'b0;
        tx_lock <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
    if (tr_state == TX_START) begin
      // Calculate the parity during the start phase.
      par_tmp = (^ shift_reg);
      if ((ws == 3'b000) || (ws == 3'b010) || (ws == 3'b110)) begin
        // Even parity.
        parity_i <= par_tmp;
      end
      else if ((ws == 3'b001) || (ws == 3'b011) || (ws == 3'b111)) begin
        // Odd parity.
        parity_i <= ~par_tmp;
      end
      else begin
        // No parity for WS = "100" and WS = "101".
        parity_i <= 1'b0;
      end
    end
  end

  always @(posedge reset or posedge clk) begin
    if (reset) begin
      tr_state <= TX_IDLE;
    end else begin
      if (mclr) begin
        tr_state <= TX_IDLE;
      end
      else begin
        tr_state <= tr_next_state;
      end
    end
  end

  always @(*) begin
    case(tr_state)
      TX_IDLE : begin
        if ((tdre) && (tc == 2'b11)) begin
          tr_next_state = TX_LOAD_SHIFT;
        end
        else if ((!tdre) && (!cts_n)) begin
          // Start if data register is not empty.
          tr_next_state = TX_LOAD_SHIFT;
        end
        else begin
          tr_next_state = TX_IDLE;
        end
      end
      TX_LOAD_SHIFT : begin
        tr_next_state = TX_START;
      end
      TX_START : begin
        if (clk_strb) begin
          tr_next_state = TX_SHIFTOUT;
        end
        else begin
          tr_next_state = TX_START;
        end
      end
      TX_SHIFTOUT : begin
        if (clk_strb) begin
          if ((bitcnt < 3'd6) && (!ws[2])) begin
            tr_next_state = TX_SHIFTOUT;
            // Transmit 7 data bits.
          end
          else if ((bitcnt < 3'd7) && (ws[2])) begin
            tr_next_state = TX_SHIFTOUT;
            // Transmit 8 data bits.
          end
          else if (ws[2:1] == 2'b10) begin
            if ((tdre) && (tc == 2'b11)) begin
              // Break condition, do not send a stop bit.
              tr_next_state = TX_IDLE;
            end
            else begin
              tr_next_state = TX_STOP1; // No parity check enabled.
            end
          end
          else begin
            tr_next_state = TX_PARITY; // Parity enabled.
          end
        end
        else begin
          tr_next_state = TX_SHIFTOUT;
        end
      end
      TX_PARITY : begin
        if (clk_strb) begin
          if ((tdre) && (tc == 2'b11)) begin
            // Break condition, do not send a stop bit.
            tr_next_state = TX_IDLE;
          end
          else begin
            tr_next_state = TX_STOP1; // No parity check enabled.
          end
        end
        else begin
          tr_next_state = TX_PARITY;
        end
      end
      TX_STOP1 : begin
        if ((clk_strb) && ((ws[2:1] == 2'b00) || (ws[1:0] == 2'b00))) begin
          tr_next_state = TX_STOP2; // Two stop bits selected.
        end
        else if (clk_strb) begin
          tr_next_state = TX_IDLE; // One stop bits selected.
        end
        else begin
          tr_next_state = TX_STOP1;
        end
      end
      TX_STOP2 : begin
        if (clk_strb) begin
          tr_next_state = TX_IDLE;
        end
        else begin
          tr_next_state = TX_STOP2;
        end
      end
      3'h7 : begin
        if (clk_strb) begin
          tr_next_state = TX_IDLE;
        end
        else begin
          tr_next_state = 3'h7;
        end
      end
    endcase
  end

endmodule
