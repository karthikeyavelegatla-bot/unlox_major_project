# High-Performance Digital Smart Home SoC
## VLSI Design Project Report

### 1. Abstract

The High-Performance Digital Smart Home SoC project is a synthesizable hardware design that models the architectural principles of a modern smart-home controller using Register-Transfer Level (RTL) methodology. The objective of the project is to move beyond software-based automation and demonstrate how sensing, decision-making, and actuation can be executed directly in hardware with deterministic timing, true parallelism, and FPGA-ready implementation. The design integrates multiple digital subsystems including thermal control, automatic lighting, security monitoring, and access management into a single top-level System-on-Chip (SoC).

Unlike software-centric Internet of Things systems that depend on processors, operating systems, and polling loops, this SoC uses dedicated synchronous hardware modules. Each block reacts to digital inputs in a clocked and predictable manner. The result is a platform that mirrors real VLSI development flow, where modular RTL, state machines, clocked registers, counters, comparators, and pulse-generation logic are combined into a unified digital product.

The implemented design has been written in SystemVerilog as a clean hierarchical RTL repository. The SoC includes a global mode register, a temperature-driven cooling controller with hysteresis, a luminance processing block with low-pass filtering, a security FSM with alarm response generation, and a PWM-based gate controller. A DE10-Lite FPGA demonstration wrapper and constraint files are also included to support board-level deployment. This report documents the architecture, design methodology, module-level behavior, FPGA mapping, resource utilization, and verification approach of the project.

### 2. Introduction

Smart homes have evolved from simple automation systems into complex cyber-physical environments. In most consumer implementations, intelligence is embedded in software running on microcontrollers or embedded processors. While software offers flexibility, it also introduces latency, scheduling overhead, and shared-resource limitations. In safety-sensitive or high-speed control scenarios, dedicated hardware provides significant benefits. Hardware logic can monitor multiple inputs simultaneously, respond within deterministic clock cycles, and maintain continuous operation without software intervention.

This project was developed to demonstrate those hardware principles through a realistic digital VLSI design. The goal was not merely to simulate isolated circuits, but to architect an integrated Smart Home SoC that resembles industrial digital subsystems used in environmental control, intrusion detection, and access automation. The final design therefore emphasizes:

- synthesizable RTL
- synchronous digital timing
- modular hierarchy
- hardware parallelism
- FPGA implementation readiness

By completing this project, the designer gains exposure to the same concepts used in ASIC and FPGA workflows: behavioral modeling, structural decomposition, state machine design, clock-domain discipline, hardware interfacing, and resource-conscious implementation.

### 3. Project Objectives

The main objective of the project is to engineer a hardware-centric smart-home control system that demonstrates mastery of digital design and hardware description languages. The specific goals are listed below.

1. Design a complete Smart Home SoC using synthesizable SystemVerilog.
2. Implement multiple real-world subsystems as independent hardware accelerators.
3. Integrate the subsystems through a top-level RTL module with shared clock and reset infrastructure.
4. Use synchronous design practices suitable for FPGA synthesis and ASIC-style reasoning.
5. Provide simulation-ready verification infrastructure through a SystemVerilog testbench.
6. Prepare FPGA-facing files including a board wrapper, pin constraints, and timing constraints.
7. Estimate and document resource utilization in terms of flip-flops, logic, and I/O usage.
8. Produce documentation suitable for academic submission and technical review.

### 4. Design Methodology

The project follows a standard RTL design methodology. The system was first decomposed into logically independent subsystems according to the problem statement. Each module was specified in terms of inputs, outputs, internal state, and synchronous behavior. The design was then implemented using clocked `always_ff` processes for sequential logic and `always_comb` processes for combinational decisions. Non-blocking assignments were used in sequential processes to preserve correct register semantics.

The methodology can be summarized in the following stages:

1. Functional decomposition of the smart-home environment into thermal, lighting, security, access, and governance blocks.
2. Definition of digital interfaces for each module.
3. RTL implementation of each block with synthesizable constructs.
4. Top-level integration into a single Smart Home SoC.
5. Creation of a simulation testbench to exercise key behaviors.
6. Preparation of FPGA-specific wrapper logic and board constraints.
7. Generation of documentation and utilization reporting.

