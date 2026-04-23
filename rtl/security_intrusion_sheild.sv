module security_intrusion_shield #(
    parameter int ALARM_DIVISOR = 4
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] mode,
    input  logic       arm_request,
    input  logic       disarm_request,
    input  logic       motion_pulse,
    output logic [1:0] state,
    output logic       alarm_active,
    output logic       strobe_led,
    output logic       siren_wave
);
    localparam logic [1:0] ST_NORMAL = 2'b00;
    localparam logic [1:0] ST_ARMED  = 2'b01;
    localparam logic [1:0] ST_ALARM  = 2'b10;

    logic motion_latched;
    logic siren_tick;

    clock_divider #(
        .DIVISOR(ALARM_DIVISOR)
    ) u_alarm_divider (
        .clk  (clk),
        .rst_n(rst_n),
        .tick (siren_tick)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            motion_latched <= 1'b0;
        end else if (state == ST_ALARM) begin
            motion_latched <= 1'b0;
        end else if (motion_pulse) begin
            motion_latched <= 1'b1;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_NORMAL;
        end else begin
            unique case (state)
                ST_NORMAL: begin
                    if (arm_request || (mode == 2'b01)) begin
                        state <= ST_ARMED;
                    end
                end
                ST_ARMED: begin
                    if (disarm_request && (mode != 2'b01)) begin
                        state <= ST_NORMAL;
                    end else if (motion_latched || (mode == 2'b01 && motion_pulse)) begin
                        state <= ST_ALARM;
                    end
                end
                ST_ALARM: begin
                    if (disarm_request) begin
                        state <= ST_NORMAL;
                    end
                end
                default: state <= ST_NORMAL;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            siren_wave <= 1'b0;
            strobe_led <= 1'b0;
        end else if (state == ST_ALARM) begin
            strobe_led <= ~strobe_led;
            if (siren_tick) begin
                siren_wave <= ~siren_wave;
            end
        end else begin
            siren_wave <= 1'b0;
            strobe_led <= 1'b0;
        end
    end

    always_comb begin
        alarm_active = (state == ST_ALARM);
    end
endmodule
