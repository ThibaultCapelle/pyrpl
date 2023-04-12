module derived_clock 
(
    input [31:0] N,
    input clk,
    input clk_in,
    input rst_n,
    output output_clk
);

    reg [32-1:0] count;
    wire edge_detected;
    wire posedge_detected;
    reg out;
    edge_detect_both detection(
        .A(clk_in),
        .clk(clk),
        .OUT(edge_detected)
    );
    
    edge_detect detection_pos(
        .A(clk_in),
        .clk(clk),
        .OUT(posedge_detected)
    );

    
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            count <= 32'b1;
            out <= 1'b0;
        end
        else begin
            if(edge_detected) begin
                count <= count + 32'b1;
            end
            if (count>=N) begin
                if ((out==1'b0)&&(posedge_detected)) begin
                    count <=1'b1;
                    out <= 1'b1;
                end
                else begin
                    if (out==1'b1) begin
                        count <=1'b1;
                        out <= 1'b0;
                    end
                end
            end
        end
    end
    
    assign output_clk = out;

endmodule
