module global_mode_register (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       wr_en,
    input  logic [1:0] wr_data,
    output logic [1:0] mode
);
    localparam logic [1:0] COMFORT_MODE  = 2'b00;
    localparam logic [1:0] LOCKDOWN_MODE = 2'b01;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mode <= COMFORT_MODE;
        end else if (wr_en) begin
            if (wr_data == LOCKDOWN_MODE) begin
                mode <= LOCKDOWN_MODE;
            end else begin
                mode <= COMFORT_MODE;
            end
        end
    end
endmodule
