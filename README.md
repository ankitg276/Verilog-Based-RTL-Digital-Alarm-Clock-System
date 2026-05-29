# Verilog-Based Digital Alarm Clock System

An attractive, production-ready, fully synthesized Digital Alarm Clock system designed in Verilog HDL. The system incorporates a multi-state Finite State Machine (FSM) , integrated shift-register keypad buffers , timekeeping counter logic , and an ASCII-configured multi-digit LCD driver engine.

---

## ## Architectural Overview

The system architecture utilizes a highly modular structural design pattern, centered around a unified top-level controller block (`alarm_clock_top.v`). The system processes raw clock inputs, keystrokes, and mode selection switches to perform real-time timekeeping, set individual alarms, and manage synchronous display states.

```
                         +-----------------------------------+
                         |         alarm_clock_top           |
                         |                                   |
    +---------+          |   +---------------------------+   |          +--------------+
    |  clock  |--------->|-->|     timing_generator      |   |          |   ms_hour    |
    |  reset  |--------->|-- |                           |---|--------->|   ls_hour    |
    +---------+          |   +---------------------------+   |          |  ms_minute   |
                         |                 |                 |          |  ls_minute   |
    +---------+          |                 v (one_second)    |          +--------------+
    |   key   |--------->|   +---------------------------+   |                 ^
    +---------+          |-->|            fsm            |   |                 |
                         |   +---------------------------+   |                 |
    +---------+          |                 |                 |          +--------------+
    | buttons |--------->|                 v (control sigs)  |          | lcd_driver_4 |
    +---------+          |   +---------------------------+   |          +--------------+
                         |-->|     counter / registers   |---|-----------------+
                         |   +---------------------------+   |
                         +-----------------------------------+

```

---

## ## Functional Specifications

* 
**Core Operating Frequency:** 50 MHz default system clock, divided dynamically to derive synchronous $1\text{ Hz}$ execution ticks.


* 
**Accelerated Simulation Mode:** Employs a dedicated `fastwatch` test control line reducing the hardware frequency division factor to 256 for rapid functional evaluation.


* 
**Time Keeping Format:** 24-Hour Military format tracking split Binary Coded Decimal (BCD) values for Most Significant Digit (MSD) and Least Significant Digit (LSD) boundaries across Hours and Minutes.


* 
**Human-Machine Interface:** Parallel-to-serial digit entry buffer capable of capturing asynchronous sequential keypad codes (`4'd10` acting as idle state validation line).


* 
**Output Driver Logic:** Hexadecimal conversion directly into standard 8-bit ASCII characters (`8'h30` to `8'h39`) natively compatible with multi-segment hardware characters and LCD pixel interfaces.



---

## ## Detailed Module Breakdowns

### ### 1. Central Core Interconnect (`alarm_clock_top.v`)

Acts as the structural netlist of the system. It wires the control busses and datapath rails together, establishing data flow lines from keypad registers into both runtime clock variables and persistent alarm matching vectors.

### ### 2. Finite State Machine Controller (`fsm.v`)

Implemented as a sequential control block orchestrating multi-cycle input routines. The controller uses specific dual-counter logic to handle system timeout tracking. If a user leaves the interface hanging mid-input, the FSM triggers a auto-timeout switch after 9 seconds, resetting back to safe time tracking displays.

| State Name | State Vector | Operational Semantics |
| --- | --- | --- |
| `SHOW_TIME` | `3'b000` | Standard operations displaying active running hour/minute counts.

 |
| `KEY_ENTRY` | `3'b001` | Active keystroke input processing mode; routes keyboard cache values directly to display nodes.

 |
| `KEY_STORED` | `3'b010` | Single-cycle transient state shifting input data sequentially deep into buffers.

 |
| `SHOW_ALARM` | `3'b011` | Intercepts current visual outputs to map designated alarm vectors to the LCD screens.

 |
| `SET_ALARM_TIME` | `3'b100` | Latches keystroke shift data permanently into the dedicated alarm storage bank.

 |
| `SET_CURRENT_TIME` | `3'b101` | Updates clock time counter variables and forces sub-second timekeeping components to restart.

 |
| `KEY_WAITED` | `3'b110` | Hold-off cycle monitoring user interaction until a pressed input key is cleanly released.

 |

### ### 3. Real-Time Tracker Engine (`counter.v`)

An advanced multi-stage BCD cascading counter framework. It manages precise temporal overflow states:

* Minutes LSD tracks up to 9 before rolling over to zero and incrementing the Minutes MSD.


* Minutes MSD rolls over to zero upon hitting 5, passing a carry bit to increment the Hours digit blocks.


* Handles 24-hour time boundaries by overriding standard transitions when the system reaches `23:59`, safely resetting all digits to `00:00`.



### ### 4. Shift Key Buffer Register (`keyreg.v`)

Implements a 4-stage cascaded nibble shift channel. On every asserted `shift` strobe, data cascades from the rightmost minute digit buffer step-by-step into the leftmost hours position. This allows standard 10-key operational entries to seamlessly cycle from right to left across the display panels.

### ### 5. Dynamic Timebase Multiplier (`timing_generator.v`)

Implements synchronous scaling of the master clock pulse. Contains a dedicated parameterized look-ahead comparator optimizing system execution for either ultra-accurate real-world operations or high-speed software waveform verification.

