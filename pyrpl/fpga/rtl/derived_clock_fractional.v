module derived_clock_fractional#(
   parameter RSZ = 14
)
(
    input [31:0] N,
    input [31:0] M,
    input clk,
    input rst_n,
    output output_clk
);

    reg [32-1:0] count;
    reg overflow;
    reg out;
    
    reg   [RSZ+16-1: 0] dac_pnt   ; // read pointer
    reg   [RSZ+16-1: 0] dac_pntp  ; // previous read pointer
    wire  [RSZ+17-1: 0] dac_npnt  ; // next read pointer
    wire  [RSZ+17-1: 0] dac_npnt_sub ;
    wire              dac_npnt_sub_neg;
    

    assign dac_npnt_sub = dac_npnt - N - 1;
    assign dac_npnt_sub_neg = dac_npnt_sub[RSZ+16];
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            dac_pnt  <= {RSZ+16{1'b0}};
            out <= 1'b1;
        end
        else begin
            dac_pntp  <= dac_pnt;
            if (~dac_npnt_sub_neg)  dac_pnt <= dac_npnt_sub; // wrap or go to start
            else                    dac_pnt <= dac_npnt[RSZ+16-1:0];
            
            /*count <= count + M;
            overflow <= count>=N;*/
        end
        if (~dac_npnt_sub_neg) begin
            out <= !out;
        end
    end
    assign dac_npnt = dac_pnt + M;
    assign output_clk = out;

endmodule
