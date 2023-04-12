module edge_detect_holdoff(sequence_in,clock,detector_out);
input clock; // clock signal
//input reset; // reset input
input sequence_in; // binary input
output reg detector_out; // output of the sequence detector
parameter  Zero=3'b00, // "Zero" State
  One=3'b01, // "One" State
  Two=3'b10,
  Three=3'b11;
reg [2:0] current_state, next_state; // current state and next state
// sequential memory of the Moore FSM
always @(posedge clock)
begin
 current_state <= next_state;
end 
// combinational logic of the Moore FSM
// to determine next state 
always @(current_state,sequence_in)
begin
 case(current_state) 
 Zero:begin
  if(sequence_in==1)
   next_state = One;
  else
   next_state = Zero;
 end
 One:begin
  if(sequence_in==1)
   next_state = Two;
  else
   next_state = Zero;
 end
 Two:begin
  if(sequence_in==1)
   next_state = Three;
  else
   next_state = Zero;
 end 
 Three:begin
  if(sequence_in==1)
   next_state = Three;
  else
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
 Zero:   detector_out = 0;
 One:   detector_out = 0;
 Two:  detector_out = 1;
 Three: detector_out = 0;
 default:  detector_out = 0;
 endcase
end 
endmodule
