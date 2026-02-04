--for PC testing purposes only
--In order to test the PC and only the PC, the ctrl_pc_inc has
--to be declared as a port as followed and the signals have to be removed (commented):
--ctrl_pc_inc : in std_logic
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity waelderPC_tb is
end waelderPC_tb;

architecture Behavioral of waelderPC_tb is

 -- Component declaration
    component waelderMain
        port (
            clk : in std_logic;
            reset : in std_logic;
            
            ctrl_pc_inc : in std_logic
            );
    end component;

    -- Signal declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    
    signal ctrl_pc_inc : std_logic := '0';

begin

    --Clock generation
    clk <= not clk after 10 ns;

    -- Instantiate Unit Under Test (UUT)
    uut: waelderMain
        port map (
            clk => clk,
            reset => reset,
            
            ctrl_pc_inc => ctrl_pc_inc
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialization
        wait for 10 ns;
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20ns;
        
        for i in 0 to 3000 loop
            ctrl_pc_inc <= '1';
            wait for 20ns;
            ctrl_pc_inc <= '0';
            wait for 20ns;
        end loop;
        
        --inc pc
        ctrl_pc_inc <= '1';
        wait for 20ns;
        ctrl_pc_inc <= '0';
        wait for 20ns;
        --inc pc
        ctrl_pc_inc <= '1';
        wait for 20ns;
        ctrl_pc_inc <= '0';
        wait for 100ns; --wait longer
        --inc pc
        ctrl_pc_inc <= '1';
        wait for 20ns;
        ctrl_pc_inc <= '0';
        wait for 20ns;
        --inc pc
        ctrl_pc_inc <= '1';
        wait for 20ns;
        ctrl_pc_inc <= '0';
        
        

        wait;
    end process;

end Behavioral;
