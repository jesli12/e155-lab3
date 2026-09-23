// Jessica Li  |  jesli@g.hmc.edu
// 09/23/2026
// This is a test bench for the keypress submodule used in the top-level module of lab 3.
/* The following tests include:
	1. Sim Waveforms show diagonal key presses individual and show both no press and multipress reactions 
*/

`timescale 1 ns/1 ns

module debounce_fsm_tb();
	logic           osc, enable, nreset;    
	logic [15:0]    key;
	logic           d_en;  

    debounce_fsm dut (
		.keymap(key),
        .clk(osc),
        .nreset,
		.enable,
        .d_en
    );

  // generate clock
	always begin
		osc = 0;
		#10;
		osc = 1;
		#10;
	end

  // apply stimuli and check outputs
	initial begin
		enable = 1;
		nreset = 0;
		key = 16'b0;
		#22 nreset = 1;
		
		#10_500_000;

		key = 16'b1;
		#10_485_780;			
		key = 16'b0;
		#10_485_780; // now it should go back to IDLE
		key = 16'b1;
		#12_000_000;
		#10_485_780;
		nreset = 0;
		#10_485_780;
		#1000 $stop;
	end
endmodule