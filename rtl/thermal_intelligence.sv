module thermal_intelligence (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] mode,
    input  logic [7:0] temperature_in,
    input  logic [7:0] threshold_in,
    output logic       cooling_on,
    output logic       overheat_irq
);
    logic [7:0] release_margin;
    logic [7:0] release_threshold;
    logic       above_threshold;
    logic       below_release;

    always_comb begin
        above_threshold = (temperature_in > threshold_in);

        if (mode == 2'b01) begin
            release_margin = 8'd1;
        end else begin
            release_margin = 8'd3;
        end

        if (threshold_in > release_margin) begin
            release_threshold = threshold_in - release_margin;
        end else begin
            release_threshold = 8'd0;
        end

        below_release = (temperature_in < release_threshold);
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cooling_on   <= 1'b0;
            overheat_irq <= 1'b0;
        end else begin
            if (above_threshold) begin
                cooling_on   <= 1'b1;
                overheat_irq <= 1'b1;
            end else if (below_release) begin
                cooling_on   <= 1'b0;
                overheat_irq <= 1'b0;
            end
        end
    end
endmodule
