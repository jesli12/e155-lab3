// Jessica Li  |  jesli@g.hmc.edu
// 09/21/2026 
// submodule for the keypress FSM (main FSM) that does the following:
// States: SCAN, PRESS, HOLD

module keypress_fsm(
	input   logic   clk, nrst,
	input 	logic 	[3:0] c_sync,
	input   logic   d_en,
	output  logic   [3:0] row_exert,
	output  logic   [3:0] d0,
	output  logic   [3:0] d1
);
	typedef enum logic [2:0] {SCAN = 3'b001, PRESS = 3'b010,
							  HOLD = 3'b100} statetype;
	statetype state, nextstate;
	logic one_key;
	
	// JESSICA GOTTA WRITE "PRESS" LOGIC (ONE KEY)
	assign one_key = ~&c_sync; // low-asserted: any column pulled down
	
	always_ff @(posedge clk, posedge ~nrst)
		if (~nrst) state <= SCAN;
		else state <= nextstate;
	
	always_comb
		case (state)
			SCAN: nextstate = (one_key & d_en) ? PRESS : SCAN;
			PRESS: nextstate = HOLD;
			HOLD: nextstate = one_key ? HOLD : SCAN; // CHECK SAME KEY              
			default: nextstate = SCAN;
		endcase
	
	always_ff @(posedge clk, posedge ~nrst)
		if (~nrst) begin
			row_exert <= 4'b0111;
			d0 <= 4'h0;
			d1 <= 4'h0;
		end else begin
			// Only SCAN moves the row pattern. Everything else freezes it.
			if (state == SCAN && !one_key) 
				row_exert <= {row_exert[0], row_exert[3:1]};
			if (state == PRESS) begin
				d1 <= d0;
				d0 <= key; // combinational decode of {rows, cols}
			end
		end

endmodule