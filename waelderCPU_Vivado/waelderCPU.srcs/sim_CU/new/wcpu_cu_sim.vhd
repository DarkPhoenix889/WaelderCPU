LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY waelderCU_tb IS
-- Testbenches have no ports
END waelderCU_tb;

ARCHITECTURE sim OF waelderCU_tb IS

    -- 1. Component Declaration for the Unit Under Test (UUT)
    COMPONENT waelderMain
        PORT (
            clk     : IN  STD_LOGIC;
            reset   : IN  STD_LOGIC;
            led_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    -- 2. Signals to drive the UUT ports [cite: 20]
    SIGNAL clk     : STD_LOGIC := '0';
    SIGNAL reset   : STD_LOGIC := '0';
    SIGNAL led_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Clock period definition (e.g., 100 MHz)
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- 3. Instantiate the Unit Under Test (UUT)
    uut: waelderMain
        PORT MAP (
            clk     => clk,
            reset   => reset,
            led_out => led_out
        );

    -- 4. Clock Process: Generates a continuous square wave [cite: 20]
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- 5. Stimulus Process: Controls the Reset and simulation flow
    stim_proc: PROCESS
    BEGIN		
        -- Step A: Apply Reset
        reset <= '1';
        WAIT FOR 50 ns;	
        reset <= '0'; -- Release reset to start the FSM

        -- Step B: Wait and observe the Fetch Cycle
        -- The CU should transition: S_RESET -> S_FETCH_1 -> S_FETCH_2 -> S_FETCH_3 [cite: 211, 212, 213, 214]
        WAIT FOR 1000 ns;

        -- You can add more specific test cases here, 
        -- but for the CU, observing the 'state' signal in the waveform is key.

        WAIT; -- Suspend simulation
    END PROCESS;

END sim;