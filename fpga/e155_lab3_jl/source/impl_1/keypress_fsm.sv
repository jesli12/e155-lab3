// Jessica Li  |  jesli@g.hmc.edu
// 09/21/2026 
// submodule for the keypress FSM (main FSM) that does the following:
// States: SCAN, PRESS, HOLD

module keypress_fsm(
	input   logic   clk, nrst, en,
	input 	logic 	[3:0] c_sync,
	input   logic   [3:0] r_sync,
	input   logic   d_en,
	output  logic   [3:0] row_exert,
	output  logic   [3:0] d0,
	output  logic   [3:0] d1
);
	typedef enum logic [2:0] {SCAN = 3'b001, PRESS = 3'b010,
							  HOLD = 3'b100} statetype;
	statetype state, nextstate;
	logic one_key;
	logic [3:0] col_index;
	logic [3:0] key_next;
	
	// logic any_key;
	// assign any_key = ~&c_sync; // low-asserted: any column pulled down
	keypress press_logic(.clk, .nrst, .en, .c_sync, .r_sync, .one_press(one_key), .col_index, .key_next );
	
	// Scanner (row exerter)
	logic nrst_scan;
	logic en_scan;
	scanner #(.WIDTH(20), .MAX_COUNT(524_289)) scanning(.int_osc (clk), .nreset (nrst_scan), .enable (en_scan), .rows (row_exert));
	
	
	// keypress fsm
	always_ff @(posedge clk, posedge ~nrst)
		if (~nrst) state <= SCAN;
		else state <= nextstate;
	
	always_comb
		case (state)
			SCAN: nextstate = (one_key & d_en) ? PRESS : SCAN;
			PRESS: nextstate = HOLD;
			HOLD: nextstate = one_key ? HOLD : SCAN; // CHECK SAME KEY [TO BE IMPLEMENTED]             
			default: nextstate = SCAN;
		endcase
		
	assign nrst_scan = nrst;
	assign en_scan = (state == SCAN); // moment one key and debounce are true --> press state stops scan rotation and freezes at row of detection
	
	always_ff @(posedge clk, posedge ~nrst)
		if (~nrst) begin
			d0 <= 4'h0;
			d1 <= 4'h0;
		end else begin
			if (state == PRESS) begin
				d1 <= d0;
				d0 <= key_next; // combinational decode of {rows, cols}
			end
		end

endmodule