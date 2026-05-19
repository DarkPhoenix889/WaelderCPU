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
0 => "00000000", -- NOP
1 => "00000000", -- NOP
2 => "00000000", -- NOP
3 => "01000100", -- LDR A 
4 => "00000000", -- 0   
5 => "01001100", -- LDR B
6 => "00011111", -- irgwndwas
7 => "01000000", -- INR A
8 => "11110000", -- ALU COMP
9 => "00000001", -- A, B
10 => "00000111", -- Drop Result
11 => "11000110", -- JCC Z
12 => "00000000", -- High 0x00
13 => "00010100", -- Low 0x14 / 20
14 => "00000010", -- JMP
15 => "00000000", -- High 0x00
16 => "00000111", -- Low 0x07
17 => "00000000", -- NOP
18 => "00000000", -- NOP
19 => "00000000", -- NOP
20 => "01000100", -- LDR A
21 => "00000001", -- 
22 => "01001100", -- LDR B
23 => "00000011", -- 
24 => "01010100", -- LDR C
25 => "00000111", -- 
26 => "01011100", -- LDR D
27 => "00001111", -- 
28 => "01100100", -- LDR E
29 => "00011111", -- 
30 => "01101100", -- LDR H
31 => "00111111", -- 
32 => "01110100", -- LDR L
33 => "00011110", -- 30
34 => "00001001", -- OUT A
35 => "00000000", -- A
36 => "00001001", -- OUT B
37 => "00000001", -- B
38 => "00001001", -- OUT C
39 => "00000010", -- C
40 => "00001001", -- OUT D
41 => "00000011", -- D
42 => "00001001", -- OUT E
43 => "00000100", -- E
44 => "00001001", -- OUT H
45 => "00000101", -- H
46 => "00000010", -- JMP
47 => "00000000", -- High 0
48 => "00100010", -- Low 34
49 => "00000000", -- NOP
        OTHERS => (OTHERS => '0')
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