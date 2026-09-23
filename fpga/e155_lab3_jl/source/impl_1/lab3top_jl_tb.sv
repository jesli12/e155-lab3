// Jessica Li  |  jesli@g.hmc.edu
// 09/23/2026
// This is a test bench for the top module.
/* The following tests include:
	1. Sim Waveforms show 
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
		enable = 1;
		nreset = 0;
		#22 nreset = 1;
		d_en = 0;
		press = 0;
		key = 4'h6;
		#50;
		press = 1'b1;
		#50;
		d_en = 1'b1;
		#50;
		press = 0;
		#50;
		key = 4'h7;
		#50;
		press = 1;
		#50
		nreset = 0;
		#50;
		nreset = 1;
		#50
		press = 0;
		#50
		$stop;
  end
endmodule