// Jessica Li  |  jesli@g.hmc.edu
// 09/23/2026
// This is a test bench for the scanner submodule used in the top-level module of lab 3.
/* The following tests include:
	1. Sim Waveforms show all four output transitions
	2. Enable & Reset
		2a. Show that enable = 0 can hold led blink (if col input is held at 0)
		2b. nreset = 0 can set count = 0, which means scanner exerts row 0, thus led 0 turns on and stays on until nreset = 1
		2c. Show that enable = 1 can let the led blink again
*/

`timescale 1 ns/1 ns

module scanner_tb();
	logic   osc, nrst, en;
	logic   [3:0] row;
	
	scanner #(.WIDTH(20), .MAX_COUNT(524_289)) dut(
		.int_osc (osc), 
		.nreset (nrst), 
		.enable (en),
		.rows (row)
	);
	
	// generate fake 50 MHz clock for testing purposes
	always begin
		osc = 0;
		#10;
		osc = 1;
		#10;
	end
	
	initial begin
		nrst = 0; //nrst is active low
		en = 1;
		#20; 
		nrst = 1;
		#500 // offset so not on clk tick
		#10_485_780;
		#2_621_445;
		en = 0;
		#2_621_445;
		en = 1;
		#2_621_445;
		nrst = 0;
		#2_621_445;
		nrst = 1;
		#2_621_445;
		#2_621_445;
		$stop;
	end
endmodule