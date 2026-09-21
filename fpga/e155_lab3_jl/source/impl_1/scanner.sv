// Jessica Li  |  jesli@g.hmc.edu
// 09/20/2026 
// This is a submodule, exerts a 4 bit code that cycles each code at 2 Hz
// "Scanning module only includes instances of a counter and assign statements 
// that convert from the counter output to output values."
// "exerts 1000, 0100, 0010, and 0001"


module scanner
	#(parameter WIDTH = 25,
		MAX_COUNT = 24_000_000)(
	input   logic   int_osc, nreset, enable,
	output  logic   [3:0] rows
);

	logic [WIDTH:0] scan_count;
	logic scan_clk;
	
	// counter for timing *each* of the 4 codes to go at 150Hz? 
	counter #(
		.WIDTH(WIDTH),
		.MAX_COUNT(MAX_COUNT) // MAX_COUNT = 12_000_000 = a signal on/off frequency of 2 Hz
	) scanner_counter (
		.osc (int_osc), 
		.nrst (nreset),  
		.en (enable),
		.count (scan_count)
	);
	
	assign rows = ((scan_count <= (MAX_COUNT/4 - 1)))? 4'b1000 : 
					((scan_count <= (MAX_COUNT/2 - 1))? 4'b0100 : 
					(scan_count <= ((MAX_COUNT*3)/2 - 1)))? 4'b0010 : 
					(scan_count <= (MAX_COUNT - 1))? 4'b0001 : 4'b1000;

endmodule