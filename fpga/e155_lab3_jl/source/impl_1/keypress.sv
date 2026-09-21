// Jessica Li  |  jesli@g.hmc.edu
// 09/21/2026 
// Submodule for single press logic and uses combinational logic to decode
module keypress(
	input   logic   clk, nrst, en,
	input 	logic 	[3:0] c_sync,
	input 	logic 	[3:0] r_sync,
	output  logic   one_press,
	output  logic   [3:0] col_index, //pressed column = col_sync[col_index]
	output  logic   [3:0] key_next  
);
	logic 	[15:0] map;

	//Take in 4 bit col sync for 4 cycles  // MEED FIXING TO NOT DISPLAY RANDOM NUMBERS AFTER THE THIRD KEY
    always_ff @(posedge clk) begin
        if (~nrst)
            map <= 15'b0;
		else if (en) begin
			if (r_sync[0])
				map[3:0] <= c_sync[3:0];
			else if (r_sync[1])
				map[7:4] <= c_sync[3:0];
			else if (r_sync[2])
				map[11:8] <= c_sync[3:0];
			else if (r_sync[3])
				map[15:12] <= c_sync[3:0];
		end
	end
	
	always_comb
		case (map)
			16'b0000000000000001: begin key_next = ~4'h1; one_press = 1; col_index = 4'h0; end
			16'b0000000000000010: begin key_next = ~4'h2; one_press = 1; col_index = 4'h1; end
			16'b0000000000000100: begin key_next = ~4'h3; one_press = 1; col_index = 4'h2; end
			16'b0000000000001000: begin key_next = ~4'hA; one_press = 1; col_index = 4'h3; end
			16'b0000000000010000: begin key_next = ~4'h4; one_press = 1; col_index = 4'h4; end
			16'b0000000000100000: begin key_next = ~4'h5; one_press = 1; col_index = 4'h5; end
			16'b0000000001000000: begin key_next = ~4'h6; one_press = 1; col_index = 4'h6; end
			16'b0000000010000000: begin key_next = ~4'hB; one_press = 1; col_index = 4'h7; end
			16'b0000000100000000: begin key_next = ~4'h7; one_press = 1; col_index = 4'h8; end
			16'b0000001000000000: begin key_next = ~4'h8; one_press = 1; col_index = 4'h9; end
			16'b0000010000000000: begin key_next = ~4'h9; one_press = 1; col_index = 4'hA; end
			16'b0000100000000000: begin key_next = ~4'hC; one_press = 1; col_index = 4'hB; end
			16'b0001000000000000: begin key_next = ~4'hF; one_press = 1; col_index = 4'hC; end
			16'b0010000000000000: begin key_next = ~4'h0; one_press = 1; col_index = 4'hD; end
			16'b0100000000000000: begin key_next = ~4'hE; one_press = 1; col_index = 4'hE; end
			16'b1000000000000000: begin key_next = ~4'hD; one_press = 1; col_index = 4'hF; end
			default: begin key_next = ~4'b0000; one_press = 0; col_index = 4'hF;end
		endcase
            

endmodule
