module edge_detect (
    input A,
    input clk,
    output OUT
);

    reg AA;

    always @(posedge clk) begin
        AA <= A;
    end

    assign OUT = !AA && A;

endmodule
