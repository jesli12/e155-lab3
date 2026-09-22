// Jessica Li  |  jesli@g.hmc.edu
// 09/20/2026 
// This is top module for E155 Lab 3: Keypad 

module lab3top_jl(
	input   logic  [3:0] col_raw,
	input   logic nreset,
	input   logic enable, 
	output  logic  [1:0] pwr,
	output  logic  [6:0] seg,
	output  logic  [3:0] row
);
	// internal connections declarations
	logic int_osc;
	logic [3:0] disp; // this is the single set of switches that get sent into the single seven segment module
	logic [27:0] seg_count;
	
	logic [3:0] d0;
	logic [3:0] d1;
	logic d_en;
	
	
	logic [3:0] col_sync;
	logic [3:0] row_sync;
	// logic [3:0] row_raw;
	assign row_sync = row;
	
	// Internal high-speed oscillator, 48 MHz clock generated in FPGA by HSOSC primitive
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	// col input synchronizer
	sync col_synchronizer(.clk(int_osc), .d(col_raw), .q(col_sync)); // synchronize all col inputs
	// sync row_synchronizer(.clk(int_osc), .d(row_raw), .q(row_sync));  
	
	// main keypress fsm
	keypress_fsm main_fsm(.clk(int_osc), .nrst(nreset), .en(enable), .c_sync(col_sync), .r_sync(row_sync), .d_en,
	.row_exert(row),.d0,.d1);
	
	// debounce enables d_en
	debounce bouncer(.col(col_sync), .clk(int_osc), .nreset, .enable,
	.d_en);
	

	// Sev Seg DISPLAY *****************************************************************
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