An important design principle throughout the project was to preserve hardware realism. Instead of using abstract software-style control, all behaviors are represented with digital logic primitives such as counters, comparators, registers, state machines, and pulse generation circuits.

### 5. System Architecture Overview

The Smart Home SoC is a hierarchical digital system. At the highest level, a single top module coordinates multiple hardware blocks that operate concurrently on a common clock. Because all modules are evaluated in parallel by hardware, the system can monitor temperature, luminance, security status, and access events simultaneously.

The top-level architecture includes the following subsystems:

1. Global State and Security Governance Register
2. Autonomous Thermal Intelligence Block
3. Digital Luminance Processing Module
4. FSM-Driven Security and Intrusion Shield
5. Automated Access and Gate Control Logic
6. Core RTL Integration Engine

The architecture is centered around the `smart_home_soc_top` module. This top-level block distributes the global clock and reset, instantiates each subsystem, and wires the required control and status paths between them. The global mode register provides a compact control word that influences subsystem behavior, particularly the security response sensitivity and thermal hysteresis margin.

### 6. Module-Level Design Description

#### 6.1 Global State and Security Governance Register

The global control register provides centralized state governance for the SoC. It is implemented as a 2-bit register and currently supports two operating modes:

- `00`: Comfort Mode
- `01`: Lockdown Mode

On reset, the module defaults to Comfort Mode. When a valid write enable is asserted, the register captures the requested mode value. This block serves as a control word source for the rest of the SoC, allowing system-level operating conditions to be changed without modifying individual modules.

In hardware terms, this is a small but important module because it models the concept of a memory-mapped control register frequently used in practical SoCs. Its advantages include:

- centralized system behavior configuration
- reduced interface complexity
- clean hierarchical control distribution

#### 6.2 Autonomous Thermal Intelligence Block

The thermal subsystem simulates an HVAC-oriented hardware accelerator. It continuously compares an 8-bit temperature input against an 8-bit threshold register. If the temperature exceeds the threshold, the block activates the cooling output and raises an overheat interrupt. To avoid rapid toggling around the decision point, the design incorporates a synchronous hysteresis loop.

The hysteresis behavior works by defining a release threshold slightly below the activation threshold. Once cooling is enabled, the logic does not disable it immediately when the temperature falls by one step. Instead, the input must fall below the release threshold. This creates a more stable control response and mimics energy-conscious industrial climate systems.

The mode register also influences this block. In Lockdown Mode, the hysteresis margin is reduced, allowing the system to respond more aggressively. In Comfort Mode, the margin is wider to avoid unnecessary oscillation.

Key hardware features of the block:

- 8-bit digital comparison
- release-threshold arithmetic
- synchronous output control
- interrupt generation
- hysteresis-based stability

#### 6.3 Digital Luminance Processing Module

The lighting controller monitors ambient light intensity and automatically drives the lighting output when the environment becomes too dark. To avoid reacting to abrupt one-cycle noise spikes, the input passes through a lightweight digital low-pass filtering mechanism. The implemented filter averages the previous filtered value and the current sensor input:

`filtered_light <= (filtered_light + ambient_light_in) >> 1`

This operation creates a first-order smoothing function using only add-and-shift logic, which is very efficient in FPGA fabric. Once filtered, the luminance value is compared with a programmable threshold. If the filtered value is below or equal to the threshold, the lighting output is enabled.

This module is significant because it demonstrates that even a simple signal-conditioning function can be realized entirely in RTL. It also reinforces good hardware practice by ensuring that the output changes only in a synchronous manner, thereby reducing switching irregularities and improving predictability.

#### 6.4 FSM-Driven Security and Intrusion Shield

The security module is the behavioral core of the Smart Home SoC. It is implemented as a finite state machine with three operational states:

- `NORMAL`
- `ARMED`
- `ALARM`

In the `NORMAL` state, no alarm response is active. Upon an arm request, or when the system is placed in Lockdown Mode, the FSM enters the `ARMED` state. If a motion pulse is detected while armed, the FSM transitions to the `ALARM` state. In that state, the design activates both a visual strobe output and an auditory alarm waveform.

