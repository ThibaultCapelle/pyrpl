module counter (
	input clk,
	input start,
	input [31:0] N,
	output reg [1:0] overflow
);
    parameter  Zero=3'b000,
    Counting=3'b010, 
    Overflow=3'b011;
    reg [2:0] current_state, next_state;
	reg [31:0] count;
	always @(posedge clk) begin
		current_state <= next_state;
		if(current_state==Counting)
		count<=count+32'b1;
		else
		count<=32'b0;
    end
    always @(current_state, start)
    begin
    case(current_state) 
    Zero:begin
    if(start==1)
    next_state = Counting;
    else
    next_state = Zero;
    end
    Counting:begin
    if(count==N)
    next_state = Overflow;
    end
    Overflow:begin
    next_state = Zero;
    end 
    default:next_state = Zero;
    endcase
    end
    // combinational logic to determine the output
    // of the Moore FSM, output only depends on current state
    always @(current_state)
    begin 
    case(current_state) 
    Zero:   overflow = 2'b00;
    Counting:   overflow = 2'b01;
    Overflow:  overflow = 2'b10;
    default:  overflow = 2'b00;
    endcase
    end 
endmodule
