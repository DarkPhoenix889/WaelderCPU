----------------------------------------------------------------------------------------------------------------------------|
-- Company: HTBLUVA Rankweil (school)                                                                                       |
-- Engineers: Raphael SCHÖFFMANN & Kilian SIMMA                                                                             |
-- Create Date: 11.02.2026 13:25:08                                                                                         |
-- Design Name: waelderCPU                                                                                                  |
-- Module Name: waelderRAM - Behavioral                                                                                     |
-- Project Name: waelderCPU                                                                                                 |
-- Target Devices: Spartan 7                                                                                                |
-- Tool Versions: Vivado 2025.1, Visual Studio Code                                                                         |
-- Description:                                                                                                             |
-- This is only the RAM for the Diploma-Thesis "WälderCPU" designed only by Raphael                                         |
-- Revision:                                                                                                                |
-- Revision 0.01 - File Created                                                                                             |
-- Revision 1.0 finished RAM                                                                                                |
-- Additional Comments:                                                                                                     |
-- none so far                                                                                                              |
----------------------------------------------------------------------------------------------------------------------------|
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--use std.textio.all; --in order to fill ram from a file

ENTITY waelderRAM IS
    PORT (
        clk : IN STD_LOGIC; --clock
        we : IN STD_LOGIC; --write enable
        addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0); --address
        di : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --data in
        do : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --data out
    );
END waelderRAM;

ARCHITECTURE behavioural OF waelderRAM IS
    TYPE ram_type IS ARRAY (0 TO 65535) OF STD_LOGIC_VECTOR(7 DOWNTO 0); --set ram type to 2^16 (=65535)bit RAM out of 8Bit values

    --------------------------------------------------------------------
    --load ram from file - later on implemented
    --------------------------------------------------------------------

    SIGNAL RAM : ram_type := (
        -- 0 => "01000000", --testvalue at address 0
        -- 1 => "01000000", --testvalue at address 1
        OTHERS => (OTHERS => '0') --set everything else in ram to 0
    );

BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF we = '1' THEN
                RAM(to_integer(unsigned(addr))) <= di;
            END IF;
            do <= RAM(to_integer(unsigned(addr)));
        END IF;
    END PROCESS;
END behavioural;