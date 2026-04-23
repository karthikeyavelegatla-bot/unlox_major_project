module access_gate_control #(
    parameter int PWM_PERIOD    = 16,
    parameter int OPEN_DUTY     = 12,
    parameter int CLOSED_DUTY   = 2,
    parameter int AUTO_CLOSE_CYCLES = 40
) (
    input  logic clk,
    input  logic rst_n,
    input  logic doorbell_pulse,
    output logic servo_pwm,
    output logic gate_open
);
    localparam int PWM_W   = (PWM_PERIOD <= 2) ? 1 : $clog2(PWM_PERIOD);
    localparam int CLOSE_W = (AUTO_CLOSE_CYCLES <= 2) ? 1 : $clog2(AUTO_CLOSE_CYCLES + 1);

    logic [PWM_W-1:0]   pwm_count;
    logic [CLOSE_W-1:0] close_count;
    logic [PWM_W:0]     active_duty;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gate_open   <= 1'b0;
            close_count <= '0;
        end else if (doorbell_pulse) begin
            gate_open   <= 1'b1;
            close_count <= '0;
        end else if (gate_open) begin
            if (close_count == AUTO_CLOSE_CYCLES - 1) begin
                gate_open   <= 1'b0;
                close_count <= '0;
            end else begin
                close_count <= close_count + 1'b1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_count <= '0;
        end else if (pwm_count == PWM_PERIOD - 1) begin
            pwm_count <= '0;
        end else begin
            pwm_count <= pwm_count + 1'b1;
        end
    end

    always_comb begin
        if (gate_open) begin
            active_duty = OPEN_DUTY;
        end else begin
            active_duty = CLOSED_DUTY;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            servo_pwm <= 1'b0;
        end else begin
            servo_pwm <= (pwm_count < active_duty);
        end
    end
endmodule
