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
    signal ctrl_pc_out : in std_logic;      --program counter out
    signal ctrl_ir_out : in std_logic;      --instruction register out
    signal ctrl_alu_out : in std_logic;     --arithmetic logical unit out
    signal ctrl_ram_out : in std_logic;     --random access memory out
    signal ctrl_ar_out : in std_logic;      --register a out
    signal ctrl_br_out : in std_logic;      --reg b out
    signal ctrl_cr_out : in std_logic;      --reg c out
    signal ctrl_dr_out : in std_logic;      --reg d out
    signal ctrl_er_out : in std_logic;      --reg e out
    signal ctrl_lr_out : in std_logic;      --reg l out
    signal ctrl_hr_out : in std_logic;      --reg h out
    signal ctrl_mr_out : in std_logic;      --reg m out (16bit)

    -------------------input control flags-------------------------------|
    signal ctrl _ram_in : in std_logic;     --ram in




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


process (clk, reset)
    begin
        if reset = '1' then
            -- asynchronous reset - set all flags, registers, etc. to default value (commonly all 0)
        end if;
    end process;

    --bus
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
    


        --program counter
    

        --arithmetic logical unit



        --control unit
begin


end Behavioral;
