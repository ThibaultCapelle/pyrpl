module derived_clock (
    input [31:0] N,
    input clk,
    input rst_n,
    output output_clk
);

    reg [32-1:0] count;
    reg out;

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            out <= 1'b0;
        end
        else if (count < N) begin
            count <= count+1;
        end
        else begin 
            count <= 32'b0;
            out <= !out;
        end
    end

    assign output_clk = out;

endmodule
