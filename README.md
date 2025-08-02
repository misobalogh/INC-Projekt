# UART Receiver Implementation in VHDL

A complete VHDL implementation of a UART (Universal Asynchronous Receiver Transmitter) receiver with finite state machine control and comprehensive testing framework.

## Project Overview

This project implements a UART receiver capable of receiving 8-bit data frames with start and stop bits. The implementation includes:

- **UART RX Core**: Main receiver logic with finite state machine
- **Shift Register**: Auxiliary component for data shifting operations
- **Simulation Support**: GTKWave integration for waveform analysis

## Architecture

### Main Components

1. **`uart_rx.vhd`** - Top-level UART receiver entity
   - Handles clock domain synchronization
   - Integrates FSM and data path logic
   - Manages bit and clock counters

2. **`uart_rx_fsm.vhd`** - Finite State Machine controller
   - Controls UART receive protocol
   - States: IDLE → START_BIT → DATA → STOP_BIT
   - Validates start/stop bits

3. **`shift_register.vhd`** - Shift register component
   - 10-bit serial input, 8-bit parallel output
   - Configurable enable signal

### UART Protocol Specifications

- **Baud Rate**: 9600 bps (configurable)
- **Data Bits**: 8
- **Start Bits**: 1
- **Stop Bits**: 1
- **Parity**: None
- **Frame Format**: [START][D0][D1][D2][D3][D4][D5][D6][D7][STOP]

## Directory Structure

```
INC-Projekt/
├── README.md              # This file
├── src/                   # Source code
│   ├── uart/             # UART components
│   │   ├── uart_rx.vhd
│   │   └── uart_rx_fsm.vhd
│   └── shift_reg/        # Shift register component
│       └── shift_register.vhd
├── test/                 # Test files
│   ├── testbench.vhd     # UART RX testbench
│   └── shift_register_tb.vhd  # Shift register testbench
├── scripts/              # Build and simulation scripts
│   ├── build_uart.sh     # UART build script
│   ├── build_shift_reg.sh # Shift register build script
│   └── wave_*.tcl        # GTKWave configuration scripts
└── docs/                 # Documentation
    └── timing_diagrams.md # Timing specifications
```

## Getting Started

### Prerequisites

- **GHDL**: VHDL compiler and simulator
- **GTKWave**: Waveform viewer for simulation results

```bash
# Ubuntu/Debian
sudo apt-get install ghdl gtkwave

# Fedora/RHEL
sudo dnf install ghdl gtkwave

# Arch Linux
sudo pacman -S ghdl gtkwave
```

### Building and Running

#### UART Receiver Simulation

```bash
# Run complete UART simulation
./scripts/build_uart.sh

# Clean build artifacts
./scripts/build_uart.sh clean
```

#### Shift Register Simulation

```bash
# Run shift register simulation
./scripts/build_shift_reg.sh
```

### Simulation Output

The testbench will output received data in hexadecimal format:
```
Sending data onto DIN with value: 0x47
Output data from DOUT with value: 0x47
```

## Customization

### Changing Baud Rate

Modify the `baudrate` constant in `testbench.vhd`:
```vhdl
constant baudrate : natural := 9600;  -- Change this value
```

### Adding Test Cases

Add new test data in the testbench main process:
```vhdl
send_byte("01000111");  -- Send 0x47
send_byte("10101010");  -- Send 0xAA
-- Add your test cases here
```

## Timing Analysis

The UART receiver operates at 16x oversampling:
- **System Clock**: 153.6 kHz (9600 × 16)
- **Bit Period**: 16 clock cycles
- **Sampling Point**: Middle of bit period (8th clock cycle)

## Testing

### Test Coverage

1. **Basic Reception**: Standard 8-bit data frames
2. **Edge Cases**: Invalid start bits, timing variations
3. **Multiple Frames**: Consecutive data transmission
4. **Metastability**: Asynchronous input handling

### Running Tests

Each component includes comprehensive testbenches:
- UART RX: Tests complete receive protocol
- Shift Register: Validates shift operations
