// Display controller driving a 2-digit common-anode or common-cathode display
module display_mux (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       mux_tick,   // ~1 kHz multiplex tick
    input  logic [3:0] hex_digit1, // Most recent key (left digit)
    input  logic [3:0] hex_digit0, // Older key (right digit)
    output logic [1:0] digit_select, // Digit enable lines (Active-Low)
    output logic [6:0] segments     // Segments [a,b,c,d,e,f,g] (Active-Low)
);

    logic sel; // 0 = Digit 0, 1 = Digit 1
    logic [3:0] current_hex;

    // Hex to Active-Low 7-Segment Decoder (abcdefg)
    function automatic logic [6:0] hex_to_7seg(input logic [3:0] hex);
        case (hex)
            4'h0: hex_to_7seg = 7'b000_0001;
            4'h1: hex_to_7seg = 7'b100_1111;
            4'h2: hex_to_7seg = 7'b001_0010;
            4'h3: hex_to_7seg = 7'b000_0110;
            4'h4: hex_to_7seg = 7'b100_1100;
            4'h5: hex_to_7seg = 7'b010_0100;
            4'h6: hex_to_7seg = 7'b010_0000;
            4'h7: hex_to_7seg = 7'b000_1101;
            4'h8: hex_to_7seg = 7'b000_0000;
            4'h9: hex_to_7seg = 7'b000_0100;
            4'hA: hex_to_7seg = 7'b000_1000;
            4'hB: hex_to_7seg = 7'b110_0000;
            4'hC: hex_to_7seg = 7'b011_0001;
            4'hD: hex_to_7seg = 7'b100_0010;
            4'hE: hex_to_7seg = 7'b011_0000;
            4'hF: hex_to_7seg = 7'b011_1000;
            default: hex_to_7seg = 7'b111_1111;
        endcase
    endfunction

    // Multiplexer state toggle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel <= 1'b0;
        end else if (mux_tick) begin
            sel <= ~sel;
        end
    end

    // Synchronous output assignment matching active multiplex digit
    always_comb begin
        current_hex  = sel ? hex_digit1 : hex_digit0;
        digit_select = sel ? 2'b10 : 2'b01; // Active-Low digit select lines
        segments     = hex_to_7seg(current_hex);
    end

endmodule