### ### 6. Integrated Visual Translation Matrix (`lcd_driver_4.v` & `lcd_driver.v`)

Structures four parallel output translators that map raw hexadecimal values to clean ASCII data arrays. Simultaneously, it routes time values through an internal multi-bit logic gate to drive the master alarm siren whenever the time arrays perfectly intersect.

---

## ## Project File Structures

The repository workspace maintains a clean, modular design layout:

```text
├── alarm_clock_top.v     # Top-level structural design file wrapping system blocks
├── fsm.v                 # Control state machine and automated interaction timeouts
├── counter.v             # BCD real-time counting logic tracking 24-hour cycles
├── alarm_reg.v           # Specialized storage block holding current alarm targets
├── keyreg.v              # Asynchronous keystroke buffer and shift processing logic
├── timing_generator.v    # Clock division manager adjusting execution timescales
├── lcd_driver_4.v        # Multi-digit hardware display aggregator and routing engine
├── lcd_driver.v          # Base BCD-to-ASCII display translator and comparator
└── tb_alarm_clock.v      # Exhaustive testbench checking typical operational cycles

```

---

## ## Simulation Framework & Verification Outcomes

The validation profile utilizes an automated test suite modeling common real-world user interactions:

1. 
**Hardware Initialization:** The system undergoes a complete synchronous reset, setting all state indicators and time parameters back to default zero baselines.


2. 
**Clock Modification Routine:** Sequentially feeds inputs `1`, `1`, `2`, and `3` into the shift registers to set the clock to `11:23`.


3. 
**Alarm Configuration Routine:** Feeds inputs `1`, `1`, `3`, and `0` into the shift registers to set an alarm for `11:30`.


4. 
**Temporal Verification:** Steps through running execution steps in fast-watch simulation mode to verify that the alarm system accurately triggers the moment the time counts reach the matching milestone.



### ### Simulation Waveform Verification

The timing behavior and functional accuracy of the modules were verified using GTKWave logic simulation tools.

#### Detailed Waveform Analysis:

* **Keystore Extraction Tracking:** The configuration data blocks (`key_ms_hr`, `key_ls_hr`, `key_ms_min`, `key_ls_min`) are shown holding values `1`, `1`, `3`, and `0` respectively, proving the keystroke buffer logic functions correctly.
* **Timekeeping Precision:** The running minutes array (`current_time_ls_min`) displays consistent increments through numbers `3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9 -> 0`, verifying the cascading BCD counter transitions correctly.
* **Multi-Digit ASCII Translation Verification:** The output display lines show appropriate translations (e.g., matching a binary input value of `3` to its correct hexadecimal ASCII display target of `33` (`8'h33`)).
* **Alarm Validation Strobe:** The internal comparison flags (`sound_alarm1` through `sound_alarm4`) turn on exactly when the real-time counting arrays match the target alarm values. This triggers the master alert system (`sound_a`), confirming the design is fully verified and functionally sound.

---

## ## Synthesis & Deployment Steps

To synthesize this core onto target programmable logic array (FPGA) development ecosystems:

### 1. Compile Source File Hierarchy

Using structural tools like Icarus Verilog or AMD/Xilinx Vivado:

```bash
# Compilation using iverilog
iverilog -o alarm_clock_sim alarm_clock_top.v fsm.v counter.v alarm_reg.v keyreg.v timing_generator.v lcd_driver_4.v lcd_driver.v tb_alarm_clock.v

# Execute simulation to output Waveform VCD file
vvp alarm_clock_sim

```

### 2. Physical Port Allocation Requirements

Map top-level hardware lines directly to the matching onboard interface pins of your development board within your project's Constraints File (.XDC / .UCF):

* `clock` $\rightarrow$ Hardware Crystal Oscillator Network ($50\text{ MHz}$).
* `key[3:0]` $\rightarrow$ 4-Bit Matrix Membrane Interface or Tactile Component Banks.
* `reset` / `time_button` / `alarm_button` $\rightarrow$ Pulldown-terminated Push Button Arrays.
* `ms_hour`, `ls_hour`, `ms_minute`, `ls_minute` $\rightarrow$ 8-bit Character LCD or parallel-driven IO display channels.
* `alarm_sound` $\rightarrow$ Dedicated Piezo Buzzing Unit or Digital Audio Output Node.

---

## ## Future Roadmap & Enhancement Capabilities

To further expand this design into a commercially viable consumer product, the following additions can be integrated:

* [ ] **Debounce Filter Integration:** Add dedicated digital debouncing modules to filter out electrical contact noise from physical tactile buttons and switches.
* [ ] **Snooze Functionality Extension:** Implement logic states to temporarily mute the alarm siren for a customizable duration (e.g., 5-10 minutes) before re-triggering.
* [ ] **Flexible Time Formats:** Add a runtime toggle switch to change the display mode between 24-Hour military time and standard 12-Hour AM/PM formats.
* [ ] **Non-Volatile Storage (EEPROM/Flash):** Add an SPI/I2C communication controller to back up user alarm settings, keeping data safe during power loss.
* [ ] **Multi-Alarm Schedules:** Expand the single alarm register into a larger addressable memory block to support setting multiple distinct alarms for weekdays and weekends.
