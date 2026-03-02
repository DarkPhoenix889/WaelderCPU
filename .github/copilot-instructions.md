# WaelderCPU AI Coding Guidelines

## Project Overview
WaelderCPU is an 8-bit CPU design in VHDL (Vivado 2025.1) for Spartan 7 FPGA. Diploma thesis project by Raphael Schöffmann & Kilian Simma. The CPU features a multiplexed data bus, 8 GPRs, 16-bit program counter, ALU with 5 flags, and a state-machine control unit with partial instruction decoding.

## Architecture: Critical Data Flow
**CPU Core Loop**: Program Counter (16-bit) → Instruction Register (8-bit) → Control Unit decodes → ALU/Registers execute → Results back to bus
- **Unified 8-bit Data Bus**: Single-source multiplexer (priority: PC_L > PC_H > IR > A-E > H > L > ALU > 0)
- **Register File**: A,B,C,D,E (8-bit) + H,L (8-bit, form 16-bit M). M is wired (not stored): `m_reg <= h_reg & l_reg`
- **16-bit PC**: Split into bytes (PC_L, PC_H) for bus transfers; increments on `ctrl_pc_inc = '1'`

## Control Flow: x/y/z Instruction Decode
Opcodes split as: `x(1:0) | y(2:0) | z(2:0)`. Instruction type determined by x:
- **00 (x)**: No-var ops (NOP, RST, JMP, CAL, RET, INP, OUT) - type selected by z/y
- **01 (x)**: Register ops (INR, DCR, RLC, RRC, LDR, PUSH, LOAD) - register via y
- **10 (x)**: MOV (move between registers)
- **11 (x)**: ALU ops & conditionals (ALU, CCC, RCC, JCC) - operation via z

Instruction list in [waelderMain.vhd](waelderMain.vhd#L133): `instr_t` enum.

## ALU: Operations & Flags
**ctrl_alu 3-bit codes**: "000"=ADD, "001"=SUB, "010"=AND, "011"=OR, "100"=NOT, "101"=XOR, "110"=COMPARE, "111"=undefined
- **Inputs**: `alu_reg_a`, `alu_reg_b` (8-bit); signed for ADD/SUB, unsigned for logic
- **Output**: `alu_result` (8-bit) + flags: `f_zero`, `f_overflow`, `f_sign`, `f_parity`, `f_comp` (compare)
- **Flag Logic** [waelderMain.vhd](waelderMain.vhd#L328): Zero if result=0; overflow (ADD/SUB only) if MSB⊕bit7; parity=LSB

## Control Unit: State Machine (waelderCPU.vhdl variant)
File `waelderCPU.vhdl` (more complete) uses state machine: RESET → FETCH_1 → FETCH_2 → DECODE → EXEC_1/2/3. File [waelderMain.vhd](waelderMain.vhd) implements instruction decoder only (partial CU).

## Signal Naming Conventions
- **Control**: `ctrl_*_out` (component→bus), `ctrl_*_in` (bus→component). E.g., `ctrl_ar_out` (A reg drive), `ctrl_ar_in` (load A)
- **Registers**: `*_reg` (a_reg, i_reg, pc); **Flags**: `f_*` (f_zero, f_overflow); **ALU**: `alu_result`, `alu_reg_a/b`

## Key Behavioral Details
- **Async reset**: All signals to 0 on `reset='1'` [waelderMain.vhd](waelderMain.vhd#L145)
- **Register load**: `data_bus` → register when `ctrl_*_in='1'` on rising clock edge [waelderMain.vhd](waelderMain.vhd#L295)
- **Bus contention**: Combinatorial if-else priority prevents conflicts [waelderMain.vhd](waelderMain.vhd#L267)
- **PC split**: PC(7:0)=pc_l, PC(15:8)=pc_h; load separately via `ctrl_pc_l_in`/`ctrl_pc_h_in` [waelderMain.vhd](waelderMain.vhd#L349)

## Testing & Verification
- **Testbench** ([waelderMain_tb.vhd](waelderCPU_Vivado/waelderCPU.srcs/sim_1/new/waelderMain_tb.vhd)): Tests ALU ops sequentially, clk=10ns (100MHz). Format: set inputs → wait 20ns → observe result/flags
- **Sim Execution**: Vivado Behavioral Simulation (tcl scripts in [waelderCPU.sim/sim_1/behav/xsim/](waelderCPU_Vivado/waelderCPU.sim/sim_1/behav/xsim/))
- **ALU Testing Only**: Comment out testbench entity port declarations, expose `alu_reg_a/b`, `alu_result`, `ctrl_alu` as ports</content>
<parameter name="filePath">c:\Users\Kilian\Documents\GitHub\WaelderCPU\.github\copilot-instructions.md