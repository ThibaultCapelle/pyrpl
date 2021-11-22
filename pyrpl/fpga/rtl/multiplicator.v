
module multiplicator #(
    parameter     INBITS1   = 14,
    parameter     INBITS2   = 14,
    parameter     OUTBITS   = 14
)
(
    input clk_i,
    input enable,
    input signed  [INBITS1-1:0]  signal1_i,
    input signed  [INBITS2-1:0]  signal2_i,
    output reg [OUTBITS-1:0] signal_o         
);

reg signed [INBITS1-1:0] signal1_reg;
reg signed [INBITS2-1:0] signal2_reg;
always @(posedge clk_i) begin
    signal1_reg <= signal1_i;
    signal2_reg <= signal2_i;
end


reg signed [INBITS1+INBITS2-1:0] raw_product;

always @(posedge clk_i) begin
//    product1 <= product1_unrounded + product1_roundoffset;
//    product2 <= product2_unrounded + product2_roundoffset;
    raw_product <= $signed(signal1_reg) * $signed(signal2_reg);
    if (enable==1'b1) begin
        signal_o <= ^raw_product[INBITS1+INBITS2-1:INBITS1+INBITS2-2] ? {raw_product[INBITS1+INBITS2-1], {13{~raw_product[INBITS1+INBITS2-1]}}} : raw_product[INBITS1+INBITS2-2:INBITS1+INBITS2-OUTBITS-1];
    end
    else begin
        signal_o <=signal1_reg;
    end
end


endmodule
