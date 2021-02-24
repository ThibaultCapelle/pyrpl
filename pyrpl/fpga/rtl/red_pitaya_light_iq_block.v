module red_pitaya_light_iq_block #(

	  //fgen for sin/cos creation parameters
	  parameter LUTSZ     =  11,   //log2 of number of LUT entries
	  parameter LUTBITS   =  17,   //LUT word size
	  parameter PHASEBITS =  32,   //phase accumulator bits

	  //demodulation/modulation parameters
      parameter SIGNALBITS = 14, //input signal bitwidth
      parameter GAINBITS  = 18 , //gain bitwidth
   	  parameter SHIFTBITS  = 8  //binary point of gains
)
(
   // data
   input                 clk_i           ,  // clock
   input                 rstn_i          ,  // reset - active low
   input                 sync_i          ,  // synchronization input, active high
   input      [ 14-1: 0] dat_i           ,  // input data
   output     [ 14-1: 0] dat_o           ,  // output data
   output     [ 14-1: 0] signal_o        ,  // output data
   output     [ 14-1: 0] signal2_o       ,  // output data 2 (orthogonal quadrature)

   // communication with PS
   input      [ 16-1: 0] addr,
   input                 wen,
   input                 ren,
   output reg   		 ack,
   output reg [ 32-1: 0] rdata,
   input      [ 32-1: 0] wdata
);


//output states
localparam QUADRATURE    = 4'd0;
localparam OUTPUT_DIRECT = 4'd1;
//localparam PFD 			 = 4'd2;
//localparam QUADRATURE_HF = 4'd4;

// state registers
reg [4-1:0] output_select;
//reg         on;  //fgen is on; allows to re-synchronize the outputs

// function registers
reg [PHASEBITS-1:0] start_phase;
reg [PHASEBITS-1:0] shift_phase;

/*reg signed [GAINBITS-1:0] g1;
reg signed [GAINBITS-1:0] g2;
reg signed [GAINBITS-1:0] g3;
reg signed [GAINBITS-1:0] g4;

reg [32-1:0] input_filter;
reg [32-1:0] quadrature_filter;*/

