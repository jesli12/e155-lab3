// Jessica Li  |  jesli@g.hmc.edu
// 09/20/2026 
// This is a submodule that contains a FSM that communicates with the main canonicl FSM on when the keypad's switches have been debounced
// (post debounce wait time, key press signals are stabilized)

// STILL NEED TO DECIDE STEP DOWN SAMPLING VALUE OF MAX COUNT AND SET COUNT_NUM LIMITATIONS TO MATCH


module debounce(
	input   logic   [3:0] col, 
	input 	logic 	 clk, nreset, enable,
	output  logic   [3:0] d_en
);

	typedef enum logic [1:0] {IDLE, WAIT, PRESSED} statetype;
	statetype state, nextstate;

	logic [19:0] count_num;

	always_ff @(posedge clk, posedge ~nreset)
		if (~nreset) state <= IDLE;
		else state <= nextstate;

	// The FSM owns the counter: cleared in IDLE, running everywhere else.
	counter #(
		.WIDTH(20),
		.MAX_COUNT(524_288) // MAX_COUNT = 524,288 about 10.9 ms (based on 48Mhz base clk)
	) debounce_counter (
		.osc (clk), 
		.nrst (~(state == IDLE)),  // in state idle, counter <= 0
		.en (~(state == IDLE)), // in any other state, counter increment
		.count (count_num) 
	);
	
	always_comb
		case (state)
			IDLE: nextstate = (~(col == 4'b1111)) ? WAIT : IDLE;
			WAIT: if (col == 4'b1111)) nextstate = IDLE; // a bounce
				else if (count_num[19]) nextstate = PRESSED;
				else nextstate = WAIT;
			PRESSED: nextstate = sw ? PRESSED : IDLE;
			default: nextstate = IDLE;
		endcase

	assign d_en = (state == PRESSED);
	
		
endmodule