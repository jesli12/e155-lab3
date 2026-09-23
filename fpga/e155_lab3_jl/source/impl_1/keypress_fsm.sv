// Jessica Li  |  jesli@g.hmc.edu
// 09/21/2026 
// submodule for the keypress FSM (main FSM) that does the following:
// States: SCAN, PRESS, HOLD

module keypress_fsm(
	input   logic   clk, nrst, en,
	input 	logic 	[3:0] c_sync,
	input   logic   [3:0] r_sync,
	input   logic   d_en,

	output  logic   [3:0] d0,
	output  logic   [3:0] d1,
	output  logic   [2:0] db_led,
	output  logic   [15:0] keymap
);
	typedef enum logic [2:0] {SCAN = 3'b001, PRESS = 3'b010,
							  HOLD = 3'b100} statetype;
	statetype state, nextstate;
	logic one_key;
	logic [3:0] key_next;
	logic [1:0] col_index; // unused
	
	keypress press_logic(.clk, .nrst, .en, .c_sync, .r_sync, .one_press(one_key), .col_index, .key_next , .map(keymap));
	
	// keypress fsm
	always_ff @(posedge clk, posedge ~nrst)
		if (~nrst) state <= SCAN;
		else state <= nextstate;
	
	always_comb
		case (state)
			SCAN: nextstate = (one_key & d_en) ? PRESS : SCAN; //& d_en is to ensure debounce FSM has been successful
			PRESS: nextstate = HOLD;
			HOLD: nextstate = (~one_key) ? SCAN : HOLD;           
			default: nextstate = SCAN;
		endcase

	logic [3:0] d_write; // mid register to prevent double

	// state output logic
	always_ff @(posedge clk, posedge ~nrst)
		if (~nrst) begin
			d0 <= 4'h0;
			d1 <= 4'h0;
			db_led <= 3'b000;
			d_write <= 4'h0;
		end else begin
			d_write <= key_next; // combinational decode of {rows, cols}
			if (state == PRESS) begin
				db_led <= 3'b010;
				d1 <= d0;
				d0 <= d_write; 
			end else if (state == SCAN)begin
				db_led <= 3'b001;
			end else begin
				db_led <= 3'b100; // state == hold
			end
		end

endmodule