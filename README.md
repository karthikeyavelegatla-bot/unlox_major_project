# unlox_major_project
A hardware-based Smart Home SoC designed using RTL on FPGA. It integrates thermal monitoring, lighting control, security FSM, and PWM-based access control into a parallel, low-latency system. Demonstrates Verilog design, synchronous logic, and real-time hardware decision-making.
# High-Performance Digital Smart Home SoC

This repository contains a synthesizable SystemVerilog prototype of a Smart Home SoC suitable for FPGA-oriented classroom or mini-project demonstrations.

## Directory Layout

- `rtl/`: Core synthesizable RTL modules
- `tb/`: SystemVerilog testbench
- `fpga/de10_lite/`: DE10-Lite FPGA wrapper top module
- `constraints/de10_lite/`: Quartus project constraints (`.qsf`, `.sdc`)
- `docs/`: Board mapping and utilization report
- `docs/final_project_report.md`: Full report-ready writeup for submission
- 
## Implemented Hardware Blocks

1. `global_mode_register.sv`
   Central 2-bit control register that selects comfort mode or lockdown mode.
2. `thermal_intelligence.sv`
   Temperature threshold monitor with synchronous hysteresis-based cooling control and overheat interrupt output.
3. `luminance_processing.sv`
   Low-pass filtered lighting controller that drives automatic lighting in dark conditions.
4. `security_intrusion_shield.sv`
   Three-state FSM (`NORMAL`, `ARMED`, `ALARM`) with strobe and divided alarm waveform generation.
5. `access_gate_control.sv`
   PWM-based access controller with auto-close timing.
6. `smart_home_soc_top.sv`
   Top-level integration module connecting all subsystems in parallel.

## Simulation Flow

Example ModelSim or Questa commands:

```tcl
vlib work
vlog rtl/*.sv tb/smart_home_soc_tb.sv
vsim smart_home_soc_tb
add wave -r /*
run -all
```

## Suggested Demo Signals

- `cooling_on`, `overheat_irq`
- `filtered_light`, `lights_on`
- `security_state`, `alarm_active`, `strobe_led`, `siren_wave`
- `gate_open`, `servo_pwm`
- `global_mode`

## Notes

- The design uses synchronous sequential logic with non-blocking assignments in clocked processes.
- Module parameters can be retuned for real FPGA clocks and servo timing.
- The current testbench is aimed at functional verification and waveform capture, not gate-level timing closure.
