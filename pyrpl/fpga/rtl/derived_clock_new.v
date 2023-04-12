module derived_clock_new
(
    input [31:0] N,
    input clk,
    input clk_in,
    input rst_n,
    output output_clk
);

    reg [32-1:0] count;
    wire overflow;
    wire edge_detected;
    reg out;
    reg previous_clk_in;

    always @(posedge clk) begin
        previous_clk_in <= clk_in;
    end

    assign edge_detected = !clk_in && previous_clk_in;
    assign overflow = count>=N;
    
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            out <= 1'b1;
            previous_clk_in <= 1'b0;
            count <= 32'b1;
        end
        else
            if(edge_detected) begin
                count <= count + 32'b1;
            end
            if(overflow) begin
                count <= 32'b1;
                out <= !out;
        end
    end
    
    assign output_clk = out;

endmodule
