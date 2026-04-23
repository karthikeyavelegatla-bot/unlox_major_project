module luminance_processing (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] ambient_light_in,
    input  logic [7:0] light_threshold,
    output logic [7:0] filtered_light,
    output logic       lights_on
);
    logic       next_lights_on;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            filtered_light <= 8'd0;
        end else begin
            filtered_light <= (filtered_light + ambient_light_in) >> 1;
        end
    end

    always_comb begin
        if (filtered_light <= light_threshold) begin
            next_lights_on = 1'b1;
        end else begin
            next_lights_on = 1'b0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lights_on <= 1'b0;
        end else begin
            lights_on <= next_lights_on;
        end
    end
endmodule
