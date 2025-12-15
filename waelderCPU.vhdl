----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2025 14:28:40
-- Design Name: 
-- Module Name: waelderMain - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity waelderMain is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        data_out . out std_logic_vector (7 downto 0);
     );
end waelderMain;

architecture Behavioral of waelderMain is
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
    
begin


end Behavioral;
