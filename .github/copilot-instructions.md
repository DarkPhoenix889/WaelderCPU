# WaelderCPU AI Coding Guidelines

## Project Overview
WaelderCPU is an 8-bit CPU design implemented in VHDL for Spartan 7 FPGA, targeting Vivado 2025.1. The architecture features a data bus connecting registers (A,B,C,D,E,H,L,M), ALU, program counter, instruction register, and memory interface.

## Architecture Components
- **Registers**: 8-bit GPRs (A,B,C,D,E) + 16-bit HL pair (M = H & L)
- **ALU**: Supports ADD/SUB/AND/OR/NOT/XOR/COMPARE with flags (overflow, zero, parity, sign, compare)
- **Control Unit**: Decodes instructions using x(1:0), y(2:0), z(2:0) fields from 8-bit opcodes
- **Data Bus**: Multiplexed output from components based on ctrl_*_out signals

## Key Files
- `waelderCPU.vhdl` / `waelderMain.vhd`: Main CPU entity and behavioral architecture
- `waelderMain_tb.vhd`: Testbench for ALU verification
- `waelderCPU_Vivado/waelderCPU.xpr`: Vivado project file

## Development Workflow
1. Edit VHDL files in VS Code
2. Open `waelderCPU.xpr` in Vivado for synthesis/simulation
3. Run behavioral simulation using Vivado Simulator
4. Synthesize for Spartan 7 target

## Coding Conventions
- **Signal Naming**: 
  - Control flags: `ctrl_*_out` / `ctrl_*_in` (e.g., `ctrl_pc_out`, `ctrl_ar_in`)
  - ALU flags: `f_*` (e.g., `f_zero`, `f_overflow`)
  - Registers: `*_reg` (e.g., `a_reg`, `pc`)
- **Instruction Decoding**: Use x/y/z bit fields to categorize instructions (type 00=no vars, 01=ops with vars, 10=move, 11=conditionals/ALU)
- **ALU Operations**: 3-bit ctrl_alu ("000"=ADD, "001"=SUB, "010"=AND, etc.)
- **Bus Logic**: Asynchronous process with priority-based multiplexing (PC > IR > registers > ALU > default '0')

## Testing Patterns
- ALU testing: Drive `alu_reg_a`, `alu_reg_b`, `ctrl_alu`; observe `alu_result` and flags
- Clock: 50MHz (20ns period) generated in testbench
- Reset: Asynchronous active-high reset

## Common Patterns
- Registers load from bus when respective `ctrl_*_in = '1'` on clock edge
- ALU inputs signed for arithmetic, unsigned for logic ops
- M register is combinatorial concatenation of H and L registers
- Instruction register holds current opcode for decoding x/y/z fields</content>
<parameter name="filePath">c:\Users\Kilian\Documents\GitHub\WaelderCPU\.github\copilot-instructions.md