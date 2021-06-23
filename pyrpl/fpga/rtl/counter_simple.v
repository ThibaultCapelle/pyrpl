module counter_simple (
	input clk,
	input start,
	input [31:0] N,
	output reg [31:0] count
);

	always @ (posedge clk or posedge start)
		if (start) begin
			count<=N;
		end
		else begin
			if (count>0) begin
				count<=count-1;
			end
		end
endmodule