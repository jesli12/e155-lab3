// Top-Level Module integrating key scanning and 2-digit display tracking
module top_keypad_display (
    input  logic       rst_n,        // Active-low global reset button
    input  logic [3:0] kp_rows,      // Matrix keypad inputs (Active-Low)
    output logic [3:0] kp_cols,      // Matrix keypad column drives (Active-Low)
    output logic [1:0] digit_select, // Active-Low digit cathode/anode enables
    output logic [6:0] segments     // Active-Low segment lines [a,b,c,d,e,f,g]
);

    // Internal Signal Interconnects
    logic clk;
    logic scan_tick;
    logic mux_tick;
    logic key_valid;
    logic [3:0] scanned_key;

    // Registers to hold last two pressed keys
    logic [3:0] recent_key;
    logic [3:0] older_key;

    // 1. Clock Generation Instance
    clock_gen #(
        .CLK_FREQ_HZ (24_000_000),
        .SCAN_FREQ_HZ(150),
        .MUX_FREQ_HZ (1000)
    ) u_clock_gen (
        .clk      (clk),
        .scan_tick(scan_tick),
        .mux_tick (mux_tick)
    );

    // 2. Keypad Scanner Instance
    keypad_scanner u_keypad_scanner (
        .clk      (clk),
        .rst_n    (rst_n),
        .scan_tick(scan_tick),
        .row      (kp_rows),
        .col      (kp_cols),
        .key_code (scanned_key),
        .key_valid(key_valid)
    );

    // 3. Shift Register for tracking key history
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            recent_key <= 4'h0;
            older_key  <= 4'h0;
        end else if (key_valid) begin
            older_key  <= recent_key;   // Shift previous key into history
            recent_key <= scanned_key;  // Store new key
        end
    end

    // 4. Multiplexed Display Instance
    display_mux u_display_mux (
        .clk         (clk),
        .rst_n       (rst_n),
        .mux_tick    (mux_tick),
        .hex_digit1  (recent_key),  // Left digit: most recent key
        .hex_digit0  (older_key),   // Right digit: older key
        .digit_select(digit_select),
        .segments    (segments)
    );

endmodule