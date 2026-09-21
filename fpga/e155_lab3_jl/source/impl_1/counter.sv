// Jessica Li  |  jesli@g.hmc.edu
// 09/20/2026 
// This is a submodule
// It contains a simple clock divider that takes the HSOSC input

module counter
	#(parameter WIDTH = 25,
		MAX_COUNT = 10_000_000) (
	input   logic   osc, nrst, en,
	output  logic   [WIDTH-1:0] count
);
	
	always_ff @(posedge osc) begin
			if (~nrst) begin
				count <= 0;
				end
			else if (en) begin
				if (count >= (MAX_COUNT-1)) begin //for exact timing MAX_COUNT - 1 to account for the cycle it takes to register that it hit max
					count <= 0;
				end
				else begin
					count <= count + 1'b1;
				end
			end
	end

endmodule