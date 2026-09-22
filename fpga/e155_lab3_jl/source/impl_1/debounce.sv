// Jessica Li  |  jesli@g.hmc. 
// 09/20/2026 
// This is a submodule that contains a FSM that communicates with the main canonicl FSM on when the keypad's switches have been debounced
// (post debounce wait time, key press signals are stabilized)

module debounce(
	input   logic   [3:0] col, 
	input 	logic 	 clk, nreset, enable,
	output  logic   d_en
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
		.MAX_COUNT(524_289) // MAX_COUNT = 524,288 about 10.9 ms (based on 48Mhz base clk) (base 2 to minimize hardware)
	) debounce_counter (
		.osc (clk), 
		.nrst (~(state == IDLE)),  // in state idle, counter <= 0
		.en ((state == WAIT)), // in any other state, counter increment
		.count (count_num) 
	);
	
	always_comb
		case (state)
			IDLE: nextstate = (~(col == 4'b1111)) ? WAIT : IDLE;
			WAIT: if (col == 4'b1111) nextstate = IDLE; // a bounce
				else if (count_num[19]&~(col == 4'b1111)) nextstate = PRESSED;
				else nextstate = WAIT;
			PRESSED: nextstate = (~(col == 4'b1111)) ? PRESSED : IDLE;
			default: nextstate = IDLE;
		endcase

	assign d_en = (state == PRESSED);
	
		
endmodule