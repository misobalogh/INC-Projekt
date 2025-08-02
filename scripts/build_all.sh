#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "  INC-Projekt: UART Implementation Build System"
    echo "=================================================="
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${YELLOW}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  all         Build all components (default)"
    echo "  uart        Build only UART RX"
    echo "  shift_reg   Build only shift register"
    echo "  clean       Clean all build artifacts"
    echo "  test        Run all tests"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0           # Build everything"
    echo "  $0 uart      # Build only UART"
    echo "  $0 clean     # Clean build files"
}

# Clean all build artifacts
clean_all() {
    print_section "CLEANING ALL BUILD ARTIFACTS"

    # Run individual clean scripts
    if [ -f "scripts/build_uart.sh" ]; then
        ./scripts/build_uart.sh clean
    fi

    if [ -f "scripts/build_shift_reg.sh" ]; then
        ./scripts/build_shift_reg.sh clean
    fi

    # Remove any remaining build files
    rm -rf build/ *.cf work-obj93.cf *.ghw

    print_success "All build artifacts cleaned"
}

# Build UART component
build_uart() {
    print_section "BUILDING UART RECEIVER"

    if [ ! -f "scripts/build_uart.sh" ]; then
        print_error "UART build script not found!"
        return 1
    fi

    ./scripts/build_uart.sh
    print_success "UART build completed"
}

# Build shift register component
build_shift_reg() {
    print_section "BUILDING SHIFT REGISTER"

    if [ ! -f "scripts/build_shift_reg.sh" ]; then
        print_error "Shift register build script not found!"
        return 1
    fi

    ./scripts/build_shift_reg.sh
    print_success "Shift register build completed"
}

# Run all tests
run_tests() {
    print_section "RUNNING ALL TESTS"

    # Build and test UART
    print_section "Testing UART RX"
    build_uart

    # Build and test shift register
    print_section "Testing Shift Register"
    build_shift_reg

    print_success "All tests completed"
}

# Validate project structure
validate_structure() {
    print_section "VALIDATING PROJECT STRUCTURE"

    local required_dirs=("src" "test" "scripts" "docs")
    local required_files=(
        "src/uart/uart_rx.vhd"
        "src/uart/uart_rx_fsm.vhd"
        "src/shift_reg/shift_register.vhd"
        "test/testbench.vhd"
        "test/shift_register_tb.vhd"
        "scripts/build_uart.sh"
        "scripts/build_shift_reg.sh"
    )

    # Check directories
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            print_error "Required directory missing: $dir"
            return 1
        fi
    done

    # Check files
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "Required file missing: $file"
            return 1
        fi
    done

    print_success "Project structure validated"
}

# Main execution
main() {
    print_header

    # Parse command line arguments
    case "${1:-all}" in
        "help"|"-h"|"--help")
            show_usage
            exit 0
            ;;
        "clean")
            clean_all
            exit 0
            ;;
        "uart")
            validate_structure
            build_uart
            ;;
        "shift_reg")
            validate_structure
            build_shift_reg
            ;;
        "test")
            validate_structure
            run_tests
            ;;
        "all"|"")
            validate_structure
            build_uart
            build_shift_reg
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac

    echo
    print_success "Build process completed successfully!"
    echo -e "${GREEN}Project ready for development and testing.${NC}"
}

# Run main function with all arguments
main "$@"