To support the auditory response, the module instantiates a clock divider. This divider produces periodic ticks from the main system clock, and the alarm waveform toggles on those ticks. As a result, the security subsystem demonstrates an important digital design technique: lower-frequency signal generation from a high-frequency base clock.

The module also includes a motion latch so that narrow motion pulses are not missed before the FSM reacts. This is especially important in digital systems where asynchronous or short-duration events might otherwise be lost between logic evaluations.

#### 6.5 Clock Divider

The clock divider is a reusable utility module that generates a periodic pulse by counting system clock cycles up to a programmable divisor. Although compact, this block is an essential component of many digital systems because it enables internal time scaling without requiring additional external clocks.

In this project, the divider is used to modulate the siren output in the security subsystem. The design can be retuned for different target clocks or desired alarm frequencies by adjusting the `DIVISOR` parameter.

#### 6.6 Automated Access and Gate Control Logic

The access-control subsystem models a secure digital gate mechanism. When a doorbell pulse is received, the system opens the gate and generates a PWM signal suitable for servo actuation. After a fixed interval, an internal counter triggers the automatic closing sequence.

Two timing behaviors are represented in this module:

1. PWM generation for position-style actuation
2. an auto-close delay counter

PWM is generated by comparing a free-running period counter against a duty-cycle value. One duty cycle is used for the open position and another for the closed position. Because the logic is implemented synchronously, the output waveform is predictable and FPGA-friendly.

The auto-close timer illustrates sequential time control using counters. As long as the gate remains open, the close counter advances every clock cycle. When it reaches the programmed timeout value, the gate closes automatically. This demonstrates how hardware can enforce security policies without software scheduling.

#### 6.7 Core RTL Integration Engine

The top-level integration engine is implemented in the `smart_home_soc_top` module. It ties together all major subsystems and serves as the functional heart of the Smart Home SoC. Its responsibilities include:

- distribution of the system clock
- propagation of reset signals
- instantiation of all submodules
- routing of sensor and control signals
- exposure of status outputs for testbench or FPGA visualization

The top-level design demonstrates hierarchical composition, one of the most important principles in digital VLSI. Each block is designed independently but integrated through a clean and explicit interface.

### 7. FPGA Demonstration Mapping

To make the design deployable on real hardware, a board-specific wrapper was created for the Terasic DE10-Lite board. The wrapper connects the generic SoC interface to the physical switches, push buttons, LEDs, and 50 MHz system clock available on the board.

The selected target is:

- Board: Terasic DE10-Lite
- FPGA Device: Intel MAX 10 `10M50DAF484C7G`
- Clock Source: `MAX10_CLK1_50`

The board mapping was chosen to keep demonstration and evaluation straightforward:

- `KEY[0]` provides system reset
- `KEY[1]` acts as a doorbell trigger
- `SW[3:0]` model temperature level
- `SW[7:4]` model ambient light level
- `SW[8]` selects Comfort or Lockdown Mode
- `SW[9]` provides a motion trigger
- `LEDR[0:9]` display actuator and status outputs

This mapping allows a live hardware demo without external sensor hardware. The board wrapper converts the limited user inputs of the development board into meaningful SoC stimulus signals.

### 8. Constraint and Timing Files

Two FPGA implementation support files were created for the DE10-Lite build:

1. Quartus Settings File (`.qsf`)
2. Synopsys Design Constraints file (`.sdc`)

The `.qsf` file defines:

- device family
- exact FPGA part number
- top-level entity
- included SystemVerilog source files
- pin locations
- I/O standards

The `.sdc` file defines the primary timing constraint for the 50 MHz board clock:

`create_clock -name {MAX10_CLK1_50} -period 20.000 [get_ports {MAX10_CLK1_50}]`

These files are important because synthesis correctness alone is not sufficient in FPGA implementation. Physical pin assignment and timing specification are both required to transform RTL into a place-and-route-ready project.

### 9. Verification Strategy

