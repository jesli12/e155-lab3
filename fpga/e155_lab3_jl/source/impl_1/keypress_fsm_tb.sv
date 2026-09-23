// Jessica Li  |  jesli@g.hmc.edu
// 09/23/2026
// This is a test bench for the keypress fsm submodule used in the top-level module of lab 3.
/* The following tests include:
	1. Sim Waveforms show diagonal key presses individual and show both no press and multipress reactions 
*/

`timescale 1 ns/1 ns

module keypress_fsm_tb();
	logic           osc, enable, nreset, d_en, press;    
	logic  [3:0]    key, d0, d1; 
	logic  [2:0]    db_led;

    keypress_fsm dut (.clk(osc), .nrst(nreset), .en(enable),.one_key(press),.key_next(key),.d_en,
		.d0,.d1,.db_led);

	// generate clock
	always begin
		osc = 0; 
		#5;
		osc = 1; 
		#5;
	end

	initial begin
    nreset = 0;
    #22 nreset = 1;

	d_en = 1'b1;
	press = 1'b1;
	#10;
			
	#10; // now it should stuck in HOLD
		
	#1000;
	press = 0;
	#1000;
		

    #1000 $stop;
  end
endmodule