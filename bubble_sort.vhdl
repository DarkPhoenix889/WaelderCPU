    -- Register-Belegung:
    --   A  = aktuelles Element arr[i]
    --   B  = nächstes Element  arr[i+1]
    --   C  = swap-flag (0 = kein Swap passiert)
    --   D  = äußerer Schleifenzähler (n-1 Durchläufe)
    --   E  = innerer Index i
    --   H  = temporär für Adress-High-Byte (immer 0x01)
    --   L  = temporär für Adress-Low-Byte
    
    0  => "01100100",  -- LDR E, 7 (Schleifenlimit n-1)
    1  => "00000111",  -- (Zusatzbyte: Wert 7)
    2  => "01010100",  -- LDR C, 0 (Swap-Flag auf 0)
    3  => "00000000",  -- (Zusatzbyte: Wert 0)
    4  => "01011100",  -- LDR D, 0 (Innerer Schleifenzähler)
    5  => "00000000",  -- (Zusatzbyte: Wert 0)
    6  => "01110100",  -- LDR L, 0 (Array-Index)
    7  => "00000000",  -- (Zusatzbyte: Wert 0)

    -- --- INNER LOOP START ---
    8  => "11110000",  -- ALU COMP, D, E, 111 (Vergleich D mit E)
    9  => "00011100",  -- (Zubyte 1: Quell-D="011", E="100")
    10 => "00000111",  -- (Zubyte 2: Ziel="111" -> kein Schreiben)
    11 => "11000110",  -- JCC Z, 53 (Wenn D == E, zu INNER END)
    12 => "00000000",  -- (Zubyte: High-Byte Ziel 53)
    13 => "00110101",  -- (Zubyte: Low-Byte Ziel 53)

    -- --- SELF-MODIFYING CODE (SMC) BLOCK ---
    14 => "10000110",  -- MOV A, L        (copy index into A — safe register)
    15 => "01000010",  -- STORE A, 30     (patch LOAD A low byte)
    16 => "00000000",
    17 => "00011110",
    18 => "01000010",  -- STORE A, 42     (patch STORE B low byte)
    19 => "00000000",
    20 => "00101010",

    21 => "01000000",  -- INR A           (A = L+1)
    22 => "01000010",  -- STORE A, 33     (patch LOAD B low byte)
    23 => "00000000",
    24 => "00100001",
    25 => "01000010",  -- STORE A, 45     (patch STORE A low byte)
    26 => "00000000",
    27 => "00101101",

    -- --- DATA LOADING (Low-Bytes werden durch SMC ersetzt) ---
    28 => "01000110",  -- LOAD A, 0x0100 (Lädt arr[i], Basis High = 0x01)
    29 => "00000001",  -- (Zubyte: High-Byte RAM-Adresse)
    30 => "00000000",  -- (Zubyte: Low-Byte RAM-Adresse -> wird zu L)
    31 => "01001110",  -- LOAD B, 0x0100 (Lädt arr[i+1], Basis High = 0x01)
    32 => "00000001",  -- (Zubyte: High-Byte RAM-Adresse)
    33 => "00000001",  -- (Zubyte: Low-Byte RAM-Adresse -> wird zu L+1)

    -- --- ARITHMETIC VERGLEICH (arr[i] > arr[i+1]) ---
    34 => "11001000",  -- ALU SUB, B, A, 111 (Berechne B - A für Flags)
    35 => "00001000",  -- (Zubyte 1: Quell-B="001", A="000")
    36 => "00000111",  -- (Zubyte 2: Ziel="111")
    37 => "11111110",  -- JCC NS, 48 (Wenn B >= A, zu NO_SWAP)
    38 => "00000000",  -- (Zubyte: High-Byte Ziel 48)
    39 => "00110000",  -- (Zubyte: Low-Byte Ziel 48)

    -- --- SWAP BLOCK (Low-Bytes werden durch SMC ersetzt) ---
    40 => "01001010",  -- STORE B, 0x0100 (Speichert B in arr[i])
    41 => "00000001",  -- (Zubyte: High-Byte RAM-Adresse)
    42 => "00000000",  -- (Zubyte: Low-Byte RAM-Adresse -> wird zu L)
    43 => "01000010",  -- STORE A, 0x0100 (Speichert A in arr[i+1])
    44 => "00000001",  -- (Zubyte: High-Byte RAM-Adresse)
    45 => "00000000",  -- (Zubyte: Low-Byte RAM-Adresse -> wird zu L+1)
    46 => "01010100",  -- LDR C, 1 (Tausch fand statt -> Swap-Flag C = 1)
    47 => "00000001",  -- (Zubyte: Wert 1)

    -- --- NO SWAP / ITERATION ---
    48 => "01011000",  -- INR D (Schleifenzähler + 1)
    49 => "01110000",  -- INR L (Array-Index + 1)
    50 => "00000010",  -- JMP 8 (Zurück zu INNER LOOP START)
    51 => "00000000",  -- (Zubyte: High-Byte Ziel 8)
    52 => "00001000",  -- (Zubyte: Low-Byte Ziel 8)

    -- --- END INNER LOOP / CHECK SWAP FLAG ---
    53 => "01000100",  -- LDR A, 0 (Konstante 0 für Flag-Check)
    54 => "00000000",  -- (Zubyte: Wert 0)
    55 => "11110000",  -- ALU COMP, C, A, 111 (Prüfe, ob C == 0)
    56 => "00010000",  -- (Zubyte 1: Quell-C="010", A="000")
    57 => "00000111",  -- (Zubyte 2: Ziel="111")
    58 => "11000110",  -- JCC Z, 64 (Wenn C == 0, zu DONE)
    59 => "00000000",  -- (Zubyte: High-Byte Ziel 64)
    60 => "01000000",  -- (Zubyte: Low-Byte Ziel 64)
    61 => "00000010",  -- JMP 2 (Wenn C != 0, zu OUTER LOOP START)
    62 => "00000000",  -- (Zubyte: High-Byte Ziel 2)
    63 => "00000010",  -- (Zubyte: Low-Byte Ziel 2)

    -- --- DONE: ENDLOSSCHLEIFE FÜR DIE AUSGABE AN DEN LEDS ---
    64 => "01110100",  -- LDR L, 0 (Ausgabe-Index zurücksetzen)
    65 => "00000000",  -- (Zubyte: Wert 0)
    66 => "10000110",  -- MOV A, L
    67 => "01000010",  -- STORE A, 71
    68 => "00000000",
    69 => "01000111",
    70 => "01000110",  -- LOAD A, 0x0100 (Lade aktuellen sortierten Wert nach A)
    71 => "00000001",  -- (Zubyte: High-Byte RAM-Adresse)
    72 => "00000000",  -- (Zubyte: Low-Byte RAM-Adresse -> wird durch SMC zu L)
    73 => "00001001",  -- OUT A (Gib Wert an IO_OUT / LEDs aus)
    74 => "00000000",  -- (Zubyte: Quellregister A = "000")
    75 => "11110000",  -- ALU COMP, L, E, 111 (Prüfe, ob der gedruckte Index L == E ist, also 7)
    76 => "00110100",  -- (Zubyte 1: Quell-L="110", E="100") 
    77 => "00000111",  -- (Zubyte 2: Ziel="111") 
    78 => "11000110",  -- JCC Z, 64 (Wenn L == 7, wurde arr[7] erfolgreich ausgegeben -> Reset bei 64)
    79 => "00000000",  -- (Zubyte: High-Byte Ziel 64)
    80 => "01000000",  -- (Zubyte: Low-Byte Ziel 64)
    81 => "01110000",  -- INR L (Nächsten Index vorbereiten)
    82 => "00000010",  -- JMP 66 (Sonst Schleife fortsetzen ab Pos 66) 
    83 => "00000000",  -- (Zubyte: High-Byte Ziel 66)
    84 => "01000010",   -- (Zubyte: Low-Byte Ziel 66)


    -- DATEN  (ab Addr 256 = 0x100)
    256 => "11111111", 
    257 => "00011111", 
    258 => "00000111",
    259 => "00111111",
    260 => "01111111",
    261 => "00000011", 
    262 => "00001111", 
    263 => "00000001",
    OTHERS => (OTHERS => '0')




    -- Register-Belegung:
--   A  = aktuelles Element arr[i]
--   B  = nächstes Element  arr[i+1]
--   C  = swap-flag (0 = kein Swap passiert)
--   D  = innerer Schleifenzähler
--   E  = Schleifenlimit (n-1 = 7, wird pro Durchlauf dekrementiert)
--   L  = Array-Index (muss pro äußerem Durchlauf auf 0 zurückgesetzt werden)

-- === INIT (nur einmal beim Start) ===
0  => "01100100",  -- LDR E, 7
1  => "00000111",

-- === OUTER LOOP START (Sprungziel: Addr 2) ===
2  => "01010100",  -- LDR C, 0  (Swap-Flag reset)
3  => "00000000",
4  => "01011100",  -- LDR D, 0  (innerer Zähler reset)
5  => "00000000",
6  => "01110100",  -- LDR L, 0  (*** FIX: Array-Index reset ***)
7  => "00000000",

-- === INNER LOOP START ===
8  => "11110000",  -- ALU COMP D, E -> kein Schreiben
9  => "00011100",  -- Quell: D="011", E="100"
10 => "00000111",  -- Ziel="111" (kein Schreiben)
11 => "11000110",  -- JCC Z, 53  (D==E -> inner loop end)
12 => "00000000",
13 => "00110101",

-- === SMC BLOCK ===
14 => "10000110",  -- MOV A, L
15 => "01000010",  -- STORE A, [30]  (patch LOAD A addr low)
16 => "00000000",
17 => "00011110",
18 => "01000010",  -- STORE A, [42]  (patch STORE B addr low)
19 => "00000000",
20 => "00101010",
21 => "01000000",  -- INR A  (A = L+1)
22 => "01000010",  -- STORE A, [33]  (patch LOAD B addr low)
23 => "00000000",
24 => "00100001",
25 => "01000010",  -- STORE A, [45]  (patch STORE A addr low)
26 => "00000000",
27 => "00101101",

