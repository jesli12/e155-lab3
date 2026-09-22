// 


`timescale 1 ns/1 ns

module keypress_fsm_tb();
	// Internal high-speed oscillator, 48 MHz clock generated in FPGA by HSOSC primitive
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	// col input synchronizer
	sync col_synchronizer(.clk(int_osc), .d(col_raw), .q(col_sync)); // synchronize all col inputs
	// sync row_synchronizer(.clk(int_osc), .d(row_raw), .q(row_sync));  
	
	// main keypress fsm
	keypress_fsm dut(.clk(int_osc), .nrst(nreset), .en(enable), .c_sync(col_sync), .r_sync(row_sync), .d_en,
	.row_exert(row),.d0,.d1);
endmodule