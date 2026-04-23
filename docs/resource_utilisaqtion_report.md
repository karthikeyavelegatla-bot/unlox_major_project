# Smart Home SoC Resource Utilization Report

## Scope

This report summarizes the resource footprint of the current RTL implementation of the Smart Home SoC.

## Report Status

- Exact vendor FPGA post-synthesis utilization could not be generated on this machine because Quartus/Vivado is not installed.
- The numbers below are therefore split into:
  - exact RTL register counts derived directly from the synthesizable code
  - estimated combinational logic usage for LUT/ALM planning

## Target FPGA Context

- Reference board: Terasic DE10-Lite
- Reference device: Intel MAX 10 `10M50DAF484C7G`
- Available logic elements on device: approximately 50K logic elements

## Exact Sequential Resource Count

The table below counts explicit state-holding elements inferred from the RTL.

| Module | Storage Elements | Count |
|---|---:|---:|
| `global_mode_register` | mode register | 2 FF |
| `thermal_intelligence` | `cooling_on`, `overheat_irq` | 2 FF |
| `luminance_processing` | `filtered_light`, `lights_on` | 9 FF |
| `clock_divider` inside security block | `count`, `tick` | 3 FF |
| `security_intrusion_shield` | `motion_latched`, `state`, `siren_wave`, `strobe_led` | 5 FF |
| `access_gate_control` | `gate_open`, `close_count`, `pwm_count`, `servo_pwm` | 12 FF |
| **Total** |  | **33 FF** |

## Estimated Combinational Logic

The current design uses small arithmetic and control structures:

- 8-bit comparator in thermal block
- 8-bit subtract/compare logic for hysteresis release
- 8-bit add-and-shift low-pass filter in luminance block
- three-state FSM next-state logic in the security block
- PWM compare logic and auto-close counter terminal detect in the access block
- simple top-level routing and output decode logic

Based on this RTL structure, the expected FPGA logic usage is:

- Estimated LUT/ALM-equivalent usage: `70` to `120`
- Estimated dedicated I/O pins used on DE10-Lite: `23`
  - `1` clock
  - `2` push buttons
  - `10` slide switches
  - `10` LEDs

## Percentage of Device Capacity

Against a 50K-class MAX 10 device, the present Smart Home SoC is very small:

- Flip-flops used: `33`
- Estimated logic usage: well below `1%` of available logic fabric
- I/O use: `23` user pins, also well within board capacity

## Why LUT Usage Is Reported as an Estimate

Exact LUT or ALM numbers depend on:

- synthesis optimizations
- register packing rules
- carry-chain inference
- device family architecture
- fitter and retiming choices

For that reason, only the FF count can be stated exactly from the RTL alone without vendor synthesis output.

## How To Generate an Exact Quartus Report Later

1. Open the DE10-Lite project using `constraints/de10_lite/smart_home_soc_de10_lite.qsf`.
2. Compile the project in Quartus Prime.
3. Export the following reports:
   - Flow Summary
   - Fitter Resource Usage Summary
   - Timing Analyzer summary
4. Replace the estimated LUT/ALM section of this report with the exact post-fit values.

## Engineering Conclusion

The Smart Home SoC is comfortably sized for the DE10-Lite board. Even after adding debounce logic, display drivers, GPIO sensor interfaces, or memory-mapped control registers, the design should remain far below the available resource limit of the target FPGA.
