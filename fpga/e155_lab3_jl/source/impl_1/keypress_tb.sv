// Jessica Li  |  jesli@g.hmc.edu
// 09/23/2026
// This is a test bench for the sync submodule used in the top-level module of lab 3.
/* The following tests include:
	1. Sim Waveforms show all 
*/

`timescale 1 ns/1 ns

module keypress_tb();
	// var declaration
	logic   osc, nreset, enable;
	logic 	[3:0] c_sync;
	logic 	[3:0] r_sync;
	logic   press;
	logic   [1:0] col_index; //pressed column = col_sync[col_index] [not used]
	logic   [3:0] key;
	logic   [15:0] map;
	
	// instantiation dut
	keypress dut(.clk(osc), .nrst(nreset), .en(enable), .c_sync, .r_sync, .one_press(press), .col_index, .key_next(key), .map);
	
	// generate fake 50 MHz clock for testing purposes
	always begin
		osc = 0;
		#10;
		osc = 1;
		#10;
	end
	
	// start timed tests
	initial begin
		enable = 1;
		nreset = 0;
		#22
		nreset = 1;
		#200; // for delay to offset (not have actions on ticks)
        r_sync = 4'b0001;                
		c_sync = 4'b1111;
        #1_000_000; // time it takes for sample counter to sample
		
		assert (key == 16'b0)       // check outputs
				$display("PASSED! key is at 0");
			else 
				$error("FAILED! key = %0b",key); 
				
		assert (press == 0)       // check outputs
				$display("PASSED! press = 0");
			else 
				$error("FAILED! press = %0b", press); 
				
		#600_000 // time left for scanned row to deactivate (and counter resets)
		r_sync = 4'b0001;                
		c_sync = 4'b1110;
        #1_000_000;    
		assert (key == 16'b10)       // check outputs
				$display("PASSED! key is at 1");
			else 
				$error("FAILED! key = %0b",key); 
				
		assert (press == 1'b1)       // check outputs
				$display("PASSED! press = 1");
			else 
				$error("FAILED! press = %0b", press); 
		#600_000
		r_sync = 4'b0010;
		c_sync = 4'b1101;
        #1_000_000;
        assert (key == 16'b0000000000100000)       // check outputs
				$display("PASSED! key is at 0");
			else 
				$error("FAILED! key = %0b",key); 
				
		assert (press == 0)       // check outputs
				$display("PASSED! press = 0");
			else 
				$error("FAILED! press = %0b", press); 

		#600_000
		#100 
		$stop;
	end
endmodule