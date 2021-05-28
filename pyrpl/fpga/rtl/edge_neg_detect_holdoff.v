module edge_neg_detect_holdoff(sequence_in,clock,detector_out);
input clock; // clock signal
//input reset; // reset input
input sequence_in; // binary input
output reg detector_out; // output of the sequence detector
parameter  Zero=4'b000, // "Zero" State
  One=4'b001, // "One" State
  Two=4'b010,
  Three=4'b011,
  Four=4'b100,
  Five=4'b101,
  Six=4'b110,
  Seven=4'b111,
  Height=4'b1000,
  Nine=4'b1001,
  Ten=4'b1010,
  Eleven=4'b1011,
  Twelve=4'b1100;
reg [3:0] current_state, next_state; // current state and next state
// sequential memory of the Moore FSM
always @(posedge clock)//, posedge reset)
begin
 /*if(reset==1) 
 current_state <= Zero;// when reset=1, reset the state of the FSM to "Zero" State
 else*/
 current_state <= next_state; // otherwise, next state
end 
// combinational logic of the Moore FSM
// to determine next state 
always @(current_state,sequence_in)
begin
 case(current_state) 
 Zero:begin
  if(sequence_in==0)
   next_state = One;
  else
   next_state = Zero;
 end
 One:begin
  if(sequence_in==0)
   next_state = Two;
  else
   next_state = Zero;
 end
 Two:begin
  if(sequence_in==0)
   next_state = Three;
  else
   next_state = Zero;
 end 
 Three:begin
  if(sequence_in==0)
   next_state = Four;
  else
   next_state = Zero;
 end 
 Four:begin
  if(sequence_in==0)
   next_state = Five;
  else
   next_state = Zero;
 end 
 Five:begin
  if(sequence_in==0)
   next_state = Six;
  else
   next_state = Zero;
 end 
 Six:begin
  if(sequence_in==0)
   next_state = Seven;
  else
   next_state = Zero;
 end 
 Seven:begin
  if(sequence_in==0)
   next_state = Height;
  else
   next_state = Zero;
 end 
 Height:begin
  if(sequence_in==0)
   next_state = Nine;
  else
   next_state = Zero;
 end 
 Nine:begin
  if(sequence_in==0)
   next_state = Ten;
  else
   next_state = Zero;
 end 
 Ten:begin
  if(sequence_in==0)
   next_state = Eleven;
  else
   next_state = Zero;
 end 
 Eleven:begin
  if(sequence_in==0)
   next_state = Twelve;
  else
   next_state = Zero;
 end 
 Twelve:begin
  if(sequence_in==0)
   next_state = Twelve;
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
 Two:  detector_out = 0;
 Three: detector_out =0;
 Four: detector_out=0;
 Five: detector_out=0;
 Six: detector_out=0;
 Seven: detector_out=0;
 Height: detector_out=0;
 Nine: detector_out=0;
 Ten: detector_out=0;
 Eleven: detector_out=1;
 Twelve: detector_out=0;
 default:  detector_out = 0;
 endcase
end 
endmodule
