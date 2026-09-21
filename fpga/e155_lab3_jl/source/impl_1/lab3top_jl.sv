// Jessica Li  |  jesli@g.hmc.edu
// 09/20/2026 
// This is top module for E155 Lab 3: Keypad 

module lab3top_jl(
	input   logic  [3:0] col_raw,
	input   logic nreset,
	input   logic enable, 
	output  logic  [1:0] pwr,
	output  logic  [6:0] seg,
	output  logic  [3:0] row,
	output  logic  [3:0] led 
);
	// internal connections declarations
	logic int_osc;
	logic seg_clk;
	logic [3:0] sw; // this is the single set of switches that get sent into the single seven segment module
	
	logic [3:0] col_sync;
	logic [3:0] row_sync;
	
	// Internal high-speed oscillator, 48 MHz clock generated in FPGA by HSOSC primitive
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	
	// col input synchronizer
	sync col_synchronizer(.clk(int_osc), .d(col_raw), .q(col_sync)); // synchronize all col omputs
	sync row_synchronizer(.clk(int_osc), .d(row), .q(row_sync));  // Q: do i neet a reset for these?
	

	// Sev Seg DISPLAY *****************************************************************
	// counter for timing multiplexer (120 Hz)
	counter #(
		.WIDTH(28),
		.MAX_COUNT(200_000) // MAX_COUNT = 200_000 = a signal on/off frequency of 120 Hz
	) segment_counter (
		.osc (int_osc), 
		.nrst (nreset),  
		.en (enable),
		.clk (seg_clk),
		.count () // purposely ignored, no use
	);
	
	// switch-to-7 segment display module
	sev_seg segment_decoder(
		.switch (sw), 
		.segment (seg) // this already outputs for segment display
	);
	
	
	assign pwr[0] = seg_clk;
	assign pwr[1] = ~seg_clk;
	assign sw = (seg_clk)? sw1 : sw2;	   // MUX: seg_clk == 0 --> sw1 + first display on, seg_clk ==1 --> sw2 + second display on (see above)
	
	

endmodule