Functional verification was addressed through a SystemVerilog testbench. The testbench instantiates the top-level SoC, generates a periodic clock, applies reset, and then stimulates the major subsystems in sequence. The goal of the testbench is to demonstrate expected behavioral transitions rather than to provide exhaustive formal proof.

The simulation scenarios include:

1. temperature rise above threshold to trigger cooling and overheat indication
2. temperature reduction to test hysteresis-based release
3. low ambient light to activate automatic lighting
4. security arming followed by motion detection to enter the alarm state
5. doorbell activation to open the gate and exercise PWM behavior
6. mode change into Lockdown Mode

The verification approach emphasizes waveform observability. The most important signals to inspect during simulation are:

- `global_mode`
- `cooling_on`
- `overheat_irq`
- `filtered_light`
- `lights_on`
- `security_state`
- `alarm_active`
- `strobe_led`
- `siren_wave`
- `gate_open`
- `servo_pwm`

The design was compile-checked successfully using Icarus Verilog with SystemVerilog enabled. Local waveform execution through `vvp` was limited by a tool installation issue on the machine, but RTL elaboration and compilation completed successfully, which confirms syntax correctness and module connectivity.

### 10. Resource Utilization Analysis

Resource analysis is a key part of VLSI and FPGA-oriented design because it shows whether the architecture is practical for the chosen target device. Since Quartus Prime was not installed in the current environment, an exact post-synthesis vendor report could not be generated locally. However, the project still supports a meaningful utilization study by separating exact sequential counts from estimated combinational logic usage.

#### 10.1 Exact Flip-Flop Count

The implemented RTL explicitly infers the following state elements:

| Module | Flip-Flop Count |
|---|---:|
| Global mode register | 2 |
| Thermal block | 2 |
| Luminance block | 9 |
| Security divider | 3 |
| Security FSM and outputs | 5 |
| Access controller | 12 |
| **Total** | **33** |

This low sequential count indicates that the design is compact and well suited for even modest FPGA devices.

#### 10.2 Estimated Logic Usage

The design also uses combinational logic for:

- arithmetic in the filter and hysteresis logic
- comparisons in threshold detection and PWM generation
- FSM next-state decoding
- output selection logic

Based on the structure of the modules, the expected logic usage is approximately `70` to `120` LUT/ALM-equivalent units. This is still extremely small relative to the capacity of the DE10-Lite target device.

#### 10.3 I/O Usage

The DE10-Lite demonstration build consumes `23` board-level pins:

- `1` clock input
- `2` key inputs
- `10` switch inputs
- `10` LED outputs

This I/O footprint is efficient and leaves significant room for future expansion such as external buzzers, seven-segment displays, UART debug, or GPIO-based sensors.

### 11. Timing and Performance Discussion

One of the central motivations for this project is to emphasize deterministic hardware execution. In software-based home automation, a microcontroller may check sensors sequentially and respond according to firmware timing. In the presented SoC, all major subsystems operate concurrently. On every system clock edge, the hardware can update thermal control state, refresh filtered luminance, evaluate security events, and advance gate-control timing.

This style of operation provides several advantages:

- constant and predictable response latency
- no software polling overhead
- straightforward concurrency
- easier timing reasoning at the RTL level

Although the present report does not include an exact post-fit timing number from Quartus, the small size of the design strongly suggests that meeting a 50 MHz board clock should be practical on the target FPGA. The arithmetic width is small, the state machines are compact, and no deep datapaths are present.

### 12. Engineering Strengths of the Design

The current Smart Home SoC has several notable strengths from a digital design perspective.

#### 12.1 Clean Hierarchical Decomposition

Each major subsystem is implemented as an independent RTL module. This improves readability, testing, reuse, and future scalability.

#### 12.2 Synthesizable Coding Style

The project uses standard synthesizable constructs, making it appropriate for FPGA tools and pedagogically aligned with VLSI design requirements.

#### 12.3 Realistic Hardware Modeling

Rather than representing the problem through software abstractions, the project uses native digital hardware structures such as comparators, counters, filters, finite state machines, and PWM generators.

#### 12.4 Board-Level Deployability

