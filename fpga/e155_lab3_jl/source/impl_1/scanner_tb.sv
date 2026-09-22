// Jessica Li  |  jesli@g.hmc.edu
// 09/15/2026
// This is a test bench for the scanner submodule used in the top-level module of lab 2.
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
		// ### 1. Does the Scanner submodule exert all 4 output transitions? ###############################################################################
		// 20 ns per posedge if osc (counter increment) 20 ns * 6_000_000 = time per cycle = 120_000_000
		
		$display("### Test 1. Does the Scanner submodule exert all 4 output transitions? ");
		#500; // avoiding edge by 500 ns
		assert (row == 4'b1000)
			$display ("1a. Success Output Row 0: row = 1000. Time: %0t.", $time);
		else $error("1a. Failure Output Row 0: row does not equal 1000, but it should be the first state. Time: %0t.", $time);
		#120_000_000;
		assert (row == 4'b0100)
			$display ("1b. Success Output Row 1: row = 0100. Time: %0t.", $time);
		else $error("1b. Failure Output Row 1: row does not equal 0100, but it should be the second state. Time: %0t.", $time);
		#120_000_000;
		assert (row == 4'b0010)
			$display ("1c. Success Output Row 2: row = 0010. Time: %0t.", $time);
		else $error("1c. Failure Output Row 2: row does not equal 0010, but it should be the third state. Time: %0t.", $time);
		#120_000_000;
		assert (row == 4'b0001)
			$display ("1d. Success Output Row 3: row = 0001. Time: %0t.", $time);
		else $error("1d. Failure Output Row 3: row does not equal 0001, but it should be the fourth state. Time: %0t.", $time);
			
		/* 2. Enable & Reset
			2a. Show that enable = 0 can hold led blink (if col input is held at 0)
			2b. Show that enable = 1 can let the led blink again
			2c. nreset = 0 can set count = 0, which means scanner exerts row 0, thus led 0 turns on and stays on until nreset = 1
		*/
		en = 0; 
		#120_000_000;
		#120_000_000;
		assert (row == 4'b0001)
			$display ("2a. Success Enable Hold Row 3: row = 0001. Time: %0t.", $time);
		else $error("2a. Failure Enable Hold Row 3: row does not equal 0001, but it should be the fourth state. Time: %0t.", $time);
		en = 1;
		#120_000_000;
		#120_000_000;
		assert (row == 4'b0100)
			$display ("2b. Success Enable = 0: row state changes. Time: %0t.", $time);
		else $error("2b. Failure Enable = 0: row state does not change as expected. Time: %0t.", $time);
		#120_000_000;
		nrst = 0;
		#120_000_000;
		assert (row == 4'b1000)
			$display ("2c. Success nreset = 0: row state resets to state 1. Time: %0t.", $time);
		else $error("2c. Failure nreset = 0: row state does not reset to state 1. Time: %0t.", $time);
		nrst = 1;
		
		#120_000_000;
		$stop;
	end
endmodule