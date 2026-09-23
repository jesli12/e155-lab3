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
	logic [3:0] row_sync;
	assign row_sync = row; // left in case sync-ing rows to delay from col_sync is necessary
	
		// dual sev-seg display ports
	logic [3:0] disp; // this is the single set of switches that get sent into the single seven segment module
	logic [27:0] seg_count;
	logic [3:0] d0;
	logic [3:0] d1;
	
	logic d_en;

		// keypress_fsm ports (main fsm: scan --> press --> hold)
	logic [15:0] keymap;
	
	// Internal high-speed oscillator, 48 MHz clock generated in FPGA by HSOSC primitive
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	
	// Scanner (row exerter) (scanning at 150 Hz)
	scanner #(.WIDTH(25), .MAX_COUNT(320000)) scanning(.int_osc, .nreset, .enable, .rows(row));

	// col input synchronizer (col asynch inputs need to be sync-ed)
	sync col_synchronizer(.clk(int_osc), .d(col_raw), .q(col_sync)); // synchronize all col inputs
	// no need for row sync, since it is already synchronous output
	// sync row_synchronizer(.clk(int_osc), .d(row_raw), .q(row_sync));  
	
	// debounce enables d_en
	debounce_fsm bouncer(.keymap, .clk(int_osc), .nreset, .enable, .d_en);
	
	// main keypress fsm
	keypress_fsm main_fsm(.clk(int_osc), .nrst(nreset), .en(enable), .c_sync(col_sync), .r_sync(row_sync), .d_en, .d0, .d1, .db_led(debug_led), .keymap);
	

	// ****************Sev Seg DISPLAY *****************************************************************
	// counter for timing multiplexer (120 Hz)
	counter #(
		.WIDTH(28),
		.MAX_COUNT(400_000) // MAX_COUNT = 200_000 = a signal on/off frequency of 120 Hz
	) segment_counter (
		.osc (int_osc), 
		.nrst (nreset),  
		.en (enable),
		.count (seg_count) // purposely ignored, no use
	);
	
	// switch-to-7 segment display module
	sev_seg segment_decoder(.switch (disp), .segment(seg));
	
	assign pwr = (seg_count < 200_000)? 2'b01 : 2'b10;
	assign disp = (seg_count < 200_000)? d0 : d1;	   // MUX: seg_clk == 0 --> sw1 + first display on, seg_clk ==1 --> sw2 + second display on (see above)
	

endmodule