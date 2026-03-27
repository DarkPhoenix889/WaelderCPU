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
        reset : IN STD_LOGIC;

        led_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        switch_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
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
    COMPONENT waelderRAM IS
        PORT (
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            di : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            do : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

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

    SIGNAL ctrl_ar_inc : STD_LOGIC;
    SIGNAL ctrl_br_inc : STD_LOGIC;
    SIGNAL ctrl_cr_inc : STD_LOGIC;
    SIGNAL ctrl_dr_inc : STD_LOGIC;
    SIGNAL ctrl_er_inc : STD_LOGIC;
    SIGNAL ctrl_lr_inc : STD_LOGIC;
    SIGNAL ctrl_hr_inc : STD_LOGIC;
    SIGNAL ctrl_mr_inc : STD_LOGIC;

    SIGNAL ctrl_ar_dec : STD_LOGIC;
    SIGNAL ctrl_br_dec : STD_LOGIC;
    SIGNAL ctrl_cr_dec : STD_LOGIC;
    SIGNAL ctrl_dr_dec : STD_LOGIC;
    SIGNAL ctrl_er_dec : STD_LOGIC;
    SIGNAL ctrl_lr_dec : STD_LOGIC;
    SIGNAL ctrl_hr_dec : STD_LOGIC;
    SIGNAL ctrl_mr_dec : STD_LOGIC;

    SIGNAL ctrl_cur_in : STD_LOGIC; -- Control Unit Register in
    SIGNAL ctrl_cur_out : STD_LOGIC; -- Control Unit Register out

    SIGNAL ctrl_io_out : STD_LOGIC;
    SIGNAL ctrl_io_in : STD_LOGIC;
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
    -----------------------------i/o-register----------------------------|
    SIGNAL io_reg_out : STD_LOGIC_VECTOR(7 DOWNTO 0); -- connected to LEDS
    SIGNAL io_reg_in : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Connected to switches
    --------------------------bus declaration----------------------------|
    SIGNAL data_bus : STD_LOGIC_VECTOR (7 DOWNTO 0);

    --------------------------------MAR----------------------------------|
    SIGNAL mar : STD_LOGIC_VECTOR (15 DOWNTO 0); --memory address register
    SIGNAL mar_h : STD_LOGIC_VECTOR (7 DOWNTO 0); --mar high byte
    SIGNAL mar_l : STD_LOGIC_VECTOR (7 DOWNTO 0); --mar low byte
    SIGNAL ctrl_mar_inc : STD_LOGIC; --control signal for incrementing mar

    --------------------------program counter----------------------------|
    SIGNAL pc : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL ctrl_pc_inc : STD_LOGIC;
    -- ctrl_pc_in & ctrl_pc_out bereits definiert
    -- pc high and low byte
    SIGNAL pc_h : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL pc_l : STD_LOGIC_VECTOR (7 DOWNTO 0);

    -------------------------Stack Pointer-------------------------------|
    -- Stack Pointer Signals
    SIGNAL sp_h : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '1'); -- Starts at FF
    SIGNAL sp_l : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '1'); -- Starts at FF
    SIGNAL sp : STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- Control Flags for SP
    SIGNAL ctrl_sp_h_out : STD_LOGIC;
    SIGNAL ctrl_sp_l_out : STD_LOGIC;
    SIGNAL ctrl_sp_dec : STD_LOGIC; -- Decrement for PUSH
    SIGNAL ctrl_sp_inc : STD_LOGIC; -- Increment for POP/RET

    --------------------------CU Register--------------------------------|
    SIGNAL cui_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); -- CU input register
    SIGNAL cuo_reg : STD_LOGIC_VECTOR (7 DOWNTO 0); -- CU output register
    -- we need 2 different registers for number creation, beacause you
    -- can only assign a value to a signal once per process
    -- cuo_reg is for the LDR instruction, cui_reg is for the ALU instruction
    -- alu declaration --
    -----------------------alu in- and outputs---------------------------|
    SIGNAL alu_reg_a : STD_LOGIC_VECTOR (7 DOWNTO 0); --alu reg 1
    SIGNAL alu_reg_b : STD_LOGIC_VECTOR (7 DOWNTO 0); --alu reg 2
    SIGNAL alu_in_a : signed (7 DOWNTO 0); --alu input reg 1 signed value
    SIGNAL alu_in_b : signed (7 DOWNTO 0); --alu input reg 2 signed value
    SIGNAL ctrl_alu_ar_in : STD_LOGIC; --control signal for alu reg a in
    SIGNAL ctrl_alu_br_in : STD_LOGIC; --control signal for alu reg b

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

    ---------RAM---------------------------------------|
    SIGNAL ram_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0); --signal between RAM and DataBus
    --CU-----------------------------------------------|
    TYPE t_state_t IS (
        S_RESET,
        S_FETCH_1,
        S_FETCH_2,
        S_FETCH_3,
        S_FETCH_4,
        S_FETCH_5,
        S_FETCH_6,
        S_DECODE,
        S_EXEC_1,
        S_EXEC_2,
        S_EXEC_3,
        S_EXEC_4,
        S_EXEC_5,
        S_EXEC_6,
        S_EXEC_7,
        S_EXEC_8,
        S_EXEC_9,
        S_EXEC_10
    );

    SIGNAL state : t_state_t;
    SIGNAL next_state : t_state_t;