//  System bus connection
always @(posedge clk_i) begin
   if (rstn_i == 1'b0) begin
      /*on <= 1'b1; //on by default
      input_filter <= 32'd0;
      quadrature_filter <= 32'd0;*/
      start_phase <= {PHASEBITS{1'b0}};
      shift_phase <= {PHASEBITS{1'b0}};
      /*g1 <= {GAINBITS{1'b0}};
      g2 <= {GAINBITS{1'b0}};
      g3 <= {GAINBITS{1'b0}};
      g4 <= {GAINBITS{1'b0}};
      na_averages = 32'd0;
      na_sleepcycles = 32'd0;
      pfd_on <= 1'b1;*/
  	  output_select <= QUADRATURE;
   end
   else begin
      if (wen) begin
		 //if (addr==16'h100)   {pfd_on,on}   <= wdata[2-1:0];
         if (addr==16'h104)   start_phase   <= wdata[PHASEBITS-1:0];
         if (addr==16'h108)   shift_phase   <= wdata[PHASEBITS-1:0];
         if (addr==16'h10C)   output_select <= wdata[4-1:0];
         /*if (addr==16'h110)   g1 <= wdata[GAINBITS-1:0];
         if (addr==16'h114)   g2 <= wdata[GAINBITS-1:0];
         if (addr==16'h118)   g3 <= wdata[GAINBITS-1:0];
         if (addr==16'h11C)   g4 <= wdata[GAINBITS-1:0];
         if (addr==16'h120)   input_filter  <= wdata;
         if (addr==16'h124)   quadrature_filter  <= wdata;
         if (addr==16'h130)   na_averages <= wdata;
         if (addr==16'h134)   na_sleepcycles <= wdata;
         if (addr==16'h134)   na_sleepcycles <= wdata;*/
      end

	  casez (addr)
	     //16'h100 : begin ack <= wen|ren; rdata <= {{32-2{1'b0}},pfd_on,on}; end
	     16'h104 : begin ack <= wen|ren; rdata <= {{32-PHASEBITS{1'b0}},start_phase}; end
	     16'h108 : begin ack <= wen|ren; rdata <= {{32-PHASEBITS{1'b0}},shift_phase}; end
	     16'h10C : begin ack <= wen|ren; rdata <= {{32-4{1'b0}},output_select}; end
	     /*16'h110 : begin ack <= wen|ren; rdata <= {{32-GAINBITS{1'b0}},g1}; end
	     16'h114 : begin ack <= wen|ren; rdata <= {{32-GAINBITS{1'b0}},g2}; end
	     16'h118 : begin ack <= wen|ren; rdata <= {{32-GAINBITS{1'b0}},g3}; end
	     16'h11C : begin ack <= wen|ren; rdata <= {{32-GAINBITS{1'b0}},g4}; end
	     16'h120 : begin ack <= wen|ren; rdata <= input_filter; end
	     16'h124 : begin ack <= wen|ren; rdata <= quadrature_filter; end
	     16'h130 : begin ack <= wen|ren; rdata <= na_averages; end
	     16'h134 : begin ack <= wen|ren; rdata <= na_sleepcycles; end
         16'h140 : begin ack <= wen|ren; rdata <= {do_averaging,iq_i_sum[31-1:0]};end
         16'h144 : begin ack <= wen|ren; rdata <= {do_averaging,iq_i_sum[62-1:31]};end
         16'h148 : begin ack <= wen|ren; rdata <= {do_averaging,iq_q_sum[31-1:0]};end
         16'h14C : begin ack <= wen|ren; rdata <= {do_averaging,iq_q_sum[62-1:31]};end
	     16'h150 : begin ack <= wen|ren; rdata <= {{32-SIGNALBITS{1'b0}},pfd_integral};end*/

	     16'h200 : begin ack <= wen|ren; rdata <= LUTSZ; end
	     16'h204 : begin ack <= wen|ren; rdata <= LUTBITS; end
	     16'h208 : begin ack <= wen|ren; rdata <= PHASEBITS; end
	     16'h20C : begin ack <= wen|ren; rdata <= GAINBITS; end
	     16'h210 : begin ack <= wen|ren; rdata <= SIGNALBITS; end
	     //16'h214 : begin ack <= wen|ren; rdata <= LPFBITS; end
	     16'h218 : begin ack <= wen|ren; rdata <= SHIFTBITS; end
		 /*16'h220 : begin ack <= wen|ren; rdata <= INPUTFILTERSTAGES; end
	     16'h224 : begin ack <= wen|ren; rdata <= INPUTFILTERSHIFTBITS; end
	     16'h228 : begin ack <= wen|ren; rdata <= INPUTFILTERMINBW; end
	     16'h230 : begin ack <= wen|ren; rdata <= QUADRATUREFILTERSTAGES; end
	     16'h234 : begin ack <= wen|ren; rdata <= QUADRATUREFILTERSHIFTBITS; end
	     16'h238 : begin ack <= wen|ren; rdata <= QUADRATUREFILTERMINBW; end*/

	     default: begin ack <= wen|ren;  rdata <=  32'h0; end
	  endcase
   end
end

//sub-module fgen_block that creates 2 phase-shifted sin/cos pairs
wire signed [LUTBITS-1:0] sin;
wire signed [LUTBITS-1:0] cos;
wire signed [LUTBITS-1:0] sin_shifted;
wire signed [LUTBITS-1:0] cos_shifted;

red_pitaya_iq_fgen_block #(
  .LUTSZ        (  LUTSZ      ),
  .LUTBITS      (  LUTBITS    ),
  .PHASEBITS    (  PHASEBITS  )
)
iq_fgen
(
   // data
  .clk_i          (  clk_i          ),  // clock
  .rstn_i         (  rstn_i         ),
  .on             (  on             ),
  .start_phase    (  start_phase    ),
  .shift_phase    (  shift_phase    ),
  .sin_o          (  sin            ),
  .cos_o          (  cos            ),
  .sin_shifted_o  (  sin_shifted    ),
  .cos_shifted_o  (  cos_shifted    )
  );
  
  // output_signal multiplexer

assign dat_o = sin;
assign signal_o = cos;

assign signal2_o = cos_shifted;

endmodule
