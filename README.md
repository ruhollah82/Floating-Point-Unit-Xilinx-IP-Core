# Floating Point Unit (FPU) - Vivado Project

## Overview
This project implements a Floating Point Unit (FPU) using VHDL in Xilinx Vivado. The FPU supports four basic arithmetic operations:
- Addition
- Subtraction
- Multiplication
- Division

The FPU interfaces with AXI-Stream based arithmetic components and processes 32-bit floating-point numbers.

## Features
- Supports IEEE 754 single-precision floating-point format (32-bit)
- Implements a finite state machine (FSM) for operation control
- Uses AXI-Stream protocol for operand and result transfer
- Synchronous operation with clock and reset signals

## Entity Definition
```vhdl
entity FPU_top is
    Port (
        A       : in  STD_LOGIC_VECTOR(31 downto 0);
        B       : in  STD_LOGIC_VECTOR(31 downto 0);
        op      : in  STD_LOGIC_VECTOR(1 downto 0);
        clock   : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        result  : out STD_LOGIC_VECTOR(31 downto 0);
        valid   : out STD_LOGIC  
    );
end FPU_top;
```

## Operation
- The FPU takes two 32-bit floating-point inputs (`A`, `B`) and a 2-bit operation selector (`op`).
- The operation selector (`op`) is defined as:
  - `00`: Addition
  - `01`: Subtraction
  - `10`: Multiplication
  - `11`: Division
- The control FSM manages operand transfer and waits for the result to be ready.
- Once the computation is complete, the `result` output is updated, and `valid` is asserted.

## Components
The FPU instantiates the following submodules for computation:
- `add` : Floating-point adder
- `sub` : Floating-point subtractor
- `mul` : Floating-point multiplier
- `div` : Floating-point divider

Each component follows the AXI-Stream interface with `tvalid`, `tready`, and `tdata` signals.

## Simulation and Synthesis
### Simulation
1. Use Vivado's built-in simulator (XSim) or an external simulator such as ModelSim.
2. Provide test vectors to verify each arithmetic operation.

### Synthesis
1. Open Vivado and create a new project.
2. Add `FPU_top.vhd` and its dependencies.
3. Run synthesis and implementation.
4. Generate the bitstream.

## Dependencies
- Xilinx Vivado (Tested on version 2023.1)
- AXI-Stream compatible arithmetic cores

## Future Improvements
- Support for additional floating-point operations (e.g., square root, exponentiation)
- Pipelining for improved performance
- Optimized resource utilization

## Author
Ruhollah