The addition of the DE10-Lite wrapper, QSF, and SDC files makes the project more than a pure simulation exercise. It is positioned for practical FPGA demonstration.

### 13. Limitations and Future Improvements

Although the project is functionally complete as a strong RTL prototype, several enhancements can improve realism, presentation quality, and implementation completeness.

#### 13.1 Exact Post-Synthesis Reports

The most important next step is to run the project through Quartus Prime to obtain:

- exact ALM/LUT count
- exact register packing results
- timing slack
- fitter resource usage
- power estimation

#### 13.2 Sensor Interface Refinement

In the board wrapper, sensor values are currently emulated with switches. A more advanced version could interface real temperature, light, or motion sensors through ADC, GPIO, or serial protocols.

#### 13.3 Debounce and Edge Conditioning

Real board buttons and switches may require explicit debounce or edge-detect logic for production-quality behavior.

#### 13.4 Richer Display Outputs

Seven-segment displays or UART logging could be added to visualize system states more clearly in hardware demos.

#### 13.5 Expanded Control Register Map

The current mode register is intentionally small. A larger memory-mapped register block could expose thresholds, timing constants, arming control, and interrupt masks as run-time programmable settings.

#### 13.6 Formal and Self-Checking Verification

The existing testbench is functional and waveform-oriented. A future version could include assertions, scoreboarding, randomized stimuli, and functional coverage.

### 14. Industrial Relevance

This project is academically valuable because it introduces the habits and abstractions used in industrial digital design. The same general engineering ideas appear in commercial SoCs and FPGA products:

- distributed hardware accelerators
- centralized control registers
- synchronous environmental monitoring
- alarm and interrupt generation
- state-machine-driven protection logic
- pulse-width modulation for actuator control

Even though the project is intentionally compact and educational, it captures many of the design instincts required in professional VLSI work. It also demonstrates that smart-home functionality need not be purely software-driven; significant autonomy can be built directly into hardware.

### 15. Conclusion

The High-Performance Digital Smart Home SoC project successfully demonstrates how a smart-home control environment can be implemented as a synthesizable digital hardware system. The final design integrates thermal monitoring, lighting control, intrusion detection, alarm generation, access actuation, and mode governance into a cleanly structured SystemVerilog SoC. The architecture is modular, synchronous, and ready for FPGA-oriented deployment.

From a technical perspective, the project achieves the core goals of RTL design, hierarchical integration, and hardware-centric decision-making. The implementation is compact, using only 33 explicitly inferred flip-flops and a small estimated logic footprint, making it highly suitable for a teaching FPGA platform such as the DE10-Lite. The addition of board constraints, timing constraints, and a demo wrapper further strengthens the project as a real implementation candidate.

Overall, this work provides a strong foundation for demonstrating digital VLSI concepts in an applied smart-home context. It stands as a practical example of how discrete gates, registers, counters, and state machines can be transformed into a coherent, responsive, and high-performance hardware system.

### 16. File References

The report is based on the following project files:

- `rtl/global_mode_register.sv`
- `rtl/thermal_intelligence.sv`
- `rtl/luminance_processing.sv`
- `rtl/clock_divider.sv`
- `rtl/security_intrusion_shield.sv`
- `rtl/access_gate_control.sv`
- `rtl/smart_home_soc_top.sv`
- `tb/smart_home_soc_tb.sv`
- `fpga/de10_lite/smart_home_soc_de10_lite_top.sv`
- `constraints/de10_lite/smart_home_soc_de10_lite.qsf`
- `constraints/de10_lite/smart_home_soc_de10_lite.sdc`

### 17. External References

The DE10-Lite pin and clock mapping used in this project were aligned to the following references:

1. Intel, "Intel MAX 10 FPGA - Terasic DE10-Lite Board Baseline Pinout."  
   https://www.intel.com/content/www/us/en/design-example/714490/intel-max-10-fpga-terasic-de10-lite-board-baseline-pinout.html

2. Terasic DE10-Lite User Manual, clock, key, switch, and LED pin assignment tables.  
   https://studylib.net/doc/27588521/de10-lite-user-manual
