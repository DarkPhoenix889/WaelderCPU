----------------------------------------------------------------------------------------------------------------------------|
-- Company: HTBLUVA Rankweil (school)                                                                                       |
-- Engineers: Raphael SCHÖFFMANN & Kilian SIMMA                                                                             |
-- Create Date: 24.11.2025 14:28:40                                                                                         |
-- Design Name: waelderCPU                                                                                                  |
-- Module Name: waelderMain - Behavioral                                                                                    |
-- Project Name: waelderCPU                                                                                                 |
-- Target Devices: Spartan 7                                                                                                |
-- Tool Versions: Vivado 2025.1, Visual Studio Code                                                                         |
-- Description:                                                                                                             |
-- This is part of the Diploma-Thesis "WälderCPU" by SCHÖFFMANN Raphael and SIMMA Kilian - designing an 8-Bit CPU in VHDL   |
-- Revision:                                                                                                                |
-- Revision 0.01 - File Created                                                                                             |
-- Revision 0.1 - Declared Bus                                                                                              |
-- Revision 0.11 - Added flags and registers  
-- Revision 0.2 - Added Alu
-- Revision 0.3 - Added CU (almost finished)
-- Revision 0.31 - PC and reg_in                                                                            |
-- Additional Comments:                                                                                                     |
-- none so far                                                                                                              |
----------------------------------------------------------------------------------------------------------------------------|
----------------------------------|-----------------------------------|
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY waelderMain IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC
        ----------------------------------------|
        ----------declare in/output ports WIP---|
        ----------------------------------------|

        --for alu testing purposes only--
        --alu_reg_a : in std_logic_vector (7 downto 0);    --alu reg 1
        --alu_reg_b : in std_logic_vector (7 downto 0);    --alu reg 2
        --alu_result : out std_logic_vector (7 downto 0);  --alu output - dependant what operation is being made
        --ctrl_alu : in std_logic_vector (2 downto 0)    --alu control register - gets filled by CU with OP-Code
    );
END waelderMain;

