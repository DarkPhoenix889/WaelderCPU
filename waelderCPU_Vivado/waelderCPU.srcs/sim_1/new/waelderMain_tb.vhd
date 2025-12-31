library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity waelderMain_tb is
end waelderMain_tb;

architecture Behavioral of waelderMain_tb is

    -- Component declaration
    component waelderMain
        port (
            clk : in std_logic;
            reset : in std_logic;
            data_in : in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector (7 downto 0)
        );
    end component;

    -- Signal declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector (7 downto 0);

begin

    -- Clock generation (example)
    -- clk <= not clk after 10 ns;

    -- Instantiate Unit Under Test (UUT)
    uut: waelderMain
        port map (
            clk => clk,
            reset => reset,
            data_in => data_in,
            data_out => data_out
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialization
        wait for 10 ns;

        -- Add stimulus here

        wait;
    end process;

end Behavioral;
