# Timing Diagrams and Specifications

## UART Protocol Timing

### Frame Format
```
Idle  Start   D0   D1   D2   D3   D4   D5   D6   D7  Stop  Idle
 ___    __    ___  ___  ___  ___  ___  ___  ___  ___  ___   ___
    |  |  |  |   ||   ||   ||   ||   ||   ||   ||   ||   ||
    |__|  |__|   ||   ||   ||   ||   ||   ||   ||   ||   ||
              Data Bits (LSB first)
```

### Timing Parameters

- **Bit Period**: 104.16 μs (at 9600 baud)
- **Sampling**: 16x oversampling
- **Sample Point**: Middle of bit period (8th clock cycle)
- **Clock Period**: 6.51 μs (153.6 kHz)

### State Machine Timing

```
State:    IDLE    START_BIT    DATA     STOP_BIT    IDLE
         ____    __________   ______   __________   ____
Clock:   ^^^^    ^^^^^^^^^^   ^^^^^^   ^^^^^^^^^^   ^^^^
DIN:     ____    ______XXXX   XXXXXX   __________   ____
                        ||||   ||||||              
                     Sampling  Data
                      Point    Bits
```

## Clock Domain Analysis

### System Clock (CLK)
- **Frequency**: 153.6 kHz (9600 × 16)
- **Period**: 6.51 μs
- **Duty Cycle**: 50%

### Bit Clock (Virtual)
- **Frequency**: 9.6 kHz
- **Period**: 104.16 μs
- **Relation**: CLK ÷ 16

### Counter Relationships

1. **clk_cnt**: 4-bit counter (0-15)
   - Counts system clock cycles within one bit period
   - Resets every 16 cycles
   - Used for bit timing and sampling

2. **bit_cnt**: 4-bit counter (0-15)
   - Counts received data bits
   - Increments when clk_cnt reaches 15
   - Resets at start of new frame

## Metastability Handling

### Input Synchronization
```vhdl
process(CLK)
begin
    if rising_edge(CLK) then
        din_s <= DIN;      -- First flip-flop
        din_in <= din_s;   -- Second flip-flop (synchronized)
    end if;
end process;
```

### Reset Synchronization
```vhdl
process(CLK)
begin
    if rising_edge(CLK) then
        rst_s <= RST;      -- First flip-flop
        rst_in <= rst_s;   -- Second flip-flop (synchronized)
    end if;
end process;
```

## Performance Characteristics

### Latency Analysis
- **Bit Detection**: 8 clock cycles (sampling point)
- **Frame Completion**: 10 bit periods (160 clock cycles)
- **Output Valid**: 1 clock cycle after stop bit detection

### Throughput
- **Maximum**: 9600 bps
- **Effective**: ~8.7 kbps (considering frame overhead)
- **Frame Efficiency**: 80% (8 data bits / 10 total bits)

## Error Detection

### Start Bit Validation
- Sample at middle of start bit period
- Must be logic '0' to be valid
- Invalid start bit returns FSM to IDLE

### Stop Bit Validation
- Sample at middle of stop bit period
- Must be logic '1' to be valid
- Invalid stop bit discards frame

### Timing Tolerance
- **Sampling Window**: ±3.25 μs around ideal sampling point
- **Maximum Drift**: ±3.4% per bit
- **Frame Drift Tolerance**: ±0.34% (cumulative over 10 bits)