ARCHITECTURE Behavioral OF waelderMain IS

    -- flag declaration --
    ------------------output control flags-------------------------------|
    SIGNAL ctrl_pc_l_out : STD_LOGIC; --pc l(ower) 8 bits out
    SIGNAL ctrl_pc_h_out : STD_LOGIC; --pc h(igher) 8 bits out    
    SIGNAL ctrl_ir_out : STD_LOGIC; --instruction register out
    SIGNAL ctrl_alu_out : STD_LOGIC; --arithmetic logical unit out
    SIGNAL ctrl_ram_out : STD_LOGIC; --random access memory out
    SIGNAL ctrl_ar_out : STD_LOGIC; --register a out
    SIGNAL ctrl_br_out : STD_LOGIC; --reg b out
    SIGNAL ctrl_cr_out : STD_LOGIC; --reg c out
    SIGNAL ctrl_dr_out : STD_LOGIC; --reg d out
    SIGNAL ctrl_er_out : STD_LOGIC; --reg e out
    SIGNAL ctrl_lr_out : STD_LOGIC; --reg l out
    SIGNAL ctrl_hr_out : STD_LOGIC; --reg h out
    SIGNAL ctrl_mr_out : STD_LOGIC; --reg m out (16bit)

    ------------------input control flags--------------------------------|
    SIGNAL ctrl_pc_l_in : STD_LOGIC; --pc l(ower) 8bits in
    SIGNAL ctrl_pc_h_in : STD_LOGIC; --pc h(igher) 8 bits in    
    SIGNAL ctrl_ir_in : STD_LOGIC; --instruction register in
    SIGNAL ctrl_mar_h_in : STD_LOGIC; --memory address register high byte in
    SIGNAL ctrl_mar_l_in : STD_LOGIC; --mar low byte in
    SIGNAL ctrl_ar_in : STD_LOGIC; --register a in
    SIGNAL ctrl_br_in : STD_LOGIC; --reg b in
    SIGNAL ctrl_cr_in : STD_LOGIC; --reg c in
    SIGNAL ctrl_dr_in : STD_LOGIC; --reg d in
    SIGNAL ctrl_er_in : STD_LOGIC; --reg e in
    SIGNAL ctrl_lr_in : STD_LOGIC; --reg l in
    SIGNAL ctrl_hr_in : STD_LOGIC; --reg h in
    SIGNAL ctrl_mr_in : STD_LOGIC; --reg m in (16bit)
    SIGNAL ctrl_ram_in : STD_LOGIC; --ram in

    -- register deeclaration --
    ------------------instruction register-------------------------------|
    SIGNAL i_reg : STD_LOGIC_VECTOR (7 DOWNTO 0);

    ----------------------general purpose register-----------------------|
    SIGNAL a_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); --reg a
    SIGNAL b_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); --reg b
    SIGNAL c_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); --reg c
    SIGNAL d_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); --reg d
    SIGNAL e_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); --reg e
    SIGNAL l_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); --reg l
    SIGNAL h_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); --reg h
    SIGNAL m_reg : STD_LOGIC_VECTOR (15 DOWNTO 0); --reg m (16bit reg - consists out of reg h(-igh) + l(-ow))
    --------------------------bus declaration----------------------------|
    SIGNAL data_bus : STD_LOGIC_VECTOR (7 DOWNTO 0);

    --------------------------program counter----------------------------|
    SIGNAL pc : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL pc_next : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ctrl_pc_inc : STD_LOGIC;
    -- ctrl_pc_in & ctrl_pc_out bereits definiert

    -- pc high and low byte
    SIGNAL pc_h : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL pc_l : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL pc_load_h : STD_LOGIC;
    SIGNAL pc_load_l : STD_LOGIC;
    -- alu declaration --
    -----------------------alu in- and outputs---------------------------|
    SIGNAL alu_reg_a : STD_LOGIC_VECTOR (7 DOWNTO 0); --alu reg 1
    SIGNAL alu_reg_b : STD_LOGIC_VECTOR (7 DOWNTO 0); --alu reg 2
    SIGNAL alu_in_a : signed (7 DOWNTO 0); --alu input reg 1 signed value
    SIGNAL alu_in_b : signed (7 DOWNTO 0); --alu input reg 2 signed value

    SIGNAL alu_result : STD_LOGIC_VECTOR (7 DOWNTO 0); --alu output - dependant what operation is being made

    --alu flags (f_ for flag)
    SIGNAL f_overflow : STD_LOGIC; --overflow - if number is bigger than 127
    SIGNAL f_zero : STD_LOGIC; --zero flag - if alu is 0
    SIGNAL f_parity : STD_LOGIC; --parity flag - if alu has even parity
    SIGNAL f_sign : STD_LOGIC; --sign flag - if value is negative
    SIGNAL f_comp : STD_LOGIC; --compare flag for ifs

    --alu ctrl bits
    SIGNAL ctrl_alu : STD_LOGIC_VECTOR (2 DOWNTO 0); --alu control register - gets filled by CU with OP-Code
    --instruction decoding-----------------------------------------------|
    -- Type definition for all supported instructions
    TYPE instr_t IS (
        NOP, RST, INR, DCR, CAL, RET, CCC, RCC, JMP, JCC,
        PUSH, LOAD, ALU, RLC, RRC, LDR, INP, instr_OUT, MOV
    );

    SIGNAL current_instr : instr_t; -- Holds the currently decoded instruction

    -- Opcode field aliases for readability
    SIGNAL x : STD_LOGIC_VECTOR(1 DOWNTO 0); -- type indicator
    SIGNAL y : STD_LOGIC_VECTOR(2 DOWNTO 0); -- variable / register
    SIGNAL z : STD_LOGIC_VECTOR(2 DOWNTO 0); -- secondary indicator
    --CU-----------------------------------------------|
    TYPE t_state_t IS (
        S_RESET,
        S_FETCH_1,
        S_FETCH_2,
        S_DECODE,
        S_EXEC_1,
        S_EXEC_2,
        S_EXEC_3
    );

    SIGNAL state : t_state_t;
    SIGNAL next_state : t_state_t;

