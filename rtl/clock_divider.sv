module clock_divider #(
    parameter int DIVISOR = 8
) (
    input  logic clk,
    input  logic rst_n,
    output logic tick
);
    localparam int COUNTER_W = (DIVISOR <= 2) ? 1 : $clog2(DIVISOR);

    logic [COUNTER_W-1:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
            tick  <= 1'b0;
        end else if (count == DIVISOR - 1) begin
            count <= '0;
            tick  <= 1'b1;
        end else begin
            count <= count + 1'b1;
            tick  <= 1'b0;
        end
    end
endmodule
