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
-- Register-Belegung:
--   A  = aktuelles Element arr[i]
--   B  = nächstes Element  arr[i+1]
--   C  = swap-flag (0 = kein Swap passiert)
--   D  = äußerer Schleifenzähler (n-1 Durchläufe)
--   E  = innerer Index i
--   H  = temporär für Adress-High-Byte (immer 0x01)
--   L  = temporär für Adress-Low-Byte
 
-- INIT
  0 => "01011100", -- LDR D, 6         D = n-1 = 6 (angepasst für i<=D)
  1 => "00000110", -- 0x06

-- OUTER_LOOP  (Addr 2)
  2 => "01010100", -- LDR C, 0         swap-flag = 0
  3 => "00000000",
  4 => "01100100", -- LDR E, 0         i = 0
  5 => "00000000",

-- INNER_LOOP  (Addr 6)
  6 => "01101100", -- LDR H, 1         H = 0x01
  7 => "00000001",
  8 => "10100110", -- MOV L, E         L = i
  9 => "01000110", -- LOAD A, [H:L]     A = arr[i]
 10 => "01110000", -- INR L             L = i+1
 11 => "01001110", -- LOAD B, [H:L]     B = arr[i+1]
-- Vergleich A-B. Ergebnis→B (Dst=SrcB), nur Sign-Flag gebraucht.
 12 => "11001000", -- ALU SUB          11_001_000
 13 => "00000001", -- Byte2: SrcA=A(000), SrcBDst=B(001)
-- JCC sign → NO_SWAP (Addr 34 = 0x22)
 14 => "11110110", -- JCC sign         11_110_110
 15 => "00100010", -- L = 0x22 = 34    (Little-Endian: Low-Byte zuerst!)
 16 => "00000000", -- H = 0x00         (High-Byte als zweites)

-- DO_SWAP  (Addr 17)
-- B wurde durch SUB zerstört → neu laden (L zeigt noch auf i+1)
 17 => "01000110", -- LOAD A, [H:L]     A = arr[i+1]  (L=i+1)
 18 => "01110001", -- DCR L             L = i
 19 => "01001110", -- LOAD B, [H:L]     B = arr[i]
 20 => "01000010", -- STORE A, [H:L]    RAM[i] = arr[i+1]
 21 => "01110000", -- INR L             L = i+1
 22 => "01001010", -- STORE B, [H:L]    RAM[i+1] = arr[i]
 23 => "01010100", -- LDR C, 1         swap-flag = 1
 24 => "00000001",
-- weiter mit NO_SWAP (direkt danach, Addr 25 → JMP 34)
 25 => "00000010", -- JMP              (zu NO_SWAP Addr 34 = 0x0022)
 26 => "00100010", -- L = 0x22 = 34    (Little-Endian!)
 27 => "00000000", -- H = 0x00

-- Padding
 28 => "00000000", -- NOP
 29 => "00000000", -- NOP
 30 => "00000000", -- NOP
 31 => "00000000", -- NOP
 32 => "00000000", -- NOP
 33 => "00000000", -- NOP

-- NO_SWAP  (Addr 34 = 0x22)
 34 => "01100000", -- INR E             i++  (01_100_000)

-- i < D? → ALU SUB D,A → A = D-i. Sign wenn D<i → Schleife fertig
 35 => "11001000", -- ALU SUB          (D - i)
 36 => "00011000", -- Byte2: SrcA=D(011), SrcBDst=A(000)  → 00_011_000
-- Sign=1 wenn D<i  → Schleife weiter (i<=D → kein Sign → weiter)
-- JCC !sign → INNER_LOOP (Addr 6)
 37 => "11111110", -- JCC !sign        11_111_110  (y=111=!sign)
 38 => "00000110", -- L = 0x06          (Little-Endian!)
 39 => "00000000", -- H = 0x00

-- Ende innere Schleife - swap-flag prüfen
-- ALU SUB C,B: erst B=0 laden, dann C-B prüfen (zero wenn C=0)
 40 => "01001100", -- LDR B, 0         B = 0 als Vergleichswert
 41 => "00000000",
 42 => "11001000", -- ALU SUB          C - B(=0) → Ergebnis→B, Zero wenn C=0
 43 => "00010001", -- Byte2: SrcA=C(010), SrcBDst=B(001)  → 00_010_001
-- JCC zero → DONE (Addr 60 = 0x3C)
 44 => "11000110", -- JCC zero         11_000_110
 45 => "00111100", -- L = 0x3C = 60    (Little-Endian!)
 46 => "00000000", -- H = 0x00

-- D-- und D<0 prüfen
 47 => "01011001", -- DCR D            D--  (01_011_001)
-- ALU SUB D,B (B=0 noch gesetzt) → Sign wenn D unter 0 fällt (0xFF)
 48 => "11001000", -- ALU SUB          D - 0
 49 => "00011001", -- Byte2: SrcA=D(011), SrcBDst=B(001)  → 00_011_001
-- JCC sign → DONE (Addr 60 = 0x3C)
 50 => "11110110", -- JCC sign         (Geändert von JCC zero auf JCC sign!)
 51 => "00111100", -- L = 0x3C = 60    (Little-Endian!)
 52 => "00000000", -- H = 0x00

-- JMP → OUTER_LOOP (Addr 2)
 53 => "00000010", -- JMP
 54 => "00000010", -- L = 0x02         (Little-Endian!)
 55 => "00000000", -- H = 0x00
 56 => "00000000", -- NOP
 57 => "00000000", -- NOP
 58 => "00000000", -- NOP
 59 => "00000000", -- NOP

-- DONE  (Addr 60 = 0x3C)
 60 => "01101100", -- LDR H, 1
 61 => "00000001",
 62 => "01110100", -- LDR L, 0         L = 0x00  (01_110_100)
 63 => "00000000",
 64 => "01000110", -- LOAD A, [H:L]     A = arr[0] (kleinster Wert)
 65 => "00000001", -- OUT              (00_000_001)
 66 => "00000000", -- Register A = 0x00
-- Tight loop (Endlosschleife auf Adresse 67 = 0x43)
 67 => "00000010", -- JMP → 67 (selbst)
 68 => "01000011", -- L = 0x43 = 67    (Little-Endian!)
 69 => "00000000", -- H = 0x00

-- DATEN  (ab Addr 256 = 0x100)
256 => "01000111", -- 0x47 = 71
257 => "00010010", -- 0x12 = 18
258 => "10100011", -- 0xA3 = 163
259 => "00000101", -- 0x05 = 5
260 => "01111111", -- 0x7F = 127
261 => "00110011", -- 0x33 = 51
262 => "11000001", -- 0xC1 = 193
263 => "00101011", -- 0x2B = 43
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