BEGIN
    U_RAM : waelderRAM
    PORT MAP(
        clk => clk,
        we => ctrl_ram_in,
        addr => mar,
        di => data_bus,
        do => ram_data_out
    );
    -- m-register --
    m_reg <= h_reg & l_reg; -- m_reg is no real register just a wiring of both - h and l registers

    -- alu inputs --
    alu_in_a <= signed(alu_reg_a);
    alu_in_b <= signed(alu_reg_b);

    -- pc --
    pc <= pc_h & pc_l;

    -- mar --
    mar <= mar_h & mar_l;

    led_out <= io_reg_out;
    io_reg_in <= switch_in;

    -- sp --
    sp <= sp_h & sp_l;

    ------------------------------data bus-------------------------------|
    PROCESS (clk, reset, ctrl_pc_l_out, ctrl_pc_h_out, ctrl_ir_out, ctrl_ar_out, ctrl_br_out,
        ctrl_cr_out, ctrl_dr_out, ctrl_er_out, ctrl_lr_out, ctrl_hr_out, ctrl_alu_out,
        ctrl_ram_out, pc_l, pc_h, i_reg, a_reg, b_reg, c_reg, d_reg, e_reg, h_reg, l_reg,
        alu_result, ram_data_out, ctrl_io_out, ctrl_io_in)
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
        ELSIF ctrl_ram_out = '1' THEN
            data_bus <= ram_data_out;
        ELSIF ctrl_cur_out = '1' THEN
            data_bus <= cuo_reg;
        ELSIF ctrl_sp_l_out = '1' THEN
            data_bus <= sp_l;
        ELSIF ctrl_sp_h_out = '1' THEN
            data_bus <= sp_h;
        ELSIF ctrl_io_in = '1' THEN
            data_bus <= io_reg_in;
        END IF;

        -- 2. SYNCHRONOUS REGISTER UPDATES
        IF reset = '1' THEN
            i_reg <= (OTHERS => '0');
            a_reg <= (OTHERS => '0');
            b_reg <= (OTHERS => '0');
            c_reg <= (OTHERS => '0');
            d_reg <= (OTHERS => '0');
            e_reg <= (OTHERS => '0');
            h_reg <= (OTHERS => '0');
            l_reg <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN

            -- Register A Logic
            IF ctrl_ar_in = '1' THEN
                a_reg <= data_bus;
            ELSIF ctrl_ar_inc = '1' THEN
                a_reg <= STD_LOGIC_VECTOR(unsigned(a_reg) + 1);
            ELSIF ctrl_ar_dec = '1' THEN
                a_reg <= STD_LOGIC_VECTOR(unsigned(a_reg) - 1);
            END IF;

            -- Register B Logic
            IF ctrl_br_in = '1' THEN
                b_reg <= data_bus;
            ELSIF ctrl_br_inc = '1' THEN
                b_reg <= STD_LOGIC_VECTOR(unsigned(b_reg) + 1);
            ELSIF ctrl_br_dec = '1' THEN
                b_reg <= STD_LOGIC_VECTOR(unsigned(b_reg) - 1);
            END IF;

            -- Register C Logic
            IF ctrl_cr_in = '1' THEN
                c_reg <= data_bus;
            ELSIF ctrl_cr_inc = '1' THEN
                c_reg <= STD_LOGIC_VECTOR(unsigned(c_reg) + 1);
            ELSIF ctrl_cr_dec = '1' THEN
                c_reg <= STD_LOGIC_VECTOR(unsigned(c_reg) - 1);
            END IF;

            -- Register D Logic
            IF ctrl_dr_in = '1' THEN
                d_reg <= data_bus;
            ELSIF ctrl_dr_inc = '1' THEN
                d_reg <= STD_LOGIC_VECTOR(unsigned(d_reg) + 1);
            ELSIF ctrl_dr_dec = '1' THEN
                d_reg <= STD_LOGIC_VECTOR(unsigned(d_reg) - 1);
            END IF;

            -- Register E Logic
            IF ctrl_er_in = '1' THEN
                e_reg <= data_bus;
            ELSIF ctrl_er_inc = '1' THEN
                e_reg <= STD_LOGIC_VECTOR(unsigned(e_reg) + 1);
            ELSIF ctrl_er_dec = '1' THEN
                e_reg <= STD_LOGIC_VECTOR(unsigned(e_reg) - 1);
            END IF;

            -- Register H Logic
            IF ctrl_hr_in = '1' THEN
                h_reg <= data_bus;
            ELSIF ctrl_hr_inc = '1' THEN
                h_reg <= STD_LOGIC_VECTOR(unsigned(h_reg) + 1);
            ELSIF ctrl_hr_dec = '1' THEN
                h_reg <= STD_LOGIC_VECTOR(unsigned(h_reg) - 1);
            END IF;

            -- Register L Logic
            IF ctrl_lr_in = '1' THEN
                l_reg <= data_bus;
            ELSIF ctrl_lr_inc = '1' THEN
                l_reg <= STD_LOGIC_VECTOR(unsigned(l_reg) + 1);
            ELSIF ctrl_lr_dec = '1' THEN
                l_reg <= STD_LOGIC_VECTOR(unsigned(l_reg) - 1);
            END IF;

            -- Instruction Register (usually doesn't need inc)
            IF ctrl_ir_in = '1' THEN
                i_reg <= data_bus;
            END IF;

            -- CU Register IN
            IF ctrl_cur_in = '1' THEN
                cui_reg <= data_bus;
            END IF;

            -- IO Register OUT
            IF ctrl_io_out = '1' THEN
                io_reg_out <= data_bus;
            END IF;

            IF ctrl_alu_ar_in = '1' THEN
                alu_reg_a <= data_bus;
            END IF;

            IF ctrl_alu_br_in = '1' THEN
                alu_reg_b <= data_bus;
            END IF;

            IF ctrl_io_out = '1' THEN
                io_reg_out <= data_bus;
            END IF;

        END IF;
    END PROCESS;
    ---------------------------------ALU----------------------------------|
    PROCESS (alu_reg_a, alu_reg_b, alu_in_a, alu_in_b, ctrl_alu, clk)
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
                    tmp_res := "000000000"; -- to set zero flag
                ELSE
                    f_comp <= '0';
                    tmp_res := "111111111";
                END IF;
            WHEN "111" =>
                --undefined - set everything 0
                tmp_res := "000000000";

                --f_parity <= tmp_res(0);  --parity flag
            WHEN OTHERS =>
                --undefined - set everything 0
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

        f_parity <= (tmp_res(0) XOR tmp_res(1) XOR tmp_res(2) XOR tmp_res(3) XOR
            tmp_res(4) XOR tmp_res(5) XOR tmp_res(6));
        -- f_parity <= tmp_res(0);  --parity is odd if LSB equals '1' -> old version

    END PROCESS;
    --▇▅▆▇▆▅▅█

    -------------------------- Program Counter ----------------------------
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            pc_h <= (OTHERS => '0');
            pc_l <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- Direktes Laden hat Vorrang vor Inkrementieren
            IF ctrl_pc_h_in = '1' THEN
                pc_h <= data_bus;
            END IF;

            IF ctrl_pc_l_in = '1' THEN
                pc_l <= data_bus;
            ELSIF ctrl_pc_inc = '1' THEN
                IF pc_l = "11111111" THEN
                    pc_h <= STD_LOGIC_VECTOR(unsigned(pc_h) + 1);
                    pc_l <= "00000000";
                ELSE
                    pc_l <= STD_LOGIC_VECTOR(unsigned(pc_l) + 1);
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------- MAR ---------------------------------
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            mar_h <= (OTHERS => '0');
            mar_l <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- Direktes Laden hat Vorrang vor Inkrementieren
            IF ctrl_mar_h_in = '1' THEN
                mar_h <= data_bus;
            END IF;

            IF ctrl_mar_l_in = '1' THEN
                mar_l <= data_bus;
            ELSIF ctrl_mar_inc = '1' THEN
                IF mar_l = "11111111" THEN
                    mar_h <= STD_LOGIC_VECTOR(unsigned(mar_h) + 1);
                    mar_l <= "00000000";
                ELSE
                    mar_l <= STD_LOGIC_VECTOR(unsigned(mar_l) + 1);
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -------------------------- Stack Pointer ------------------------------
    PROCESS (clk, reset)
        VARIABLE sp_temp : unsigned(15 DOWNTO 0);
    BEGIN
        IF reset = '1' THEN
            sp_h <= (OTHERS => '1'); -- 0xFFFF
            sp_l <= (OTHERS => '1');
        ELSIF rising_edge(clk) THEN
            IF ctrl_sp_dec = '1' THEN
                IF sp_l = "00000000" THEN
                    sp_h <= STD_LOGIC_VECTOR(unsigned(sp_h) - 1);
                    sp_l <= "11111111";
                ELSE
                    sp_l <= STD_LOGIC_VECTOR(unsigned(sp_l) - 1);
                END IF;
            ELSE
                IF ctrl_sp_inc = '1' THEN
                    IF sp_l = "11111111" THEN
                        sp_h <= STD_LOGIC_VECTOR(unsigned(sp_h) + 1);
                        sp_l <= "00000000";
                    ELSE
                        sp_l <= STD_LOGIC_VECTOR(unsigned(sp_l) + 1);
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --Instruction Decoder------------------------------------------------|
    PROCESS (i_reg)
        VARIABLE x : STD_LOGIC_VECTOR(1 DOWNTO 0); -- type indicator
        VARIABLE y : STD_LOGIC_VECTOR(2 DOWNTO 0); -- variable / register
        VARIABLE z : STD_LOGIC_VECTOR(2 DOWNTO 0); -- secondary indicator

    BEGIN
        -- Default value to ensure clean synthesis
        current_instr <= NOP;
        x := i_reg(7 DOWNTO 6);
        y := i_reg(5 DOWNTO 3);
        z := i_reg(2 DOWNTO 0);
        CASE x IS
                -- Type 00: No Variables-------------------------------------|
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

                -- Type 01: Ops with Vars------------------------------------|
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

                -- Type 10: Move OP------------------------------------------|
            WHEN "10" =>
                current_instr <= MOV;

                -- Type 11: Conditionals + ALU-------------------------------|
            WHEN "11" =>
                CASE z IS
                    WHEN "000" => current_instr <= ALU;
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

    --Control Unit-------------------------------------------------------|
    PROCESS (state, current_instr)
        VARIABLE x : STD_LOGIC_VECTOR(1 DOWNTO 0); -- type indicator
        VARIABLE y : STD_LOGIC_VECTOR(2 DOWNTO 0); -- variable / register
        VARIABLE z : STD_LOGIC_VECTOR(2 DOWNTO 0); -- secondary indicator

        VARIABLE a : STD_LOGIC_VECTOR(1 DOWNTO 0); -- first 2 bits of CU register in
        VARIABLE b : STD_LOGIC_VECTOR(2 DOWNTO 0); -- middle 3 bits of CU register in
        VARIABLE c : STD_LOGIC_VECTOR(2 DOWNTO 0); -- last 3 bits of CU register in
    BEGIN
        x := i_reg(7 DOWNTO 6);
        y := i_reg(5 DOWNTO 3);
        z := i_reg(2 DOWNTO 0);
        a := cui_reg(7 DOWNTO 6);
        b := cui_reg(5 DOWNTO 3);
        c := cui_reg(2 DOWNTO 0);
        -- Default control signals to avoid latches
        -- PC
        ctrl_pc_l_out <= '0';
        ctrl_pc_h_out <= '0';
        ctrl_pc_l_in <= '0';
        ctrl_pc_h_in <= '0';
        ctrl_pc_inc <= '0';

        -- IR / MAR / RAM
        ctrl_ir_in <= '0';
        ctrl_ir_out <= '0';
        ctrl_ram_out <= '0';
        ctrl_ram_in <= '0';
        ctrl_mar_l_in <= '0';
        ctrl_mar_h_in <= '0';
        ctrl_mar_inc <= '0';
        ctrl_io_out <= '0';

        -- CU Register
        ctrl_cur_in <= '0';
        ctrl_cur_out <= '0';

        -- SP
        ctrl_sp_l_out <= '0';
        ctrl_sp_h_out <= '0';
        ctrl_sp_inc <= '0';
        ctrl_sp_dec <= '0';

        -- Registers
        ctrl_ar_in <= '0';
        ctrl_br_in <= '0';
        ctrl_cr_in <= '0';
        ctrl_dr_in <= '0';
        ctrl_er_in <= '0';
        ctrl_hr_in <= '0';
        ctrl_lr_in <= '0';

        ctrl_ar_out <= '0';
        ctrl_br_out <= '0';
        ctrl_cr_out <= '0';
        ctrl_dr_out <= '0';
        ctrl_er_out <= '0';
        ctrl_hr_out <= '0';
        ctrl_lr_out <= '0';

        ctrl_ar_inc <= '0';
        ctrl_br_inc <= '0';
        ctrl_cr_inc <= '0';
        ctrl_dr_inc <= '0';
        ctrl_er_inc <= '0';
        ctrl_hr_inc <= '0';
        ctrl_lr_inc <= '0';

        ctrl_ar_dec <= '0';
        ctrl_br_dec <= '0';
        ctrl_cr_dec <= '0';
        ctrl_dr_dec <= '0';
        ctrl_er_dec <= '0';
        ctrl_hr_dec <= '0';
        ctrl_lr_dec <= '0';

        -- ALU
        ctrl_alu_out <= '0';
        ctrl_alu_ar_in <= '0';
        ctrl_alu_br_in <= '0';
        ctrl_alu <= (OTHERS => '0');

        CASE state IS
            WHEN S_RESET =>
                next_state <= S_FETCH_1;
            WHEN S_FETCH_1 =>
                ctrl_pc_l_out <= '1';
                ctrl_mar_l_in <= '1';
                next_state <= S_FETCH_2;

            WHEN S_FETCH_2 =>
                ctrl_pc_h_out <= '1';
                ctrl_mar_h_in <= '1';
                next_state <= S_FETCH_3;

            WHEN S_FETCH_3 =>
                -- wait for RAM
                next_state <= S_FETCH_4;

            WHEN S_FETCH_4 =>
                ctrl_ram_out <= '1';
                ctrl_ir_in <= '1';
                next_state <= S_DECODE;

            WHEN S_DECODE =>
                ctrl_pc_inc <= '1';
                next_state <= S_EXEC_1;

            WHEN S_EXEC_1 =>
                CASE current_instr IS
                    WHEN NOP =>
                        next_state <= S_FETCH_1;

                    WHEN RST =>
                        next_state <= S_RESET;

                    WHEN INR =>
                        CASE y IS
                            WHEN "000" => ctrl_ar_inc <= '1';
                            WHEN "001" => ctrl_br_inc <= '1';
                            WHEN "010" => ctrl_cr_inc <= '1';
                            WHEN "011" => ctrl_dr_inc <= '1';
                            WHEN "100" => ctrl_er_inc <= '1';
                            WHEN "101" => ctrl_hr_inc <= '1';
                            WHEN "110" => ctrl_lr_inc <= '1';
                            WHEN OTHERS =>
                        END CASE;

                        next_state <= S_FETCH_1;

                    WHEN DCR =>
                        CASE y IS
                            WHEN "000" => ctrl_ar_dec <= '1';
                            WHEN "001" => ctrl_br_dec <= '1';
                            WHEN "010" => ctrl_cr_dec <= '1';
                            WHEN "011" => ctrl_dr_dec <= '1';
                            WHEN "100" => ctrl_er_dec <= '1';
                            WHEN "101" => ctrl_hr_dec <= '1';
                            WHEN "110" => ctrl_lr_dec <= '1';
                            WHEN OTHERS =>
                        END CASE;

                        next_state <= S_FETCH_1;

                    WHEN CAL =>
                        ctrl_pc_inc <= '1';

                        next_state <= S_EXEC_2;
                    WHEN RET =>
                        ctrl_lr_out <= '1';
                        ctrl_pc_l_in <= '1';

                        next_state <= S_EXEC_2;

                    WHEN CCC =>

                    WHEN RCC =>

                        CASE y IS
                            WHEN "000" => -- return if zero
                                IF f_zero = '1' THEN
                                    next_state <= S_EXEC_2;
                                ELSE
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "001" => -- return if not zero
                                IF f_zero = '0' THEN
                                    next_state <= S_EXEC_2;
                                ELSE
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "010" => -- return if overflow
                                IF f_overflow = '1' THEN
                                    next_state <= S_EXEC_2;
                                ELSE
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "011" => -- return if not overflow
                                IF f_overflow = '0' THEN
                                    next_state <= S_EXEC_2;
                                ELSE
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "100" => -- return if parity
                                IF f_parity = '1' THEN
                                    next_state <= S_EXEC_2;
                                ELSE
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "101" => -- return if not parity
                                IF f_parity = '0' THEN
                                    next_state <= S_EXEC_2;
                                ELSE
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "110" => -- return if sign
                                IF f_sign = '1' THEN
                                    next_state <= S_EXEC_2;
                                ELSE
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "111" => -- return if not sign
                                IF f_sign = '0' THEN
                                    next_state <= S_EXEC_2;
                                ELSE
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN OTHERS =>
                        END CASE;

                    WHEN JMP =>
                        ctrl_mar_inc <= '1';

                        next_state <= S_EXEC_2;

                    WHEN JCC =>
                        ctrl_pc_inc <= '1';
                        ctrl_mar_inc <= '1';

                        next_state <= S_EXEC_2;
                    WHEN PUSH =>
                        ctrl_sp_l_out <= '1';
                        ctrl_mar_l_in <= '1';

                        next_state <= S_EXEC_2;

                    WHEN LOAD =>
                        ctrl_mar_inc <= '1';
                        ctrl_pc_inc <= '1';

                        next_state <= S_EXEC_2;

                    WHEN ALU =>
                        ctrl_mar_inc <= '1';
                        ctrl_pc_inc <= '1';

                        next_state <= S_EXEC_2;

                    WHEN LDR =>
                        ctrl_mar_inc <= '1';
                        ctrl_pc_inc <= '1';

                        next_state <= S_EXEC_2;
                    WHEN INP =>

                        ctrl_io_in <= '1';

                        CASE c IS
                            WHEN "000" =>
                                ctrl_ar_in <= '1';
                            WHEN "001" =>
                                ctrl_br_in <= '1';
                            WHEN "010" =>
                                ctrl_cr_in <= '1';
                            WHEN "011" =>
                                ctrl_dr_in <= '1';
                            WHEN "100" =>
                                ctrl_er_in <= '1';
                            WHEN "101" =>
                                ctrl_hr_in <= '1';
                            WHEN "110" =>
                                ctrl_lr_in <= '1';
                            WHEN OTHERS =>
                        END CASE;

                        next_state <= S_EXEC_2;

                    WHEN instr_OUT =>
                        ctrl_mar_inc <= '1';
                        ctrl_pc_inc <= '1';

                        next_state <= S_EXEC_2;

                    WHEN MOV =>
                        CASE y IS
                            WHEN "000" =>
                                ctrl_ar_out <= '1';
                            WHEN "001" =>
                                ctrl_br_out <= '1';
                            WHEN "010" =>
                                ctrl_cr_out <= '1';
                            WHEN "011" =>
                                ctrl_dr_out <= '1';
                            WHEN "100" =>
                                ctrl_er_out <= '1';
                            WHEN "101" =>
                                ctrl_hr_out <= '1';
                            WHEN "110" =>
                                ctrl_lr_out <= '1';
                            WHEN OTHERS =>
                                --do nothing
                        END CASE;

                        CASE z IS
                            WHEN "000" =>
                                ctrl_ar_in <= '1';
                            WHEN "001" =>
                                ctrl_br_in <= '1';
                            WHEN "010" =>
                                ctrl_cr_in <= '1';
                            WHEN "011" =>
                                ctrl_dr_in <= '1';
                            WHEN "100" =>
                                ctrl_er_in <= '1';
                            WHEN "101" =>
                                ctrl_hr_in <= '1';
                            WHEN "110" =>
                                ctrl_lr_in <= '1';
                            WHEN OTHERS =>
                                --do nothing
                        END CASE;

                        next_state <= S_FETCH_1;

                    WHEN OTHERS =>
                        next_state <= S_FETCH_1;
                END CASE;
            WHEN S_EXEC_2 =>
                CASE current_instr IS
                    WHEN JMP =>
                        -- wait for RAM
                        next_state <= S_EXEC_3;
                    WHEN CAL =>
                        ctrl_pc_inc <= '1';

                        next_state <= S_EXEC_3;
                    WHEN RET =>
                        ctrl_hr_out <= '1';
                        ctrl_pc_h_in <= '1';

                        next_state <= S_FETCH_1;

                    WHEN ALU =>
                        -- Wait for RAM

                        next_state <= S_EXEC_3;
                    WHEN PUSH =>
                        ctrl_sp_h_out <= '1';
                        ctrl_mar_h_in <= '1';

                        next_state <= S_EXEC_3;
                    WHEN LOAD =>
                        ctrl_ram_out <= '1';
                        ctrl_hr_in <= '1';

                        next_state <= S_EXEC_3;
                    WHEN LDR =>
                        -- wait for RAM
                        next_state <= S_EXEC_3;

                    WHEN instr_OUT =>
                        -- wait for RAM

                        next_state <= S_EXEC_3;
                    WHEN INP =>
                        next_state <= S_FETCH_1;
                    WHEN JCC =>
                        CASE y IS
                            WHEN "000" => -- jump if zero
                                IF f_zero = '1' THEN
                                    next_state <= S_EXEC_3;
                                ELSE
                                    ctrl_pc_inc <= '1';
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "001" => -- jump if not zero
                                IF f_zero = '0' THEN
                                    next_state <= S_EXEC_3;
                                ELSE
                                    ctrl_pc_inc <= '1';
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "010" => -- jump if overflow
                                IF f_overflow = '1' THEN
                                    next_state <= S_EXEC_3;
                                ELSE
                                    ctrl_pc_inc <= '1';
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "011" => -- jump if not overflow
                                IF f_overflow = '0' THEN
                                    next_state <= S_EXEC_3;
                                ELSE
                                    ctrl_pc_inc <= '1';
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "100" => -- jump if parity
                                IF f_parity = '1' THEN
                                    next_state <= S_EXEC_3;
                                ELSE
                                    ctrl_pc_inc <= '1';
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "101" => -- jump if not parity
                                IF f_parity = '0' THEN
                                    next_state <= S_EXEC_3;
                                ELSE
                                    ctrl_pc_inc <= '1';
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "110" => -- jump if sign
                                IF f_sign = '1' THEN
                                    next_state <= S_EXEC_3;
                                ELSE
                                    ctrl_pc_inc <= '1';
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN "111" => -- jump if not sign
                                IF f_sign = '0' THEN
                                    next_state <= S_EXEC_3;
                                ELSE
                                    ctrl_pc_inc <= '1';
                                    next_state <= S_FETCH_1;
                                END IF;
                            WHEN OTHERS =>
                        END CASE;
                    
                    WHEN RCC =>
                        ctrl_hr_out <= '1';
                        ctrl_pc_h_in <= '1';

                        next_state <= S_EXEC_3;

                    WHEN OTHERS =>
                        --do nothing
                END CASE;
            WHEN S_EXEC_3 =>
                CASE current_instr IS
                    WHEN instr_OUT =>
                        ctrl_ram_out <= '1';
                        ctrl_cur_in <= '1';

                        next_state <= S_EXEC_4;
                    WHEN JMP =>
                        ctrl_ram_out <= '1';
                        ctrl_pc_h_in <= '1';

                        next_state <= S_EXEC_4;
                    WHEN CAL =>
                        ctrl_pc_l_out <= '1';
                        ctrl_lr_in <= '1';
                        ctrl_mar_inc <= '1';

                        next_state <= S_EXEC_4;
                    WHEN ALU =>
                        ctrl_ram_out <= '1';
                        ctrl_cur_in <= '1';
                        ctrl_alu <= y;

                        next_state <= S_EXEC_4;

                    WHEN PUSH =>
                        CASE y IS
                            WHEN "000" => ctrl_ar_out <= '1';
                            WHEN "001" => ctrl_br_out <= '1';
                            WHEN "010" => ctrl_cr_out <= '1';
                            WHEN "011" => ctrl_dr_out <= '1';
                            WHEN "100" => ctrl_er_out <= '1';
                            WHEN "101" => ctrl_hr_out <= '1';
                            WHEN "110" => ctrl_lr_out <= '1';
                            WHEN OTHERS => NULL;
                        END CASE;
                        ctrl_ram_in <= '1';
                        next_state <= S_EXEC_4;

                    WHEN LOAD =>
                        ctrl_mar_inc <= '1';
                        ctrl_pc_inc <= '1';

                        next_state <= S_EXEC_4;
                    WHEN LDR =>
                        ctrl_ram_out <= '1';

                        CASE y IS
                            WHEN "000" => ctrl_ar_in <= '1';
                            WHEN "001" => ctrl_br_in <= '1';
                            WHEN "010" => ctrl_cr_in <= '1';
                            WHEN "011" => ctrl_dr_in <= '1';
                            WHEN "100" => ctrl_er_in <= '1';
                            WHEN "101" => ctrl_hr_in <= '1';
                            WHEN "110" => ctrl_lr_in <= '1';
                            WHEN OTHERS =>
                        END CASE;

                        next_state <= S_FETCH_1;

                    WHEN JCC =>
                        -- wait for RAM already done in S_EXEC_2 / MAR already incremented in ECEC_1
                        ctrl_ram_out <= '1';
                        ctrl_pc_h_in <= '1';

                        next_state <= S_EXEC_4;
                    
                    WHEN RCC =>
                        ctrl_lr_out <= '1';
                        ctrl_pc_l_in <= '1';
                        
                        next_state <= S_FETCH_1;
                        
                    WHEN OTHERS =>
                        --do nothing
                END CASE;
            WHEN S_EXEC_4 =>
                CASE current_instr IS
                    WHEN instr_OUT =>
                        ctrl_io_out <= '1';

                        CASE c IS
                            WHEN "000" => ctrl_ar_out <= '1';
                            WHEN "001" => ctrl_br_out <= '1';
                            WHEN "010" => ctrl_cr_out <= '1';
                            WHEN "011" => ctrl_dr_out <= '1';
                            WHEN "100" => ctrl_er_out <= '1';
                            WHEN "101" => ctrl_hr_out <= '1';
                            WHEN "110" => ctrl_lr_out <= '1';
                            WHEN OTHERS =>
                        END CASE;

                        next_state <= S_FETCH_1;
                    WHEN JMP =>
                        ctrl_mar_inc <= '1';

                        next_state <= S_EXEC_5;
                    WHEN CAL =>
                        ctrl_pc_h_out <= '1';
                        ctrl_hr_in <= '1';

                        next_state <= S_EXEC_5;

                    WHEN ALU =>
                        CASE b IS
                            WHEN "000" =>
                                ctrl_ar_out <= '1';
                            WHEN "001" =>
                                ctrl_br_out <= '1';
                            WHEN "010" =>
                                ctrl_cr_out <= '1';
                            WHEN "011" =>
                                ctrl_dr_out <= '1';
                            WHEN "100" =>
                                ctrl_er_out <= '1';
                            WHEN "101" =>
                                ctrl_hr_out <= '1';
                            WHEN "110" =>
                                ctrl_lr_out <= '1';
                            WHEN OTHERS =>
                                --do nothing
                        END CASE;

                        ctrl_alu_ar_in <= '1';
                        ctrl_mar_inc <= '1';
                        ctrl_pc_inc <= '1';

                        next_state <= S_EXEC_5;

                    WHEN PUSH =>
                        ctrl_sp_dec <= '1';

                        next_state <= S_FETCH_1;
                    WHEN LOAD =>
                        ctrl_ram_out <= '1';
                        ctrl_lr_in <= '1';

                        next_state <= S_EXEC_5;
                    WHEN JCC =>
                        ctrl_mar_inc <= '1';

                        next_state <= S_EXEC_5;
                    WHEN OTHERS =>
                        --do nothing
                END CASE;
            WHEN S_EXEC_5 =>
                CASE current_instr IS
                    WHEN JMP =>
                        --wait for RAM

                        next_state <= S_EXEC_6;
                    WHEN CAL =>
                        ctrl_pc_h_in <= '1';
                        ctrl_ram_out <= '1';
                        next_state <= S_EXEC_6;
                    WHEN ALU =>
                        CASE c IS
                            WHEN "000" =>
                                ctrl_ar_out <= '1';
                            WHEN "001" =>
                                ctrl_br_out <= '1';
                            WHEN "010" =>
                                ctrl_cr_out <= '1';
                            WHEN "011" =>
                                ctrl_dr_out <= '1';
                            WHEN "100" =>
                                ctrl_er_out <= '1';
                            WHEN "101" =>
                                ctrl_hr_out <= '1';
                            WHEN "110" =>
                                ctrl_lr_out <= '1';
                            WHEN OTHERS =>
                                --do nothing
                        END CASE;

                        ctrl_alu_br_in <= '1';

                        next_state <= S_EXEC_6;
                    WHEN LOAD =>
                        ctrl_hr_out <= '1';
                        ctrl_mar_h_in <= '1';

                        next_state <= S_EXEC_6;
                    WHEN JCC =>
                        --wait for RAM

                        next_state <= S_EXEC_6;
                    WHEN OTHERS =>

                END CASE;
            WHEN S_EXEC_6 =>
                CASE current_instr IS
                    WHEN JMP =>
                        ctrl_ram_out <= '1';
                        ctrl_pc_l_in <= '1';

                        next_state <= S_FETCH_1;
                    WHEN CAL =>
                        ctrl_mar_inc <= '1';

                        next_state <= S_EXEC_7;
                    WHEN ALU =>
                        ctrl_ram_out <= '1';
                        ctrl_cur_in <= '1';

                        next_state <= S_EXEC_7;
                    WHEN LOAD =>
                        ctrl_lr_out <= '1';
                        ctrl_mar_l_in <= '1';

                        next_state <= S_EXEC_7;
                    WHEN JCC =>
                        ctrl_ram_out <= '1';
                        ctrl_pc_l_in <= '1';

                        next_state <= S_FETCH_1;
                    WHEN OTHERS =>

                END CASE;
            WHEN S_EXEC_7 =>
                CASE current_instr IS
                    WHEN ALU =>
                        ctrl_alu_out <= '1';

                        CASE c IS
                            WHEN "000" =>
                                ctrl_ar_in <= '1';
                            WHEN "001" =>
                                ctrl_br_in <= '1';
                            WHEN "010" =>
                                ctrl_cr_in <= '1';
                            WHEN "011" =>
                                ctrl_dr_in <= '1';
                            WHEN "100" =>
                                ctrl_er_in <= '1';
                            WHEN "101" =>
                                ctrl_hr_in <= '1';
                            WHEN "110" =>
                                ctrl_lr_in <= '1';
                            WHEN OTHERS =>
                                --do nothing
                        END CASE;

                        next_state <= S_FETCH_1;
                    WHEN CAL =>

                        next_state <= S_EXEC_8;
                    WHEN LOAD =>
                        ctrl_ram_out <= '1';

                        CASE y IS
                            WHEN "000" =>
                                ctrl_ar_in <= '1';
                            WHEN "001" =>
                                ctrl_br_in <= '1';
                            WHEN "010" =>
                                ctrl_cr_in <= '1';
                            WHEN "011" =>
                                ctrl_dr_in <= '1';
                            WHEN "100" =>
                                ctrl_er_in <= '1';
                            WHEN "101" =>
                                ctrl_hr_in <= '1';
                            WHEN "110" =>
                                ctrl_lr_in <= '1';
                            WHEN OTHERS =>
                                --do nothing
                        END CASE;
                        next_state <= S_FETCH_1;
                    WHEN OTHERS =>
                        next_state <= S_FETCH_1;
                END CASE;
            WHEN S_EXEC_8 =>
                CASE current_instr IS
                    WHEN CAL =>
                        ctrl_pc_l_in <= '1';
                        ctrl_ram_out <= '1';

                        next_state <= S_FETCH_1;
                    WHEN OTHERS =>
                        next_state <= S_FETCH_1;
                END CASE;
            WHEN OTHERS =>
                next_state <= S_FETCH_1;
        END CASE;

    END PROCESS;
END Behavioral;