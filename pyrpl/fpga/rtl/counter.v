module counter (
	input clk,
	input is_counting,
	input N,
	output overflow
);
	reg [32:0] count;
	reg out;
	always @(posedge clk) begin
		if (is_counting == 1'b1) begin
			count <= 32'b0;
			out <= 1'b0;
		end else begin
            if (count<N) begin
				count <= count +1;
			end else begin
                out <= 1'b1;
            end
		end
	end
	assign overflow = out;
	
endmodule 
