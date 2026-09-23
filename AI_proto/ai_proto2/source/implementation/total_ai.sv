// Keypad Edge & Debounce One-Shot Register Module
// Target: Lattice iCE40 UP5K

module keypad_oneshot #(
    parameter int CLK_FREQ_HZ = 12_000_000, // Default iCE40 internal oscillator speed
    parameter int DEBOUNCE_MS = 20           // Debounce period in milliseconds
) (
    input  logic       clk,         // System clock
    input  logic       rst_n,       // Active-low asynchronous reset
    input  logic       raw_valid,   // Keypad row detect (1 = key pressed, 0 = no key)
    input  logic [3:0] raw_code,    // Unstable key code corresponding to raw_valid
    output logic [3:0] registered_code, // Captured key code on valid press
    output logic       key_strobe   // Single-cycle glitch-free output pulse on new key
);

  // Calculate counter limit for debounce timer
  localparam int TIMER_LIMIT = (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;
  localparam int TIMER_BITS  = $clog2(TIMER_LIMIT > 0 ? TIMER_LIMIT : 1);

  // FSM State Enumeration
  typedef enum logic [2:0] {
    STATE_IDLE,
    STATE_DEBOUNCE_PRESS,
    STATE_REGISTER,
    STATE_WAIT_RELEASE,
    STATE_DEBOUNCE_RELEASE
  } state_e;

  state_e current_state, next_state;

  // 3-Stage Synchronizer for Asynchronous Input
  logic [2:0] valid_sync;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_sync <= '0;
    end else begin
      valid_sync <= {valid_sync[1:0], raw_valid};
    end
  end
  
  logic valid_deb; // Synchronized valid signal
  assign valid_deb = valid_sync[2];

  // Debounce Counter Logic
  logic [TIMER_BITS-1:0] timer_cnt;
  logic                  timer_clear;
  logic                  timer_expired;

  assign timer_expired = (timer_cnt >= TIMER_LIMIT - 1);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      timer_cnt <= '0;
    end else if (timer_clear) begin
      timer_cnt <= '0;
    end else if (!timer_expired) begin
      timer_cnt <= timer_cnt + 1'b1;
    end
  end

  // FSM Sequential State Register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= STATE_IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // FSM Combinational Next State Logic
  always_comb begin
    next_state  = current_state;
    timer_clear = 1'b0;

    case (current_state)
      STATE_IDLE: begin
        if (valid_deb) begin
          timer_clear = 1'b1;
          next_state  = STATE_DEBOUNCE_PRESS;
        end
      end

      STATE_DEBOUNCE_PRESS: begin
        if (!valid_deb) begin
          // False trigger or noise bounce
          next_state = STATE_IDLE;
        end else if (timer_expired) begin
          next_state = STATE_REGISTER;
        end
      end

      STATE_REGISTER: begin
        // Single-cycle transition state
        next_state = STATE_WAIT_RELEASE;
      end

      STATE_WAIT_RELEASE: begin
        if (!valid_deb) begin
          timer_clear = 1'b1;
          next_state  = STATE_DEBOUNCE_RELEASE;
        end
      end

      STATE_DEBOUNCE_RELEASE: begin
        if (valid_deb) begin
          // Key was pressed again during release debounce
          next_state = STATE_WAIT_RELEASE;
        end else if (timer_expired) begin
          next_state = STATE_IDLE;
        end
      end

      default: next_state = STATE_IDLE;
    endcase
  end

  // Output Registers & Code Latching (Glitch-Free Output Generation)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      registered_code <= 4'h0;
      key_strobe      <= 1'b0;
    end else begin
      if (current_state == STATE_DEBOUNCE_PRESS && timer_expired) begin
        // Sample key code only when debounce timer successfully completes
        registered_code <= raw_code;
      end

      // Registered strobe output ensures clean single-cycle pulse
      if (current_state == STATE_REGISTER) begin
        key_strobe <= 1'b1;
      end else begin
        key_strobe <= 1; // Register pulse cleared automatically
      end
    end
  end

endmodule

// 4x4 Keypad Matrix Scanner Module
// Target: Lattice iCE40 UP5K FPGA

module keypad_scanner #(
    parameter int CLK_FREQ_HZ  = 12_000_000, // System clock frequency (Hz)
    parameter int SCAN_RATE_HZ = 1_000       // Column scan frequency (Hz)
) (
    input  logic       clk,         // System clock
    input  logic       rst_n,       // Active-low asynchronous reset
    input  logic [3:0] rows,        // Keypad Row Inputs (Active-low with internal pull-ups)
    output logic [3:0] cols,        // Keypad Column Outputs (Active-low, driven)
    output logic [3:0] raw_code,    // Mapped hex key code (0x0..0xF)
    output logic       raw_valid    // High when any key is currently pressed
);

  // Scan Counter Limit
  localparam int SCAN_LIMIT = CLK_FREQ_HZ / (SCAN_RATE_HZ * 4);
  localparam int CNT_BITS   = $clog2(SCAN_LIMIT > 0 ? SCAN_LIMIT : 1);

  // 3-Stage Input Synchronizer on Rows (Active-Low)
  logic [3:0] rows_sync_0, rows_sync_1, rows_sync;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rows_sync_0 <= 4'hF;
      rows_sync_1 <= 4'hF;
      rows_sync   <= 4'hF;
    end else begin
      rows_sync_0 <= rows;
      rows_sync_1 <= rows_sync_0;
      rows_sync   <= rows_sync_1;
    end
  end

  // Scan Timer & Column State
  logic [CNT_BITS-1:0] scan_cnt;
  logic [1:0]          col_index;
  logic                key_detected;

  // Active-low row detection: key_detected is 1 if any row line is driven low (0)
  assign key_detected = (rows_sync != 4'b1111);

  // Column Drive Output (Active-Low One-Hot)
  always_comb begin
    case (col_index)
      2'd0:    cols = 4'b1110;
      2'd1:    cols = 4'b1101;
      2'd2:    cols = 4'b1011;
      2'd3:    cols = 4'b0111;
      default: cols = 4'b1111;
    endcase
  end

  // Scan Logic: Advance columns only when NO key is currently pressed
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      scan_cnt  <= '0;
      col_index <= 2'd0;
    end else if (!key_detected) begin
      if (scan_cnt >= SCAN_LIMIT - 1) begin
        scan_cnt  <= '0;
        col_index <= col_index + 1'b1;
      end else begin
        scan_cnt <= scan_cnt + 1'b1;
      end
    end
    // If key_detected == 1, scan_cnt and col_index hold their current values
  end

  // Key Decode Table (Standard Matrix Layout Mapping)
  //
  // Layout Matrix:
  //            Col 0 (0)  Col 1 (1)  Col 2 (2)  Col 3 (3)
  // Row 0 (0):    1          2          3          A
  // Row 1 (1):    4          5          6          B
  // Row 2 (2):    7          8          9          C
  // Row 3 (3):    E (*)      0          F (#)      D

  logic [3:0] decoded_hex;

  always_comb begin
    case ({col_index, rows_sync})
      // Column 0
      {2'd0, 4'b1110}: decoded_hex = 4'h1; // R0
      {2'd0, 4'b1101}: decoded_hex = 4'h4; // R1
      {2'd0, 4'b1011}: decoded_hex = 4'h7; // R2
      {2'd0, 4'b0111}: decoded_hex = 4'hE; // R3 (*)

      // Column 1
      {2'd1, 4'b1110}: decoded_hex = 4'h2; // R0
      {2'd1, 4'b1101}: decoded_hex = 4'h5; // R1
      {2'd1, 4'b1011}: decoded_hex = 4'h8; // R2
      {2'd1, 4'b0111}: decoded_hex = 4'h0; // R3 (0)

      // Column 2
      {2'd2, 4'b1110}: decoded_hex = 4'h3; // R0
      {2'd2, 4'b1101}: decoded_hex = 4'h6; // R1
      {2'd2, 4'b1011}: decoded_hex = 4'h9; // R2
      {2'd2, 4'b0111}: decoded_hex = 4'hF; // R3 (#)

      // Column 3
      {2'd3, 4'b1110}: decoded_hex = 4'hA; // R0
      {2'd3, 4'b1101}: decoded_hex = 4'hB; // R1
      {2'd3, 4'b1011}: decoded_hex = 4'hC; // R2
      {2'd3, 4'b0111}: decoded_hex = 4'hD; // R3

      default: decoded_hex = 4'h0;
    endcase
  end

  // Synchronous Output Assignment
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      raw_code  <= 4'h0;
      raw_valid <= 1'b0;
    end else begin
      raw_valid <= key_detected;
      if (key_detected) begin
        raw_code <= decoded_hex;
      end
    end
  end

endmodule

// Top-Level Keypad Scan & Dual 7-Segment Display Module
// Target Device: Lattice iCE40 UP5K

module top_keypad_display (
    // Hard Reset (e.g., active-low onboard button or external reset)
    input  logic       ext_rst_n,

    // 4x4 Keypad Interfaces
    input  logic [3:0] keypad_rows,  // Active-low inputs with pull-ups
    output logic [3:0] keypad_cols,  // Active-low column drivers

    // Dual 7-Segment Display Interfaces
    output logic [6:0] seg_out,     // Active-low segment outputs (a-g)
    output logic [1:0] digit_sel    // Active-low digit selects (Digit 0, Digit 1)
);

  // System Clock Generation using iCE40 Internal High-Frequency Oscillator
  // TRM Settings: CLKHF_DIV = "0b10" yields a 12 MHz clock output
  logic clk;

  SB_HFOSC #(
      .CLKHF_DIV("0b10") // Divide internal 48MHz by 4 = 12MHz
  ) u_hfosc (
      .CLKHFPU(1'b1),    // Power up oscillator
      .CLKHFEN(1'b1),    // Enable oscillator output
      .CLKHF  (clk)
  );

  // Power-On Reset Synchronizer
  logic [1:0] rst_sync;
  logic       sys_rst_n;

  always_ff @(posedge clk or negedge ext_rst_n) begin
    if (!ext_rst_n) begin
      rst_sync  <= 2'b00;
      sys_rst_n <= 1'b0;
    end else begin
      rst_sync  <= {rst_sync[0], 1'b1};
      sys_rst_n <= rst_sync[1];
    end
  end

  // Interconnect Signals
  logic [3:0] raw_code;
  logic       raw_valid;
  logic [3:0] registered_code;
  logic       key_strobe;

  // Keypad Scanner Instance
  keypad_scanner #(
      .CLK_FREQ_HZ (12_000_000),
      .SCAN_RATE_HZ(1_000)
  ) u_scanner (
      .clk      (clk),
      .rst_n    (sys_rst_n),
      .rows     (keypad_rows),
      .cols     (keypad_cols),
      .raw_code (raw_code),
      .raw_valid(raw_valid)
  );

  // Keypad One-Shot Debouncer Instance
  keypad_oneshot #(
      .CLK_FREQ_HZ (12_000_000),
      .DEBOUNCE_MS (20)
  ) u_oneshot (
      .clk            (clk),
      .rst_n          (sys_rst_n),
      .raw_valid      (raw_valid),
      .raw_code       (raw_code),
      .registered_code(registered_code),
      .key_strobe     (key_strobe)
  );

  // 2-Digit Hex Key History Shift Register
  logic [3:0] digit_hi; // Older key
  logic [3:0] digit_lo; // Most recent key

  always_ff @(posedge clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      digit_hi <= 4'h0;
      digit_lo <= 4'h0;
    end else if (key_strobe) begin
      digit_hi <= digit_lo;         // Shift older key to high digit
      digit_lo <= registered_code;  // Load new key into low digit
    end
  end

  // Multiplexer Refresh Counter (~1 kHz refresh rate, 500 Hz per digit)
  // 12 MHz / 12,000 = 1 kHz refresh period (12-bit counter)
  localparam int MUX_LIMIT = 12_000;
  logic [$clog2(MUX_LIMIT)-1:0] refresh_cnt;
  logic                         active_digit;

  always_ff @(posedge clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      refresh_cnt  <= '0;
      active_digit <= 1'b0;
    end else begin
      if (refresh_cnt >= MUX_LIMIT - 1) begin
        refresh_cnt  <= '0;
        active_digit <= ~active_digit; // Toggle digit display selection
      end else begin
        refresh_cnt <= refresh_cnt + 1'b1;
      end
    end
  end

  // Active Hex Nibble Selection
  logic [3:0] current_nibble;
  assign current_nibble = (active_digit == 1'b0) ? digit_lo : digit_hi;

  // External 7-Segment Decoder Instance
  logic [6:0] decoded_segments;
  sevenSegment u_7seg_decoder (
      .hex_in  (current_nibble),
      .seg_out (decoded_segments)
  );

  // Synchronous Output Register (Eliminates glitches during switching)
  always_ff @(posedge clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      seg_out   <= 7'b111_1111; // Blank display on reset
      digit_sel <= 2'b11;       // Both digits disabled
    end else begin
      seg_out <= decoded_segments;

      // Active-low digit enablement
      if (active_digit == 1) begin
        digit_sel <= 2'b10; // Enable Digit 0 (Low)
      end else begin
        digit_sel <= 2'b01; // Enable Digit 1 (High)
      end
    end
  end

endmodule