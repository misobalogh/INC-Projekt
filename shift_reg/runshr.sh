#!/bin/sh

# Run the shift register testbench
ghdl -a shift_register.vhd                                             
ghdl -a shift_register_tb.vhd
ghdl -e shift_register_tb
ghdl -r shift_register_tb --wave=wave.ghw --stop-time=10000ns
echo "Done"

gtkwave wave.ghw  --script=wave.tcl   # View the waveform