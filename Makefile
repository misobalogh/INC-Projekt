# Makefile for INC-Projekt UART Implementation

.PHONY: all uart shift_reg test clean help install-deps

# Default target
all: uart shift_reg

# Build UART receiver
uart:
	@echo "Building UART Receiver..."
	@./scripts/build_uart.sh

# Build shift register
shift_reg:
	@echo "Building Shift Register..."
	@./scripts/build_shift_reg.sh

# Run all tests
test:
	@echo "Running all tests..."
	@./scripts/build_all.sh test

# Clean all build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@./scripts/build_all.sh clean

# Install dependencies (Ubuntu/Debian)
install-deps:
	@echo "Installing dependencies..."
	@sudo apt-get update
	@sudo apt-get install -y ghdl gtkwave

# Install dependencies (Fedora/RHEL)
install-deps-fedora:
	@echo "Installing dependencies (Fedora)..."
	@sudo dnf install -y ghdl gtkwave

# Install dependencies (Arch Linux)
install-deps-arch:
	@echo "Installing dependencies (Arch)..."
	@sudo pacman -S ghdl gtkwave

# Show help
help:
	@echo "Available targets:"
	@echo "  all          - Build all components (default)"
	@echo "  uart         - Build UART receiver only"
	@echo "  shift_reg    - Build shift register only"
	@echo "  test         - Run all tests"
	@echo "  clean        - Clean build artifacts"
	@echo "  install-deps - Install dependencies (Ubuntu/Debian)"
	@echo "  install-deps-fedora - Install dependencies (Fedora/RHEL)"
	@echo "  install-deps-arch   - Install dependencies (Arch Linux)"
	@echo "  help         - Show this help message"

# Project information
info:
	@echo "INC-Projekt: UART Implementation in VHDL"
	@echo "========================================="
	@echo "Components:"
	@echo "  - UART Receiver (uart_rx.vhd, uart_rx_fsm.vhd)"
	@echo "  - Shift Register (shift_register.vhd)"
	@echo "  - Comprehensive testbenches"
	@echo "  - Build automation scripts"
	@echo ""
	@echo "Usage: make [target]"
	@echo "See 'make help' for available targets"
