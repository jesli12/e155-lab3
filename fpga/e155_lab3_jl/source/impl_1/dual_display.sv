// Jessica Li  |  jesli@g.hmc.edu
// 09/22/2026
// This is a submodule.

module dual_display(
	input   logic int_osc, nreset, enable,
	input  logic   [3:0] d0,
	input  logic   [3:0] d1,
	output  logic  [1:0] pwr,
	output  logic  [6:0] seg
);
	logic [3:0] disp; // this is the single set of switches that get sent into the single seven segment module
	logic [27:0] seg_count;
	// counter for timing multiplexer (120 Hz)
	counter #(
		.WIDTH(28),
		.MAX_COUNT(400_000) // MAX_COUNT = 200_000 = a signal on/off frequency of 120 Hz
	) segment_counter (
		.osc (int_osc), 
		.nrst (nreset),  
		.en (enable),
		.count (seg_count) 
	);
	
	// switch-to-7 segment display module
	sev_seg segment_decoder(.switch (disp), .segment(seg));
	
	assign pwr = (seg_count < 200_000)? 2'b01 : 2'b10;
	assign disp = (seg_count < 200_000)? d0 : d1;	   // MUX: seg_clk == 0 --> sw1 + first display on, seg_clk ==1 --> sw2 + second display on (see above)
	
	
endmodule