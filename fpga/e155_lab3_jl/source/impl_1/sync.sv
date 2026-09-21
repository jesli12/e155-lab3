// Jessica Li  |  jesli@g.hmc.edu
// 09/21/2026 
// Submodule for two flop synchronizer
module sync(
	input   logic   clk,
	input 	logic 	[3:0] d,
	output  logic   [3:0] q
);
	logic [3:0] n1
	
	always_ff @(posedge clk) begin
		n1 <= d;
		q <= n1;
	end

endmodule
