module smart_home_soc_top (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       mode_wr_en,
    input  logic [1:0] mode_wr_data,
    input  logic [7:0] temperature_in,
    input  logic [7:0] thermal_threshold,
    input  logic [7:0] ambient_light_in,
    input  logic [7:0] light_threshold,
    input  logic       arm_request,
    input  logic       disarm_request,
    input  logic       motion_pulse,
    input  logic       doorbell_pulse,
    output logic [1:0] global_mode,
    output logic       cooling_on,
    output logic       overheat_irq,
    output logic [7:0] filtered_light,
    output logic       lights_on,
    output logic [1:0] security_state,
    output logic       alarm_active,
    output logic       strobe_led,
    output logic       siren_wave,
    output logic       servo_pwm,
    output logic       gate_open
);
    global_mode_register u_mode_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .wr_en  (mode_wr_en),
        .wr_data(mode_wr_data),
        .mode   (global_mode)
    );

    thermal_intelligence u_thermal (
        .clk          (clk),
        .rst_n        (rst_n),
        .mode         (global_mode),
        .temperature_in(temperature_in),
        .threshold_in (thermal_threshold),
        .cooling_on   (cooling_on),
        .overheat_irq (overheat_irq)
    );

    luminance_processing u_lighting (
        .clk            (clk),
        .rst_n          (rst_n),
        .ambient_light_in(ambient_light_in),
        .light_threshold(light_threshold),
        .filtered_light (filtered_light),
        .lights_on      (lights_on)
    );

    security_intrusion_shield #(
        .ALARM_DIVISOR(4)
    ) u_security (
        .clk          (clk),
        .rst_n        (rst_n),
        .mode         (global_mode),
        .arm_request  (arm_request),
        .disarm_request(disarm_request),
        .motion_pulse (motion_pulse),
        .state        (security_state),
        .alarm_active (alarm_active),
        .strobe_led   (strobe_led),
        .siren_wave   (siren_wave)
    );

    access_gate_control #(
        .PWM_PERIOD(16),
        .OPEN_DUTY(12),
        .CLOSED_DUTY(2),
        .AUTO_CLOSE_CYCLES(40)
    ) u_access (
        .clk          (clk),
        .rst_n        (rst_n),
        .doorbell_pulse(doorbell_pulse),
        .servo_pwm    (servo_pwm),
        .gate_open    (gate_open)
    );
endmodule
