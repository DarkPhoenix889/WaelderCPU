library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity waelderRAM_tb is

end waelderRAM_tb;

architecture sim of waelderRAM_tb is
    component waelderRAM
        port(
            clk : in std_logic;
            we : in std_logic;
            addr : in std_logic_vector(15 downto 0);
            di : in std_logic_vector(7 downto 0);
            do : out std_logic_vector(7 downto 0)
        );
    end component;
    
    signal clk : std_logic := '0';
    signal we : std_logic := '0';
    signal addr : std_logic_vector(15 downto 0);
    signal di : std_logic_vector(7 downto 0);
    signal do : std_logic_vector(7 downto 0);
    
    constant clk_period : time := 10ns;
    
begin
    DUT: waelderRAM
        port map(
            clk => clk,
            we => we,
            addr => addr,
            di => di,
            do => do
        );
        
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc: process
    begin
        wait for 20ns;
        
        
        --write on address--
        addr <= X"000A";
        di <= X"42";
        we <= '1';
        wait for clk_period;
        
        we <= '0';
        di <= X"00";
        wait for clk_period;
        
        --reading value from address--
        addr <= X"000A";
        wait for clk_period;
        
        
        --writing on another address--
        addr <= X"000B";
        di <= X"FF";
        we <= '1';
        wait for clk_period;
        
        we <= '0';
        wait for clk_period;
        
        di <= X"00";
        addr <= X"000A";
        wait for clk_period;
        
        
        wait for 100ns;
        wait;
    end process;
end sim;