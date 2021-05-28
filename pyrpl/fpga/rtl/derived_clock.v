module derived_clock (
    input [32-1:0] N,
    input clk,
    output OUT
);

    reg [32-1:0] count;
    reg out;

    always @(posedge clk) begin
        if (count < N)
            count <= count+1;
        else
            count <= 32'b0;
            out <= !out;
    end

    assign OUT = out;

endmodule
