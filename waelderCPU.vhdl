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
        data_out : out std_logic_vector (7 downto 0)
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
    --signal ctrl_mr_out : std_logic;      --reg m out (16bit) not needed because m-reg is not a real register, just register l+h

    -------------------input control flags-------------------------------|
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
    

    --------------------------bus declaration----------------------------|
    signal data_bus : std_logic_vector (7 downto 0);


    -- alu declaration --
    -----------------------alu in- and outputs---------------------------|
    signal alu_reg_a :std_logic_vector (7 downto 0);    --alu reg 1
    signal alu_reg_b :std_logic_vector (7 downto 0);    --alu reg 2
    signal alu_in_a : signed (7 downto 0);  --alu input reg 1 signed value
    signal alu_in_b : signed (7 downto 0);  --alu input reg 2 signed value
    
    signal alu_result : std_logic_vector (7 downto 0);  --alu output - dependant what operation is being made
    
    --alu flags (f_ for flag)
    signal f_overflow : std_logic;    --overflow - if number is bigger than 127
    signal f_zero : std_logic;    --zero flag - if alu is 0
    signal f_parity : std_logic;  --parity flag - if alu has even parity
    signal f_sign : std_logic;  --sign flag - if value is negative
    signal f_comp : std_logic; --compare flag for ifs

    --alu ctrl bits
    signal ctrl_alu : std_logic_vector (2 downto 0);    --alu control register - gets filled by CU with OP-Code

    --temporary declarations that will be modified in the future
    signal pc, ir : std_logic_vector (7 downto 0);

    begin
    -- m-register --
    m_reg <= h_reg & l_reg; -- m_reg is no real register just a wiring of both - h and l registers
    
    
    alu_in_a <= signed(alu_reg_a);
    alu_in_b <= signed(alu_reg_b);

    -----------------------------async reset-----------------------------|
    process (reset)
        begin
            if reset = '1' then
                -- asynchronous reset - set all flags, registers, etc. to default value (commonly all 0)
            end if;
    end process;


    ------------------------------data bus-------------------------------|
    process (ctrl_pc_out, ctrl_ir_out, ctrl_ar_out, ctrl_br_out, ctrl_cr_out, ctrl_dr_out, ctrl_er_out, 
             ctrl_lr_out, ctrl_hr_out, ctrl_alu_out)
    begin
        if ctrl_pc_out = '1' then
            data_bus <= pc;
        elsif ctrl_ir_out = '1' then
            data_bus <= ir;
        elsif ctrl_ar_out = '1' then
            data_bus <= a_reg;
        elsif ctrl_br_out = '1' then
            data_bus <= b_reg;
        elsif ctrl_cr_out = '1' then
            data_bus <= c_reg;
        elsif ctrl_dr_out = '1' then
            data_bus <= d_reg;
        elsif ctrl_er_out = '1' then
            data_bus <= e_reg;
        elsif ctrl_hr_out = '1' then
            data_bus <= h_reg;
        elsif ctrl_lr_out = '1' then
            data_bus <= l_reg;
        elsif ctrl_alu_out = '1' then
            data_bus <= alu_result;
        else
        --mem(mar) when ctrl_ram_out = '1' else memory is implemented later on
        data_bus <= (others => '0');
        end if;
    end process;    

    ---------------------------------ALU----------------------------------|
    process(alu_reg_a, alu_reg_b, alu_in_a, alu_in_b, ctrl_alu)
        variable tmp_res : signed (8 downto 0);
    begin
    case ctrl_alu is
        when "000" =>   --ADD
        tmp_res := resize(alu_in_a, 9) + resize(alu_in_b, 9);
        
        when "001" =>   --SUBTRACT
        tmp_res := resize(alu_in_a, 9) - resize(alu_in_b, 9);
        
        when "010" => --AND
        tmp_res := signed('0' & (alu_reg_a and alu_reg_b));

        when "011" => --OR
        tmp_res := signed('0' & (alu_reg_a or alu_reg_b));
        
        when "100" => --NOT (just reg a)
        tmp_res := signed('0' & (not alu_reg_a));

        when "101" => --XOR
        tmp_res := signed('0' & (alu_reg_a xor alu_reg_b));

        when "110" => --COMPARE
        if (alu_reg_a = alu_reg_b) then
            f_comp <= '1';
        else
            f_comp <= '0';
        end if;
        tmp_res := "000000000";

        when "111" =>
        --undefined - set everything 0
        tmp_res := "000000000";
            
        end case;

        alu_result <= std_logic_vector(tmp_res(7 downto 0));

    --flag logic
    if tmp_res = 0 then
        f_zero <= '1';  --zero flag if result is equal to 0
    else
        f_zero <= '0';
    end if;

    -- Overflow - only needed for ADD and SUBTRACT
    f_overflow <= tmp_res(7);
    
    f_sign <= tmp_res(8);

    f_parity <= tmp_res(0);  --parity is odd if LSB equals '1'

    end process;

    
        --penis


        --program counter
    


        --arithmetic logical unit




        --control unit



end Behavioral;
