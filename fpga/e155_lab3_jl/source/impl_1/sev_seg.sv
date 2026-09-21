// Jessica Li  |  jesli@g.hmc.edu
// 09/20/2026
// This is a submodule.
// It contains the combinational logic for the switch-to-7-segment display.
// This module takes s[3:0] and displays its single hexadecimal digit on a 7 segment display.
// Note: applied logic 0 turns on the segment (common anode display)


module sev_seg(
	input   logic [3:0] switch,
	output  logic [6:0] segment
);
	
	always_comb
		case (switch)
			4'b0000: segment = 7'b1000000; //0
			4'b0001: segment = 7'b1111001; //1
			4'b0010: segment = 7'b0100100; //2
			4'b0011: segment = 7'b0110000; //3
			4'b0100: segment = 7'b0011001; //4
			4'b0101: segment = 7'b0010010; //5
			4'b0110: segment = 7'b0000010; //6
			4'b0111: segment = 7'b1111000; //7
			4'b1000: segment = 7'b0000000; //8
			4'b1001: segment = 7'b0010000; //9
			4'b1010: segment = 7'b0001000; //10  A
			4'b1011: segment = 7'b0000011; //11  B
			4'b1100: segment = 7'b1000110; //12  C
			4'b1101: segment = 7'b0100001; //13  D
			4'b1110: segment = 7'b0000110; //14  E
			4'b1111: segment = 7'b0001110; //15  F
			default: segment = 7'b1111111;
		endcase
	

endmodule