BEGIN
    -- m-register --
    m_reg <= h_reg & l_reg; -- m_reg is no real register just a wiring of both - h and l registers
    alu_in_a <= signed(alu_reg_a);
    alu_in_b <= signed(alu_reg_b);

    -----------------------------async reset-----------------------------|
    PROCESS (reset)
    BEGIN
        IF reset = '1' THEN
            --output control flags--|
            ctrl_pc_l_out <= '0';
            ctrl_pc_h_out <= '0';
            ctrl_ir_out <= '0';
            ctrl_alu_out <= '0';
            ctrl_ram_out <= '0';
            ctrl_ar_out <= '0';
            ctrl_br_out <= '0';
            ctrl_cr_out <= '0';
            ctrl_dr_out <= '0';
            ctrl_er_out <= '0';
            ctrl_lr_out <= '0';
            ctrl_hr_out <= '0';
            ctrl_mr_out <= '0';

            --input control flags--|
            ctrl_pc_l_in <= '0';
            ctrl_pc_h_in <= '0';
            ctrl_ir_in <= '0';
            ctrl_mar_h_in <= '0';
            ctrl_mar_l_in <= '0';
            ctrl_ar_in <= '0';
            ctrl_br_in <= '0';
            ctrl_cr_in <= '0';
            ctrl_dr_in <= '0';
            ctrl_er_in <= '0';
            ctrl_lr_in <= '0';
            ctrl_hr_in <= '0';
            ctrl_mr_in <= '0';
            ctrl_ram_in <= '0';

            --instruction register--|
            i_reg <= (OTHERS => '0');

            --general purpose register--|
            a_reg <= (OTHERS => '0');
            b_reg <= (OTHERS => '0');
            c_reg <= (OTHERS => '0');
            d_reg <= (OTHERS => '0');
            e_reg <= (OTHERS => '0');
            l_reg <= (OTHERS => '0');
            h_reg <= (OTHERS => '0');
            m_reg <= (OTHERS => '0');

            --bus declaration--|
            data_bus <= (OTHERS => '0');

            --program counter--|
            pc <= (OTHERS => '0');
            pc_next <= (OTHERS => '0');
            ctrl_pc_inc <= '0';

            pc_h <= (OTHERS => '0');
            pc_l <= (OTHERS => '0');
            pc_load_h <= '0';
            pc_load_l <= '0';

            --alu--|
            alu_reg_a <= (OTHERS => '0');
            alu_reg_b <= (OTHERS => '0');
            alu_in_a <= (OTHERS => '0');
            alu_in_b <= (OTHERS => '0');

            alu_result <= (OTHERS => '0');

            f_overflow <= '0';
            f_zero <= '0';
            f_parity <= '0';
            f_sign <= '0';
            f_comp <= '0';

            ctrl_alu <= (OTHERS => '0');
            --control unit--|
            current_instr <= NOP;

            x <= (OTHERS => '0');
            y <= (OTHERS => '0');
            z <= (OTHERS => '0');
        END IF;
    END PROCESS;
    ------------------------------data bus-------------------------------|
    PROCESS (ctrl_pc_l_out, ctrl_pc_h_out, ctrl_ir_out, ctrl_ar_out, ctrl_br_out, ctrl_cr_out, ctrl_dr_out, ctrl_er_out,
        ctrl_lr_out, ctrl_hr_out, ctrl_alu_out)
    BEGIN
        IF ctrl_pc_l_out = '1' THEN
            data_bus <= pc_l;
        ELSIF ctrl_pc_h_out = '1' THEN
            data_bus <= pc_h;
        ELSIF ctrl_ir_out = '1' THEN
            data_bus <= i_reg;
        ELSIF ctrl_ar_out = '1' THEN
            data_bus <= a_reg;
        ELSIF ctrl_br_out = '1' THEN
            data_bus <= b_reg;
        ELSIF ctrl_cr_out = '1' THEN
            data_bus <= c_reg;
        ELSIF ctrl_dr_out = '1' THEN
            data_bus <= d_reg;
        ELSIF ctrl_er_out = '1' THEN
            data_bus <= e_reg;
        ELSIF ctrl_hr_out = '1' THEN
            data_bus <= h_reg;
        ELSIF ctrl_lr_out = '1' THEN
            data_bus <= l_reg;
        ELSIF ctrl_alu_out = '1' THEN
            data_bus <= alu_result;
        ELSE
            --mem(mar) when ctrl_ram_out = '1' else memory is implemented later on
            data_bus <= (OTHERS => '0');
        END IF;

        IF ctrl_ir_in = '1' THEN
            i_reg <= data_bus;
        ELSIF ctrl_ar_in = '1' THEN
            a_reg <= data_bus;
        ELSIF ctrl_br_in = '1' THEN
            b_reg <= data_bus;
        ELSIF ctrl_cr_in = '1' THEN
            c_reg <= data_bus;
        ELSIF ctrl_dr_in = '1' THEN
            d_reg <= data_bus;
        ELSIF ctrl_er_in = '1' THEN
            e_reg <= data_bus;
        ELSIF ctrl_hr_in = '1' THEN
            h_reg <= data_bus;
        ELSIF ctrl_lr_in = '1' THEN
            l_reg <= data_bus;
        END IF;
    END PROCESS;
    ---------------------------------ALU----------------------------------|
    PROCESS (alu_reg_a, alu_reg_b, alu_in_a, alu_in_b, ctrl_alu)
        VARIABLE tmp_res : signed (8 DOWNTO 0);
    BEGIN
        CASE ctrl_alu IS
            WHEN "000" => --ADD
                tmp_res := resize(alu_in_a, 9) + resize(alu_in_b, 9);

            WHEN "001" => --SUBTRACT
                tmp_res := resize(alu_in_a, 9) - resize(alu_in_b, 9);

            WHEN "010" => --AND
                tmp_res := signed('0' & (alu_reg_a AND alu_reg_b));

            WHEN "011" => --OR
                tmp_res := signed('0' & (alu_reg_a OR alu_reg_b));

            WHEN "100" => --NOT (just reg a)
                tmp_res := signed('0' & (NOT alu_reg_a));

            WHEN "101" => --XOR
                tmp_res := signed('0' & (alu_reg_a XOR alu_reg_b));

            WHEN "110" => --COMPARE
                IF (alu_reg_a = alu_reg_b) THEN
                    f_comp <= '1';
                ELSE
                    f_comp <= '0';
                END IF;
                tmp_res := "000000000";

            WHEN "111" =>
                --undefined - set everything 0
                tmp_res := "000000000";

            WHEN OTHERS =>
                tmp_res := "000000000";

        END CASE;

        alu_result <= STD_LOGIC_VECTOR(tmp_res(7 DOWNTO 0));

        --flag logic
        IF tmp_res = 0 THEN
            f_zero <= '1'; --zero flag if result is equal to 0
        ELSE
            f_zero <= '0';
        END IF;

        -- Overflow - only needed for ADD and SUBTRACT
        IF ctrl_alu = "000" OR ctrl_alu = "001" THEN
            f_overflow <= tmp_res(8) XOR tmp_res(7);
        END IF;

        f_sign <= tmp_res(8);

        f_parity <= tmp_res(0); --parity is odd if LSB equals '1'

    END PROCESS;
    --▇▅▆▇▆▅▅█

    --------------------------program counter----------------------------|
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            pc <= (OTHERS => '0'); -- set pc to 0 on reset
        ELSIF rising_edge(clk) THEN
            IF ctrl_pc_l_in = '1' THEN
                pc(7 DOWNTO 0) <= data_bus;
            ELSIF ctrl_pc_h_in = '1' THEN
                pc(15 DOWNTO 8) <= data_bus;
            ELSIF ctrl_pc_inc = '1' THEN
                pc <= STD_LOGIC_VECTOR(unsigned(pc) + 1);
            END IF;
        END IF;
    END PROCESS;

    --control unit

    ---------------------------------------------------------------------|
    -- Instruction Decoder
    ---------------------------------------------------------------------|
    PROCESS (x, y, z)
    BEGIN
        -- Default value to ensure clean synthesis
        current_instr <= NOP;

        CASE x IS
                --------------------------------------------------------------
                -- Type 00: No Variables
                --------------------------------------------------------------
            WHEN "00" =>
                CASE z IS
                    WHEN "000" =>
                        IF y = "000" THEN
                            current_instr <= NOP;
                        ELSIF y = "001" THEN
                            current_instr <= INP;
                        END IF;
                    WHEN "001" =>
                        IF y = "001" THEN
                            current_instr <= instr_OUT;
                        ELSE
                            current_instr <= RST;
                        END IF;
                    WHEN "010" => current_instr <= JMP;
                    WHEN "100" => current_instr <= CAL;
                    WHEN "101" => current_instr <= RET;
                    WHEN OTHERS => --current_instr stays the same
                END CASE;

                --------------------------------------------------------------
                -- Type 01: Ops with Vars
                --------------------------------------------------------------
            WHEN "01" =>
                CASE z IS
                    WHEN "000" => current_instr <= INR;
                    WHEN "001" => current_instr <= DCR;
                    WHEN "010" => current_instr <= RLC;
                    WHEN "011" => current_instr <= RRC;
                    WHEN "100" => current_instr <= LDR;
                    WHEN "101" => current_instr <= PUSH;
                    WHEN "110" => current_instr <= LOAD;
                    WHEN OTHERS => --current_instr stays the same
                END CASE;

                --------------------------------------------------------------
                -- Type 10: Move OP 
                --------------------------------------------------------------
            WHEN "10" =>
                current_instr <= MOV;

                --------------------------------------------------------------
                -- Type 11: Conditionals + ALU 
                --------------------------------------------------------------
            WHEN "11" =>
                CASE z IS
                    WHEN "000" | "001" => current_instr <= ALU;
                    WHEN "100" => current_instr <= CCC;
                    WHEN "101" => current_instr <= RCC;
                    WHEN "110" => current_instr <= JCC;
                    WHEN OTHERS => current_instr <= ALU;
                END CASE;

            WHEN OTHERS =>
                current_instr <= NOP;
        END CASE;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            state <= S_RESET;
        ELSIF rising_edge(clk) THEN
            state <= next_state;
        END IF;
    END PROCESS;
    PROCESS (state, current_instr)
    BEGIN
        -- Default control signals to avoid latches
        ctrl_pc_l_out <= '0';
        ctrl_pc_h_out <= '0';
        ctrl_pc_inc <= '0';

        ctrl_ir_in <= '0';
        ctrl_ram_out <= '0';
        ctrl_mar_l_in <= '0';
        ctrl_mar_h_in <= '0';
    END Behavioral;