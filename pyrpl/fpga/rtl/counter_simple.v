module counter_simple (
	input clk,
	input start,
	input timer_tick,
	input [31:0] N,
	output wire [1:0] overflow
);

	reg [31:0] timer_reg, timer_next;
	reg counting_reg;

	always @ (posedge clk)
		timer_reg<=timer_next;

	always @ (*) begin
		if (start)
			timer_next=N;
		else if ((timer_tick) && (timer_reg != 0)) begin
			timer_next=timer_reg-1;
			counting_reg=1;
			end
		else begin
			timer_next=timer_reg;
			counting_reg=0;
			end
	end
	assign overflow = {timer_reg==0,counting_reg==1};
endmodule