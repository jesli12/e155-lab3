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
	output  logic   [3:0] d1,
	output  logic   [2:0] db_led,
	output  logic   [15:0] keymap
);
	typedef enum logic [2:0] {SCAN = 3'b001, PRESS = 3'b010,
							  HOLD = 3'b100} statetype;
	statetype state, nextstate;
	logic one_key;
	logic [3:0] key_next;
	logic [1:0] col_index;
	
	keypress press_logic(.clk, .nrst, .en, .c_sync, .r_sync, .one_press(one_key), .col_index, .key_next , .map(keymap));
	
	// Scanner (row exerter)
	logic nrst_scan;
	logic en_scan;
	scanner #(.WIDTH(25), .MAX_COUNT(320000)) scanning(.int_osc (clk), .nreset (nrst_scan), .enable (en_scan), .rows (row_exert));
	// ^^^ scanner is scanning at 150 Hz
	
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
		
	assign nrst_scan = nrst;
	assign en_scan = en;

	logic [3:0] d_write;
	
	always_ff @(posedge clk, posedge ~nrst) begin
		if (~nrst)
			d_write <= 4'h0;
		else
			d_write <= key_next;
	end
	
	always_ff @(posedge clk, posedge ~nrst)
		if (~nrst) begin
			d0 <= 4'h0;
			d1 <= 4'h0;
			db_led <= 3'b000;
		end else begin
			if (state == PRESS) begin
				db_led[1] <= 1'b1;
				db_led[0] <= 0;
				db_led[2] <= 0;
				d1 <= d0;
				d0 <= d_write; // combinational decode of {rows, cols}
			end
			else if (state == SCAN)begin
				db_led[0] <= 1'b1;
				db_led[1] <= 0;
				db_led[2] <= 0; end
			else begin
				db_led[2] <= 1'b1;
				db_led[1:0] <= 2'b00;
			end
		end

endmodule