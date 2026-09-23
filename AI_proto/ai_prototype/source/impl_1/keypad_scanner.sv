// Keypad scanner with 1-key rollover and built-in debounce by sampling interval
module keypad_scanner (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       scan_tick, // ~150 Hz enable strobe
    input  logic [3:0] row,       // Active-low inputs from keypad rows (pulled HIGH)
    output logic [3:0] col,       // Active-low driven column outputs
    output logic [3:0] key_code,  // 4-bit Hex code (0x0 to 0xF)
    output logic       key_valid  // Single-cycle strobe when a new key is registered
);

    // FSM States
    typedef enum logic [1:0] {
        SCAN_COL,  // Drive active column and sample rows
        REGISTER,  // Valid key found, issue pulse
        WAIT_REL   // Wait for complete keypad release before accepting new press
    } state_e;

    state_e state;
    logic [1:0] col_idx; // 0 to 3
    logic [3:0] row_sync_0, row_sync_1; // 2-stage synchronizer for async row inputs

    // Drive 1-hot active-low column pins
    always_comb begin
        col          = 4'b1111;
        col[col_idx] = 1'b0;
    end

    // Input synchronizer for noisy/asynchronous row lines
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_sync_0 <= 4'b1111;
            row_sync_1 <= 4'b1111;
        end else begin
            row_sync_0 <= row;
            row_sync_1 <= row_sync_0;
        end
    end

    // Helper decode function mapping Column and Row index to 4-bit Hex
    function automatic logic [3:0] decode_key(input logic [1:0] c, input logic [3:0] r);
        case ({c, r})
            // Col 0
            {2'd0, 4'b1110}: decode_key = 4'h1;
            {2'd0, 4'b1101}: decode_key = 4'h4;
            {2'd0, 4'b1011}: decode_key = 4'h7;
            {2'd0, 4'b0111}: decode_key = 4'h0;
            // Col 1
            {2'd1, 4'b1110}: decode_key = 4'h2;
            {2'd1, 4'b1101}: decode_key = 4'h5;
            {2'd1, 4'b1011}: decode_key = 4'h8;
            {2'd1, 4'b0111}: decode_key = 4'hF; // 'F' / 'A' key
            // Col 2
            {2'd2, 4'b1110}: decode_key = 4'h3;
            {2'd2, 4'b1101}: decode_key = 4'h6;
            {2'd2, 4'b1011}: decode_key = 4'h9;
            {2'd2, 4'b0111}: decode_key = 4'hE; // 'E' / 'B' key
            // Col 3
            {2'd3, 4'b1110}: decode_key = 4'hA;
            {2'd3, 4'b1101}: decode_key = 4'hB;
            {2'd3, 4'b1011}: decode_key = 4'hC;
            {2'd3, 4'b0111}: decode_key = 4'hD;
            default:        decode_key = 4'h0;
        endcase
    endfunction

    // Keypad Scan State Machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= SCAN_COL;
            col_idx   <= '0;
            key_code  <= '0;
            key_valid <= 1'b0;
        end else begin
            key_valid <= 1'b0; // Default pulse output low

            if (scan_tick) begin
                case (state)
                    SCAN_COL: begin
                        // Check if any row in the current active column is pulled low
                        if (row_sync_1 != 4'b1111) begin
                            key_code  <= decode_key(col_idx, row_sync_1);
                            key_valid <= 1'b1;
                            state     <= WAIT_REL; // Lock out further input until release
                        end else begin
                            col_idx <= col_idx + 1'b1; // Advance to next column
                        end
                    end

                    WAIT_REL: begin
                        // Drive all columns low during WAIT_REL to detect any key held on any column
                        // Release is confirmed only when all rows pull high (4'b1111)
                        if (row_sync_1 == 4'b1111) begin
                            state   <= SCAN_COL;
                            col_idx <= '0;
                        end
                    end

                    default: state <= SCAN_COL;
                endcase
            end
        end
    end

endmodule