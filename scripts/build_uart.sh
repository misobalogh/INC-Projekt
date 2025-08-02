#!/bin/bash

set -e  # Exit on any error

# Configuration
GHDL="ghdl"
GHDLFLAGS="-fsynopsys -fexplicit"
GTKW="gtkwave"
SYNTH_FILE="build/synth.vhd"
SIM_FILE="build/sim.ghw"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create build directory
mkdir -p build

# Function to print colored output
print_status() {
    echo -e "${BLUE}########## $1 ##########${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Clean function
clean_build() {
    print_status "CLEANING"
    rm -rf build/ *.cf work-obj93.cf
    print_success "Clean completed"
    exit 0
}

# Check if clean was requested
if [ "$1" == "clean" ]; then
    clean_build
fi

# Check dependencies
check_dependencies() {
    print_status "CHECKING DEPENDENCIES"

    if ! command -v $GHDL &> /dev/null; then
        print_error "GHDL not found. Please install GHDL."
        exit 1
    fi

    if ! command -v $GTKW &> /dev/null; then
        print_warning "GTKWave not found. Waveform viewing will be skipped."
        SKIP_GTKWAVE=1
    fi

    print_success "Dependencies check completed"
}

# Analysis phase
analyze_sources() {
    print_status "ANALYSIS"

    local sources=(
        "src/uart/uart_rx_fsm.vhd"
        "src/uart/uart_rx.vhd"
        "test/testbench.vhd"
    )

    for src in "${sources[@]}"; do
        if [ ! -f "$src" ]; then
            print_error "Source file $src not found!"
            exit 1
        fi

        echo "Analyzing $src..."
        if ! $GHDL -a $GHDLFLAGS "$src"; then
            print_error "Analysis of $src failed!"
            exit 1
        fi
        print_success "Analysis of $src completed"
    done

    print_success "All source files analyzed successfully"
}

# Synthesis phase
synthesize() {
    print_status "SYNTHESIS"

    echo "Synthesizing UART_RX module..."
    if ! $GHDL synth $GHDLFLAGS uart_rx > "$SYNTH_FILE"; then
        print_error "Synthesis failed!"
        exit 1
    fi

    print_success "Synthesis completed: $SYNTH_FILE"
}

# Simulation phase
simulate() {
    print_status "SIMULATION"

    echo "Running testbench simulation..."
    if ! $GHDL -c $GHDLFLAGS -r testbench --wave="$SIM_FILE"; then
        print_error "Simulation failed!"
        exit 1
    fi

    print_success "Simulation completed: $SIM_FILE"
}

# Waveform viewing
view_waveform() {
    if [ -z "$SKIP_GTKWAVE" ] && [ -f "$SIM_FILE" ]; then
        print_status "OPENING WAVEFORM VIEWER"

        if [ -f "scripts/wave_uart.tcl" ]; then
            echo "Opening GTKWave with custom script..."
            $GTKW "$SIM_FILE" --script=scripts/wave_uart.tcl &
        else
            echo "Opening GTKWave..."
            $GTKW "$SIM_FILE" &
        fi

        print_success "GTKWave launched"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}UART RX Build and Simulation Script${NC}"
    echo "===================================="

    check_dependencies
    analyze_sources
    synthesize
    simulate
    view_waveform

    echo
    print_success "Build process completed successfully!"
    echo -e "${GREEN}Results:${NC}"
    echo "  - Synthesis output: $SYNTH_FILE"
    echo "  - Simulation output: $SIM_FILE"

    if [ -z "$SKIP_GTKWAVE" ]; then
        echo "  - Waveform viewer: GTKWave (launched)"
    fi
}

# Run main function
main "$@"
