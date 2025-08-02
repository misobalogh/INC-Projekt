#!/bin/sh

# Run the shift register testbench
ghdl -a src/shift_reg/shift_register.vhd                                             
ghdl -a test/shift_register_tb.vhd
ghdl -e shift_register_tb
ghdl -r shift_register_tb --wave=wave.ghw --stop-time=10000ns
echo "Done"

gtkwave wave.ghw  --script=scripts/wave_shift_reg.tcl   # View the waveform