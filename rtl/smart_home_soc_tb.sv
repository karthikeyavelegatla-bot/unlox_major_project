`timescale 1ns/1ps

module smart_home_soc_tb;
    logic       clk;
    logic       rst_n;
    logic       mode_wr_en;
    logic [1:0] mode_wr_data;
    logic [7:0] temperature_in;
    logic [7:0] thermal_threshold;
    logic [7:0] ambient_light_in;
    logic [7:0] light_threshold;
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

    smart_home_soc_top dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .mode_wr_en     (mode_wr_en),
        .mode_wr_data   (mode_wr_data),
        .temperature_in (temperature_in),
        .thermal_threshold(thermal_threshold),
        .ambient_light_in(ambient_light_in),
        .light_threshold(light_threshold),
        .arm_request    (arm_request),
        .disarm_request (disarm_request),
        .motion_pulse   (motion_pulse),
        .doorbell_pulse (doorbell_pulse),
        .global_mode    (global_mode),
        .cooling_on     (cooling_on),
        .overheat_irq   (overheat_irq),
        .filtered_light (filtered_light),
        .lights_on      (lights_on),
        .security_state (security_state),
        .alarm_active   (alarm_active),
        .strobe_led     (strobe_led),
        .siren_wave     (siren_wave),
        .servo_pwm      (servo_pwm),
        .gate_open      (gate_open)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic pulse_arm_request;
        begin
            arm_request = 1'b1;
            @(posedge clk);
            arm_request = 1'b0;
        end
    endtask

    task automatic pulse_doorbell;
        begin
            doorbell_pulse = 1'b1;
            @(posedge clk);
            doorbell_pulse = 1'b0;
        end
    endtask

    task automatic motion_event;
        begin
            motion_pulse = 1'b1;
            @(posedge clk);
            motion_pulse = 1'b0;
        end
    endtask

    initial begin
        rst_n            = 1'b0;
        mode_wr_en       = 1'b0;
        mode_wr_data     = 2'b00;
        temperature_in   = 8'd22;
        thermal_threshold= 8'd30;
        ambient_light_in = 8'd140;
        light_threshold  = 8'd80;
        arm_request      = 1'b0;
        disarm_request   = 1'b0;
        motion_pulse     = 1'b0;
        doorbell_pulse   = 1'b0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        temperature_in = 8'd35;
        repeat (3) @(posedge clk);
        temperature_in = 8'd24;
        repeat (4) @(posedge clk);

        ambient_light_in = 8'd20;
        repeat (6) @(posedge clk);
        ambient_light_in = 8'd150;
        repeat (6) @(posedge clk);

        pulse_arm_request();
        repeat (2) @(posedge clk);
        motion_event();
        repeat (10) @(posedge clk);

        disarm_request = 1'b1;
        @(posedge clk);
        disarm_request = 1'b0;

        pulse_doorbell();
        repeat (50) @(posedge clk);

        mode_wr_en   = 1'b1;
        mode_wr_data = 2'b01;
        @(posedge clk);
        mode_wr_en   = 1'b0;
        temperature_in = 8'd33;
        repeat (2) @(posedge clk);
        motion_event();
        repeat (10) @(posedge clk);

        $finish;
    end
endmodule
