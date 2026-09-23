// Jessica Li  |  jesli@g.hmc.edu
// 09/22/2026 
// This is top module for E155 Lab 3: Keypad 

module lab3top_jl(
	input   logic  [3:0] col_raw,
	input   logic nreset,
	input   logic enable, 
	output  logic  [1:0] pwr,
	output  logic  [6:0] seg,
	output  logic  [3:0] row,
	output  logic  [2:0] debug_led // displays which of the 3 states in main fsm is active
);
	//**************** internal connections declarations ****************
	logic int_osc;
	logic [3:0] col_sync;
	
		// dual sev-seg display ports
	logic [3:0] disp; // this is the single set of switches that get sent into the single seven segment module
	logic [27:0] seg_count;
	
		// debouncer submodule output
	logic d_en;
	
		// keypress submodule outputs
	logic   one_key;
	logic   [1:0] col_index; //pressed column = col_sync[col_index] [not used]
	logic   [3:0] key_next;
	logic   [15:0] keymap;
	
		// keypress_fsm internal outputs (main fsm: scan --> press --> hold)
	logic [3:0] d0;
	logic [3:0] d1;
	
	// **************** SUBMODULE INSTANTIATIONS ****************
	// Internal high-speed oscillator, 48 MHz clock generated in FPGA by HSOSC primitive
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	
	// Scanner (row exerter) (scanning at 150 Hz)
	scanner #(.WIDTH(25), .MAX_COUNT(320000)) scanning(.int_osc, .nreset, .enable, .rows(row));

	// col input synchronizer (col asynch inputs need to be sync-ed)
	sync col_synchronizer(.clk(int_osc), .d(col_raw), .q(col_sync)); // synchronize all col inputs
		
	// debounce enables d_en
	debounce_fsm debouncer(.keymap, .clk(int_osc), .nreset, .enable, .d_en);

	// keypress logic (creates key map and outputs if one key is true and what that key is (key_next))
	keypress press_logic(.clk(int_osc), .nrst(nreset), .en(enable), .c_sync(col_sync), .r_sync(row), .one_press(one_key), .col_index, .key_next , .map(keymap));
	
	// main keypress fsm
	keypress_fsm main_fsm(.clk(int_osc), .nrst(nreset), .en(enable),.one_key,.key_next, .d_en, .d0, .d1, .db_led(debug_led));

	// Sev Seg DISPLAY 
	dual_display dual(.int_osc, .nreset, .enable,.d0, .d1, .pwr, .seg);

endmodule