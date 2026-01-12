--for ALU testing purposes only
--In order to test the ALU and only the ALU, the alu_reg_a and b, alu_result and 
--ctrl_alu have to be declared as ports as followed and the signals have to be removed (commented):
--for alu testing purposes only--
--alu_reg_a : in std_logic_vector (7 downto 0);    --alu reg 1
--alu_reg_b : in std_logic_vector (7 downto 0);    --alu reg 2
--alu_result : out std_logic_vector (7 downto 0);  --alu output - dependant what operation is being made
--ctrl_alu : in std_logic_vector (2 downto 0)    --alu control register - gets filled by CU with OP-Code
--

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
            data_out : out std_logic_vector (7 downto 0);
            
            alu_reg_a : in std_logic_vector (7 downto 0);    --alu reg 1
            alu_reg_b : in std_logic_vector (7 downto 0);    --alu reg 2
            alu_result : out std_logic_vector (7 downto 0);  --alu output - dependant what operation is being made
            ctrl_alu : in std_logic_vector (2 downto 0)    --alu control register - gets filled by CU with OP-Code
        );
    end component;

    -- Signal declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector (7 downto 0) := (others => '0');
    
    signal alu_reg_a : std_logic_vector(7 downto 0) := "00000000";
    signal alu_reg_b : std_logic_vector(7 downto 0) := "00000000";
    signal alu_result : std_logic_vector (7 downto 0) := "00000000";
    signal ctrl_alu : std_logic_vector (2 downto 0) := "000";

begin

    --Clock generation
    clk <= not clk after 10 ns;

    -- Instantiate Unit Under Test (UUT)
    uut: waelderMain
        port map (
            clk => clk,
            reset => reset,
            data_in => data_in,
            data_out => data_out,
            
            alu_reg_a => alu_reg_a,
            alu_reg_b => alu_reg_b,
            alu_result => alu_result,
            ctrl_alu => ctrl_alu
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialization
        wait for 10 ns;
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        
        
        --ADD test
        ctrl_alu <= "000";
        alu_reg_a <= "01000101";
        alu_reg_b <= "00000001";
        wait for 20 ns;
        --SUB test
        ctrl_alu <= "001";
        wait for 20 ns;
        --AND test
        ctrl_alu <= "010";
        wait for 20 ns;
        --OR test
        ctrl_alu <= "011";
        wait for 20 ns;
        --NOT test
        ctrl_alu <= "100";
        wait for 20 ns;
        --XOR test
        ctrl_alu <= "101";
        wait for 20 ns;
        --ADD test with overflow
        ctrl_alu <= "000";
        alu_reg_b <= "01111111";
        wait for 20 ns;
        --SUB test overflow
        alu_reg_a <= "10000101";
        ctrl_alu <= "001";

        wait;
    end process;

end Behavioral;
