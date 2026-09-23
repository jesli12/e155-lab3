// Jessica Li  |  jesli@g.hmc.edu
// 09/23/2026
// This is a test bench for submodule dual_display
/* Does time multiplexing of dual display anode
*/

`timescale 1 ns/1 ns

module dual_display_tb();
	logic osc, nreset, enable;
	logic   [3:0] d0;
	logic   [3:0] d1;
	logic  [1:0] pwr;
	logic  [6:0] seg;
	
	dual_display dut(.int_osc(osc), .nreset, .enable, .d0, .d1, .pwr, .seg);
	
	// generate fake 50 MHz clock for testing purposes
	always begin
		osc = 0;
		#10;
		osc = 1;
		#10;
	end
	
	initial begin
		nreset = 0; //nrst is active low
		enable = 1;
		#200;
		nreset = 1;
		d0 = 4'b1111;
		d1 = 4'b0000;
		
		// ### Exercise multiplexing functionality (7-segment switches and displays)#########################################################
		$display("###  Exercise multiplexing functionality (7-segment switches and displays)");
		#5_000_000
		enable = 0;
		#2_000_000;
		d0 = 4'b1001;
		d1 = 4'b0001;
		#2_000_000;
		enable = 1;
		#8_000_000;
		nreset = 0;
		#2_000_000;
		nreset = 1;
		
		$stop;
	end
endmodule