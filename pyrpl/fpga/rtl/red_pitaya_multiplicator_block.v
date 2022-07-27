module red_pitaya_multiplicator_block 
(
   // data
   input                 clk_i           ,  // clock
   input                 rstn_i          ,  // reset - active low
   input                 sync_i          ,  // synchronization input, active high
   input signed     [ 14-1: 0] dat_i           ,  // input data
   input signed     [ 14-1: 0] dat2_i          ,
   output signed    [ 14-1: 0] dat_o           ,  // output data

   // communication with PS
   input      [ 16-1: 0] addr,
   input                 wen,
   input                 ren,
   output reg   		 ack,
   output reg [ 32-1: 0] rdata,
   input      [ 32-1: 0] wdata
);
wire      [ 14-1: 0] mult_out;
multiplicator #(
    .INBITS1(14),
    .INBITS2(14),
    .OUTBITS(14))
    mult
    (
    .clk_i(clk_i),
    .signal1_i(dat_i),
    .signal2_i(dat2_i),
    .signal_o(dat_o)
    );

reg signed [ 14-1: 0] test;
//  System bus connection
always @(posedge clk_i) begin
   if (rstn_i == 1'b0) begin
      test <= 14'd0;
   end
   else begin
      if (wen) begin
         if (addr==16'h100)   test <= wdata[16-1:0];
      end
	  casez (addr)
	     16'h100 : begin ack <= wen|ren; rdata <= test; end
	     
	     default: begin ack <= wen|ren;  rdata <=  32'h0; end 
	  endcase	     
   end
end

endmodule