-- === DATA LOAD (low-bytes patched by SMC) ===
28 => "01000110",  -- LOAD A, 0x01_LL  (arr[i])
29 => "00000001",
30 => "00000000",  -- low byte <- patched to L
31 => "01001110",  -- LOAD B, 0x01_LL  (arr[i+1])
32 => "00000001",
33 => "00000001",  -- low byte <- patched to L+1

-- === COMPARE arr[i] > arr[i+1] ===
34 => "11001000",  -- ALU SUB B, A -> flags only
35 => "00001000",  -- Quell: B="001", A="000"
36 => "00000111",  -- Ziel="111" (kein Schreiben)
37 => "11111110",  -- JCC NS, 48  (B >= A -> no swap)
38 => "00000000",
39 => "00110000",

-- === SWAP BLOCK (low-bytes patched by SMC) ===
40 => "01001010",  -- STORE B, 0x01_LL  (B -> arr[i])
41 => "00000001",
42 => "00000000",  -- low byte <- patched to L
43 => "01000010",  -- STORE A, 0x01_LL  (A -> arr[i+1])
44 => "00000001",
45 => "00000000",  -- low byte <- patched to L+1
46 => "01010100",  -- LDR C, 1  (swap happened)
47 => "00000001",

-- === NO SWAP / NEXT ITERATION ===
48 => "01011000",  -- INR D
49 => "01110000",  -- INR L
50 => "00000010",  -- JMP 8
51 => "00000000",
52 => "00001000",

-- === INNER LOOP END / CHECK SWAP FLAG ===
53 => "01000100",  -- LDR A, 0  (Konstante 0)
54 => "00000000",
55 => "11110000",  -- ALU COMP C, A
56 => "00010000",  -- Quell: C="010", A="000"
57 => "00000111",  -- Ziel="111"
58 => "11000110",  -- JCC Z, 68  (C==0 -> DONE)
59 => "00000000",
60 => "01000100",  -- *** FIX: jump to DONE at 68 ***
61 => "00000010",  -- JMP 2  (C!=0 -> next outer pass)
62 => "00000000",
63 => "00000010",

-- === DONE: LED output loop ===
64 => "01110100",  -- LDR L, 0
65 => "00000000",
66 => "10000110",  -- MOV A, L
67 => "01000010",  -- STORE A, 71  (SMC: patch LOAD addr)
68 => "00000000",
69 => "01000111",
70 => "01000110",  -- LOAD A, 0x01_LL
71 => "00000001",
72 => "00000000",  -- low byte <- patched
73 => "00001001",  -- OUT A
74 => "00000000",
75 => "11110000",  -- ALU COMP L, E
76 => "00110100",  -- Quell: L="110", E="100"
77 => "00000111",  -- Ziel="111"
78 => "11000110",  -- JCC Z, 64  (L==7 -> restart output)
79 => "00000000",
80 => "01000000",
81 => "01110000",  -- INR L
82 => "00000010",  -- JMP 66
83 => "00000000",
84 => "01000010",

-- === DATA (ab Addr 256 = 0x0100) ===
256 => "11111111",
257 => "00011111",
258 => "00000111",
259 => "00111111",
260 => "01111111",
261 => "00000011",
262 => "00001111",
263 => "00000001",
OTHERS => (OTHERS => '0')