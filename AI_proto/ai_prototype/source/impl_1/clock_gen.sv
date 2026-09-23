// Clock generation using iCE40 UP5K internal high-speed oscillator (HSOSC)
// Generates single-cycle enable pulses for scanning and multiplexing.
module clock_gen #(
    parameter int CLK_FREQ_HZ  = 24_000_000, // Nominal oscillator frequency
    parameter int SCAN_FREQ_HZ = 150,        // Keypad scan rate (~150 Hz)
    parameter int MUX_FREQ_HZ  = 1000        // Display multiplex frequency (~1 kHz)
)(
    output logic clk,         // Global buffered clock output
    output logic scan_tick,   // Single-cycle pulse at SCAN_FREQ_HZ
    output logic mux_tick     // Single-cycle pulse at MUX_FREQ_HZ
);

    // Instantiate Lattice iCE40 UP5K internal high-speed oscillator
    // CLKHF_DIV = "0b01" configures default output to 24 MHz
    HSOSC #(
        .CLKHF_DIV("0b01")
    ) u_hsosc (
        .CLKHFPU(1'b1),  // Power up
        .CLKHFEN(1'b1),  // Enable output
        .CLKHF  (clk)    // Output clock
    );

    // Counter limits
    localparam int SCAN_LIMIT = CLK_FREQ_HZ / SCAN_FREQ_HZ;
    localparam int MUX_LIMIT  = CLK_FREQ_HZ / MUX_FREQ_HZ;

    int scan_cnt = 0;
    int mux_cnt  = 0;

    always_ff @(posedge clk) begin
        // Scan clock divider
        if (scan_cnt == SCAN_LIMIT - 1) begin
            scan_cnt  <= 0;
            scan_tick <= 1'b1;
        end else begin
            scan_cnt  <= scan_cnt + 1;
            scan_tick <= 1'b0;
        end

        // Mux clock divider
        if (mux_cnt == MUX_LIMIT - 1) begin
            mux_cnt  <= 0;
            mux_tick <= 1; // mux_tick pulse
            mux_tick <= 1'b1;
        end else begin
            mux_cnt  <= mux_cnt + 1;
            mux_tick <= 1'b0;
        end
    end

endmodule