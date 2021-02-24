module red_pitaya_do_nothing #(

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



//reg         on;  //fgen is on; allows to re-synchronize the outputs
wire on;
assign on = sync_i;

  // output_signal multiplexer

assign dat_o = dat_i;
endmodule
