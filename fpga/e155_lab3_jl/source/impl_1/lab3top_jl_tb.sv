// Jessica Li  |  jesli@g.hmc.edu
// 09/23/2026
// This is a test bench for the top module.
/* The following tests include:
	1. Sim Waveforms show 
*/

`timescale 1 ns/1 ns

module lab3top_jl_tb();
	logic  [3:0] col_raw;
	logic nreset;
	logic enable;
	logic  [1:0] pwr;
	logic  [6:0] seg;
	logic  [3:0] row;
	logic  [2:0] debug_led;
	
    lab3top_jl dut (
        .col_raw,
		.nreset,
		.enable,
		.pwr,
		.seg,
		.row,
		.debug_led
    );

  // apply stimuli and check outputs
  initial begin
	enable = 1;
    nreset = 0;
    #22;
	nreset = 1;
	
	col_raw = 4'b1101;
	#5_000_000;// shorter than debounce
	col_raw = 4'b1111;
	#15_000_000;
	
	
	col_raw = 4'b1101;
    #15_000_000;// longer than debounce                      
	col_raw = 4'b1111;
	#15_000_000;// longer than debounce
	col_raw = 4'b1001; // multipress
	#15_000_000;// longer than debounce
	col_raw = 4'b1101;
	#15_000_000;// longer than debounce
	nreset = 0;
	#10_000_000;
	nreset = 1;
	col_raw = 4'b1011;
		#100000
		col_raw = 4'b1111;
		#100000
		col_raw = 4'b1011;
		#100000
		col_raw = 4'b1111;
		#100000
		col_raw = 4'b1011;
		#100000
		col_raw = 4'b1111;
		#100000
		col_raw = 4'b1011;
		#100000
		col_raw = 4'b1111;
		#100000
		col_raw = 4'b1011;
		#100000
		col_raw = 4'b1111;
		#100000
		col_raw = 4'b1011;
		#100000000
		
		nreset = 0;
		#5
		nreset = 1;
		#5
		//col_raw = 4'b1111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b0111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b1111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b0111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b1111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b0111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b1111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b0111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b1111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b0111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b1111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b0111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b1111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667
		//col_raw = 4'b0111;
		//#6666657
		//col_raw = 4'b1111;
		//#6666667


    #100 $stop;
  end
endmodule