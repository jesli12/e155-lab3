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


// typedef enum logic [1:0] {IDLE, WAIT, PRESSED} statetype;

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
    nreset = 0;
    #22 nreset = 1;
	
	

    // a full clock cycle (#10)
    // Test moving from IDLE to WAIT
        // setup inputs
		key = 16'b1;
	#20;			
		key = 16'b0;
	#20; // now it should go back to IDLE
		
	#20;
		key = 16'b11;
	#12_000_000;
		
       

    #1000 $stop;
  end
endmodule