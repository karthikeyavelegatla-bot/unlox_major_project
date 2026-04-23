# DE10-Lite Board Mapping

This project is mapped to the Terasic DE10-Lite board as a demonstration build of the Smart Home SoC.

## Board Assumption

- FPGA board: Terasic DE10-Lite
- Device: Intel MAX 10 `10M50DAF484C7G`
- System clock: `MAX10_CLK1_50` at 50 MHz

## Input Mapping

- `KEY[0]`: active-low reset for the entire SoC
- `KEY[1]`: doorbell trigger while pressed
- `SW[3:0]`: temperature level control, scaled internally to `temperature_in[7:0]`
- `SW[7:4]`: ambient light level control, scaled internally to `ambient_light_in[7:0]`
- `SW[8]`: mode select
  - `0`: Comfort Mode
  - `1`: Lockdown Mode
- `SW[9]`: motion detect trigger

## Fixed Demo Thresholds

- Thermal threshold: `96`
- Light threshold: `64`

These values are fixed inside the DE10-Lite wrapper so the board demo remains simple and fits the available switches.

## Output Mapping

- `LEDR[0]`: `cooling_on`
- `LEDR[1]`: `overheat_irq`
- `LEDR[2]`: `lights_on`
- `LEDR[3]`: `alarm_active`
- `LEDR[4]`: `strobe_led`
- `LEDR[5]`: `siren_wave`
- `LEDR[6]`: `gate_open`
- `LEDR[7]`: `servo_pwm`
- `LEDR[8]`: `global_mode[0]`
- `LEDR[9]`: `global_mode[1]`

## Demo Procedure

1. Hold `KEY[0]` low to reset the system.
2. Set `SW[3:0]` to a high value to simulate increased temperature.
3. Set `SW[7:4]` to a low value to simulate darkness.
4. Raise `SW[8]` to enter Lockdown Mode.
5. Raise `SW[9]` to simulate motion detection.
6. Press `KEY[1]` to simulate a doorbell-driven gate open request.

## Source References

- DE10-Lite user manual pin tables for `MAX10_CLK1_50`, `KEY`, `SW`, and `LEDR`
- Intel DE10-Lite baseline pinout design example
