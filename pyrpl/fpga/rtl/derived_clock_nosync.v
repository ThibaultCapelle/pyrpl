module derived_clock_nosync
(
    input [31:0] N,
    input clk,
    input clk_in,
    input rst_n,
    output output_clk
);

    reg [32-1:0] count;
    wire edge_detected;
    reg out;
    edge_detect_both detection(
        .A(clk_in),
        .clk(clk),
        .OUT(edge_detected)
    );
    
    

    
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            count <= 32'b0;
            out <= 1'b0;
        end
        else begin
            if(edge_detected) begin
                count <= count + 32'b1;
            end
            if (count>=N) begin
                
                    count <=1'b0;
                    out <= !out;
            end
        end
    end
    
    assign output_clk = out;

endmodule
