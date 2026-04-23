module smart_home_soc_de10_lite_top (
    input  logic        MAX10_CLK1_50,
    input  logic [1:0]  KEY,
    input  logic [9:0]  SW,
    output logic [9:0]  LEDR
);
    localparam logic [7:0] THERMAL_THRESHOLD = 8'd96;
    localparam logic [7:0] LIGHT_THRESHOLD   = 8'd64;

    logic       rst_n;
    logic       mode_wr_en;
    logic [1:0] mode_wr_data;
    logic [7:0] temperature_in;
    logic [7:0] ambient_light_in;
    logic       arm_request;
    logic       disarm_request;
    logic       motion_pulse;
    logic       doorbell_pulse;
    logic [1:0] global_mode;
    logic       cooling_on;
    logic       overheat_irq;
    logic [7:0] filtered_light;
    logic       lights_on;
    logic [1:0] security_state;
    logic       alarm_active;
    logic       strobe_led;
    logic       siren_wave;
    logic       servo_pwm;
    logic       gate_open;

    assign rst_n = KEY[0];

    // Demo-friendly board mapping:
    // SW[3:0]  -> 4-bit temperature control, scaled to 8-bit
    // SW[7:4]  -> 4-bit ambient light control, scaled to 8-bit
    // SW[8]    -> lockdown mode enable
    // SW[9]    -> motion detect trigger
    // KEY[1]   -> doorbell pulse while pressed
    assign temperature_in = {SW[3:0], 4'b0000};
    assign ambient_light_in = {SW[7:4], 4'b0000};
    assign mode_wr_en = 1'b1;
    assign mode_wr_data = {1'b0, SW[8]};
    assign arm_request = 1'b0;
    assign disarm_request = 1'b0;
    assign motion_pulse = SW[9];
    assign doorbell_pulse = ~KEY[1];

    smart_home_soc_top u_soc (
        .clk             (MAX10_CLK1_50),
        .rst_n           (rst_n),
        .mode_wr_en      (mode_wr_en),
        .mode_wr_data    (mode_wr_data),
        .temperature_in  (temperature_in),
        .thermal_threshold(THERMAL_THRESHOLD),
        .ambient_light_in(ambient_light_in),
        .light_threshold (LIGHT_THRESHOLD),
        .arm_request     (arm_request),
        .disarm_request  (disarm_request),
        .motion_pulse    (motion_pulse),
        .doorbell_pulse  (doorbell_pulse),
        .global_mode     (global_mode),
        .cooling_on      (cooling_on),
        .overheat_irq    (overheat_irq),
        .filtered_light  (filtered_light),
        .lights_on       (lights_on),
        .security_state  (security_state),
        .alarm_active    (alarm_active),
        .strobe_led      (strobe_led),
        .siren_wave      (siren_wave),
        .servo_pwm       (servo_pwm),
        .gate_open       (gate_open)
    );

    assign LEDR[0] = cooling_on;
    assign LEDR[1] = overheat_irq;
    assign LEDR[2] = lights_on;
    assign LEDR[3] = alarm_active;
    assign LEDR[4] = strobe_led;
    assign LEDR[5] = siren_wave;
    assign LEDR[6] = gate_open;
    assign LEDR[7] = servo_pwm;
    assign LEDR[9:8] = global_mode;
endmodule
