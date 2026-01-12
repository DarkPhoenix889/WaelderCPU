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
--Revision 0.11 - Added flags and registers                                                                                 |
-- Additional Comments:                                                                                                     |
-- none so far                                                                                                              |
----------------------------------------------------------------------------------------------------------------------------|
----------------------------------|-----------------------------------|


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity waelderMain is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        data_out . out std_logic_vector (7 downto 0);
     );
end waelderMain;

architecture Behavioral of waelderMain is

    -- flag declaration --
    ------------------output control flags-------------------------------|
    signal ctrl_pc_out : std_logic;      --program counter out
    signal ctrl_ir_out : std_logic;      --instruction register out
    signal ctrl_alu_out : std_logic;     --arithmetic logical unit out
    signal ctrl_ram_out : std_logic;     --random access memory out
    signal ctrl_ar_out : std_logic;      --register a out
    signal ctrl_br_out : std_logic;      --reg b out
    signal ctrl_cr_out : std_logic;      --reg c out
    signal ctrl_dr_out : std_logic;      --reg d out
    signal ctrl_er_out : std_logic;      --reg e out
    signal ctrl_lr_out : std_logic;      --reg l out
    signal ctrl_hr_out : std_logic;      --reg h out
    signal ctrl_mr_out : std_logic;      --reg m out (16bit)

    ------------------input control flags--------------------------------|
    signal ctrl_pc_in : std_logic;      --program counter in
    signal ctrl_ir_in : std_logic;      --instruction register in
    signal ctrl_mar_h_in : std_logic;    --memory address register high byte in
    signal ctrl_mar_l_in : std_logic;    --memory address register low byte in
    signal ctrl_ar_in : std_logic;      --register a in
    signal ctrl_br_in : std_logic;      --reg b in
    signal ctrl_cr_in : std_logic;      --reg c in
    signal ctrl_dr_in : std_logic;      --reg d in
    signal ctrl_er_in : std_logic;      --reg e in
    signal ctrl_lr_in : std_logic;      --reg l in
    signal ctrl_hr_in : std_logic;      --reg h in
    signal ctrl_mr_in : std_logic;      --reg m in (16bit)
    signal ctrl_ram_in : std_logic;     --ram in






    -- register deeclaration --
    ------------------instruction register-------------------------------|
    signal i_reg : std_logic_vector (7 downto 0);
    
    
    ----------------------general purpose register-----------------------|
    signal a_reg : std_logic_vector (7 downto 0);      --reg a
    signal b_reg : std_logic_vector (7 downto 0);      --reg b
    signal c_reg : std_logic_vector (7 downto 0);      --reg c
    signal d_reg : std_logic_vector (7 downto 0);      --reg d
    signal e_reg : std_logic_vector (7 downto 0);      --reg e
    signal l_reg : std_logic_vector (7 downto 0);      --reg l
    signal h_reg : std_logic_vector (7 downto 0);      --reg h
    signal m_reg : std_logic_vector (15 downto 0);      --reg m (16bit reg - consists out of reg h(-igh) + l(-ow))
    m_reg(15 downto 8) <= h_reg;    --set highest 8bits of reg m with h reg
    m_reg(7 downto 0) <= l_reg;     --set lowest 8bits of reg m with l reg

    -----------------------------async reset-----------------------------|
    process (clk, reset)
        begin
            if reset = '1' then
                -- asynchronous reset - set all flags, registers, etc. to default value (commonly all 0)
            end if;
    end process;

    ------------------------------data bus-------------------------------|
    signal bus : std_logic_vector (7 downto 0);
    bus <= pc when ctrl_pc_out = '1' else
        ir when ctrl_ir_out = '1' else
        a_reg when ctrl_ar_out = '1' else
        b_reg when ctrl_br_out = '1' else
        c_reg when ctrl_cr_out = '1' else
        d_reg when ctrl_dr_out = '1' else
        e_reg when ctrl_er_out = '1' else
        h_reg when ctrl_hr_out = '1' else
        l_reg when ctrl_lr_out = '1' else
        m_reg when ctrl_mr_out = '1' else
        alu when ctrl_alu_out = '1' else
        mem(mar) when ctrl_ram_out = '1' else
        (others => '0');
    
    
    


    ---------------------------------ALU----------------------------------|
    --alu in- and outputs
    signal alu_reg_a :std_logic_vector (7 downto 0);    --alu reg 1
    signal alu_reg_b :std_logic_vector (7 downto 0);    --alu reg 1
    signal alu_in_a : signed (7 downto 0);  --alu input reg 1 signed value
    signal alu_in_b : signed (7 downto 0);  --alu input reg 2 signed value
    alu_in_a <= signed(alu_reg_a);
    alu_in_b <= signed(alu_reg_b);

    signal alu_result : std_logic_vector (8 downto 0);  --alu output - dependant what operation is being made

    --alu flags (f_ for flag)
    signal f_overflow : std_logic;    --overflow - if number is bigger than 127
    signal f_zero : std_logic;    --zero flag - if alu is 0
    signal f_parity : std_logic;  --parity flag - if alu has even parity
    signal f_sign : std_logic;  --sign flag - if value is negative
    signal f_comp : std_logic; --compare flag for ifs



    --alu ctrl bits
    signal ctrl_alu : std_logic_vector (2 downto 0);    --alu control register - gets filled by CU with OP-Code

    process(alu_reg_a, alu_reg_b, alu_in_a, alu_in_b, ctrl_alu)
    begin
    variable tmp_result : signed (8 downto 0); --temporary variable neccessary for flags because variables get processed before signals (sopurce: https://coolt.ch/notizen/variable-signale-in-vhdl/#:~:text=–%20Sie%20müssen%20im%20Prozess%2C%20vor%20dem,token_note:%20std_logic_vector(7%20downto%200)%20:=(OTHERS%20=>%20%270%27);)

    case alu_ctrl is
        when "000" =>   --ADD
        tmp_result := resize(alu_in_a, 9) + resize(alu_in_b, 9);
        
        when "001" =>   --SUBTRACT
        tmp_result := resize(alu_in_a, 9) - resize(alu_in_b, 9);
        
        when "010" => --AND
        tmp_result := signed('0' & (alu_reg_a and alu_reg_b));

        when "011" => --OR
        tmp_result := signed('0' & (alu_reg_a or alu_reg_b));
        
        when "100" => --NOT (just reg a)
        tmp_result := signed('0' & (not alu_reg_a));

        when "101" => --XOR
        tmp_result := signed('0' & (alu_reg_a xor alu_reg_b));

        when "110" => --COMPARE
        if (alu_reg_a = alu_reg_b) then
            f_comp <= '1';
        else
            f_comp <= '0';
        end if;
        tmp_result := "000000000";

        when "111" =>
        --undefined - set everything 0
        tmp_result := "000000000";
            
        end case;

        alu_result <= std_logic_vector(tmp_result);

    --flag logic
    if tmp_result = 0 then
        f_zero <= '1';  --zero flag if result is equal to 0
    else
        f_zero <= '0';
    end if;

     -- Overflow - only needed for ADD and SUBTRACT
     f_overflow <= '0'; --reset overflow
    if (alu_ctrl = "000" or alu_ctrl = "001") then  --overflow condition = if a and b have the same signage but the output has another then it is overflow
        if (alu_in_a(7) = alu_in_b(7)) and (tmp_result(7) /= alu_in_a(7)) then
            f_overflow <= '1';
        end if;
    end if;

    f_sign <= tmp_result(7);    --MSB says if value is negative - sign flag has to be MSB

    f_parity <= tmp_result(0);  --parity is odd if LSB equals '1'

    end process;

    



        --program counter
    


        --arithmetic logical unit


        --control unit
    -----------------------instruction decoding---------------------------|
    -- Type definition for all supported instructions
    type instr_t is (
        NOP, RST, INR, DCR, CAL, RET, CCC, RCC, JMP, JCC, 
        PUSH, LOAD, ALU, RLC, RRC, LDR, INP, OUT, MOV
    );
    
    signal current_instr : instr_t; -- Holds the currently decoded instruction

    -- Opcode field aliases for readability
    signal x : std_logic_vector(1 downto 0); -- type indicator
    signal y : std_logic_vector(2 downto 0); -- variable / register
    signal z : std_logic_vector(2 downto 0); -- secondary indicator

    ---------------------------------------------------------------------|
    -- Instruction Decoder
    ---------------------------------------------------------------------|
    process(x, y, z)
    begin
        -- Default value to ensure clean synthesis
        instr <= NOP;

        case x is
            --------------------------------------------------------------
            -- Type 00: No Variables
            --------------------------------------------------------------
            when "00" =>
                case z is
                    when "000" =>
                        if y = "000" then instr <= NOP;
                        elsif y = "001" then instr <= INP;
                        end if;
                    when "001" =>
                        if y = "001" then instr <= OUT;
                        else instr <= RST;
                        end if;
                    when "010"  => instr <= JMP;
                    when "100"  => instr <= CAL;
                    when "101"  => instr <= RET;
                end case;

            --------------------------------------------------------------
            -- Type 01: Ops with Vars
            --------------------------------------------------------------
            when "01" =>
                case z is
                    when "000"  => instr <= INR;
                    when "001"  => instr <= DCR;
                    when "010"  => instr <= RLC;
                    when "011"  => instr <= RRC;
                    when "100"  => instr <= LDR;
                    when "101"  => instr <= PUSH;
                    when "110"  => instr <= LOAD;
                end case;

            --------------------------------------------------------------
            -- Type 10: Move OP 
            --------------------------------------------------------------
            when "10" =>
                instr <= MOV;

            --------------------------------------------------------------
            -- Type 11: Conditionals + ALU 
            --------------------------------------------------------------
            when "11" =>
                case z is
                    when "000" | "001" => instr <= ALU;
                    when "100"         => instr <= CCC;
                    when "101"         => instr <= RCC;
                    when "110"         => instr <= JCC;
                    when others        => instr <= ALU;
                end case;

            when others =>
                instr <= NOP;
        end case;
    end process;

begin


end Behavioral;
