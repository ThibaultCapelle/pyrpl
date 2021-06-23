module counter_simple (
	input clk,
	input start,
	input timer_tick,
	input [31:0] N,
	output reg [1:0] overflow
);

reg [31:0] timer_reg, timer_next;
reg counting

always @ (posedge clk)
	timer_reg<=timer_next;

always @*
	if (start)
		timer_next=N;
	else if ((timer_tick) && (timer_reg != 0)) begin
		timer_next=timer_reg-1;
		counting=1;
		end
	else begin
		timer_next=timer_reg;
		counting=0;
		end
assign overflow = {timer_reg==0,counting==1};