#!/bin/bash

set -e

# Configuration
GHDL="ghdl"
GHDLFLAGS="-fsynopsys -fexplicit"
GTKW="gtkwave"
SIM_FILE="build/shift_reg_sim.ghw"

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

# Analysis and simulation
simulate_shift_register() {
    print_status "SHIFT REGISTER SIMULATION"

    local sources=(
        "src/shift_reg/shift_register.vhd"
        "test/shift_register_tb.vhd"
    )

    # Analyze sources
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

    # Elaborate testbench
    echo "Elaborating shift_register_tb..."
    if ! $GHDL -e $GHDLFLAGS shift_register_tb; then
        print_error "Elaboration failed!"
        exit 1
    fi
    print_success "Elaboration completed"

    # Run simulation
    echo "Running simulation..."
    if ! $GHDL -r $GHDLFLAGS shift_register_tb --wave="$SIM_FILE" --stop-time=1000ns; then
        print_error "Simulation failed!"
        exit 1
    fi

    print_success "Simulation completed: $SIM_FILE"
}

# Waveform viewing
view_waveform() {
    if [ -z "$SKIP_GTKWAVE" ] && [ -f "$SIM_FILE" ]; then
        print_status "OPENING WAVEFORM VIEWER"

        if [ -f "scripts/wave_shift_reg.tcl" ]; then
            echo "Opening GTKWave with custom script..."
            $GTKW "$SIM_FILE" --script=scripts/wave_shift_reg.tcl &
        else
            echo "Opening GTKWave..."
            $GTKW "$SIM_FILE" &
        fi

        print_success "GTKWave launched"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}Shift Register Build and Simulation Script${NC}"
    echo "=========================================="

    check_dependencies
    simulate_shift_register
    view_waveform

    echo
    print_success "Build process completed successfully!"
    echo -e "${GREEN}Results:${NC}"
    echo "  - Simulation output: $SIM_FILE"

    if [ -z "$SKIP_GTKWAVE" ]; then
        echo "  - Waveform viewer: GTKWave (launched)"
    fi
}

# Run main function
main "$@"
