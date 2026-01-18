----------------------------------------------------------------------------------------------------------------------------|
-- Company: HTBLUVA Rankweil (school)                                                                                       |
-- Engineers: Raphael SCHÖFFMANN & Kilian SIMMA                                                                             |
-- Create Date: 24.11.2025 14:28:40                                                                                         |
-- Design Name: waelderCPU                                                                                                  |
-- Module Name: waelderMain - Behavioral                                                                                    |
-- Project Name: waelderCPU                                                                                                 |
-- Target Devices: Spartan 7                                                                                                |
-- Tool Versions: Vivado 2025.1, Visual Studio Code                                                                         |
-- Description:                                                                                                             |
-- This is part of the Diploma-Thesis "WälderCPU" by SCHÖFFMANN Raphael and SIMMA Kilian - designing an 8-Bit CPU in VHDL   |
-- Revision:                                                                                                                |
-- Revision 0.01 - File Created                                                                                             |
-- Revision 0.1 - Declared Bus                                                                                              |
-- Revision 0.11 - Added flags and registers  
-- Revision 0.2 - Added Alu
-- Revision 0.3 - Added CU (almost finished)
-- Revision 0.31 - PC and reg_in                                                                            |
-- Additional Comments:                                                                                                     |
-- none so far                                                                                                              |
----------------------------------------------------------------------------------------------------------------------------|
----------------------------------|-----------------------------------|


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity waelderMain is
    Port (
        clk : in std_logic;
        reset : in std_logic
----------------------------------------|
----------declare in/output ports WIP---|
----------------------------------------|

        --for alu testing purposes only--
        --alu_reg_a : in std_logic_vector (7 downto 0);    --alu reg 1
        --alu_reg_b : in std_logic_vector (7 downto 0);    --alu reg 2
        --alu_result : out std_logic_vector (7 downto 0);  --alu output - dependant what operation is being made
        --ctrl_alu : in std_logic_vector (2 downto 0)    --alu control register - gets filled by CU with OP-Code
     );
end waelderMain;

architecture Behavioral of waelderMain is

    -- flag declaration --
    ------------------output control flags-------------------------------|
    signal ctrl_pc_l_out : std_logic;   --pc l(ower) 8 bits out
    signal ctrl_pc_h_out : std_logic;   --pc h(igher) 8 bits out    
    signal ctrl_ir_out : std_logic;     --instruction register out
    signal ctrl_alu_out : std_logic;    --arithmetic logical unit out
    signal ctrl_ram_out : std_logic;    --random access memory out
    signal ctrl_ar_out : std_logic;     --register a out
    signal ctrl_br_out : std_logic;     --reg b out
    signal ctrl_cr_out : std_logic;     --reg c out
    signal ctrl_dr_out : std_logic;     --reg d out
    signal ctrl_er_out : std_logic;     --reg e out
    signal ctrl_lr_out : std_logic;     --reg l out
    signal ctrl_hr_out : std_logic;     --reg h out
    signal ctrl_mr_out : std_logic;     --reg m out (16bit)

    ------------------input control flags--------------------------------|
    signal ctrl_pc_l_in : std_logic;    --pc l(ower) 8bits in
    signal ctrl_pc_h_in : std_logic;    --pc h(igher) 8 bits in    
    signal ctrl_ir_in : std_logic;      --instruction register in
    signal ctrl_mar_h_in : std_logic;   --memory address register high byte in
    signal ctrl_mar_l_in : std_logic;   --mar low byte in
    signal ctrl_ar_in : std_logic;      --register a in
    signal ctrl_br_in : std_logic;      --reg b in
    signal ctrl_cr_in : std_logic;      --reg c in
    signal ctrl_dr_in : std_logic;      --reg d in
    signal ctrl_er_in : std_logic;      --reg e in
    signal ctrl_lr_in : std_logic;      --reg l in
    signal ctrl_hr_in : std_logic;      --reg h in
    signal ctrl_mr_in : std_logic;      --reg m in (16bit)
    signal ctrl_ram_in : std_logic;     --ram in



    -- register deeclaration --
    ------------------instruction register-------------------------------|
    signal i_reg : std_logic_vector (7 downto 0); 
    
    ----------------------general purpose register-----------------------|
    signal a_reg : std_logic_vector (7 downto 0);      --reg a
    signal b_reg : std_logic_vector (7 downto 0);      --reg b
    signal c_reg : std_logic_vector (7 downto 0);      --reg c
    signal d_reg : std_logic_vector (7 downto 0);      --reg d
    signal e_reg : std_logic_vector (7 downto 0);      --reg e
    signal l_reg : std_logic_vector (7 downto 0);      --reg l
    signal h_reg : std_logic_vector (7 downto 0);      --reg h
    signal m_reg : std_logic_vector (15 downto 0);      --reg m (16bit reg - consists out of reg h(-igh) + l(-ow))
    

    --------------------------bus declaration----------------------------|
    signal data_bus : std_logic_vector (7 downto 0);



    --------------------------program counter----------------------------|
    signal pc : std_logic_vector (15 downto 0);
    signal pc_next   : std_logic_vector(15 downto 0);
    signal ctrl_pc_inc : std_logic;
    -- ctrl_pc_in & ctrl_pc_out bereits definiert

    -- pc high and low byte
    signal pc_h : std_logic_vector (7 downto 0);
    signal pc_l : std_logic_vector (7 downto 0);
    signal pc_load_h : std_logic;
    signal pc_load_l : std_logic;


    -- alu declaration --
    -----------------------alu in- and outputs---------------------------|
    signal alu_reg_a :std_logic_vector (7 downto 0);    --alu reg 1
    signal alu_reg_b :std_logic_vector (7 downto 0);    --alu reg 2
    signal alu_in_a : signed (7 downto 0);  --alu input reg 1 signed value
    signal alu_in_b : signed (7 downto 0);  --alu input reg 2 signed value
    
    signal alu_result : std_logic_vector (7 downto 0);  --alu output - dependant what operation is being made
    
    --alu flags (f_ for flag)
    signal f_overflow : std_logic;    --overflow - if number is bigger than 127
    signal f_zero : std_logic;    --zero flag - if alu is 0
    signal f_parity : std_logic;  --parity flag - if alu has even parity
    signal f_sign : std_logic;  --sign flag - if value is negative
    signal f_comp : std_logic; --compare flag for ifs

    --alu ctrl bits
    signal ctrl_alu : std_logic_vector (2 downto 0);    --alu control register - gets filled by CU with OP-Code
    
    
    --instruction decoding-----------------------------------------------|
    -- Type definition for all supported instructions
    type instr_t is (
        NOP, RST, INR, DCR, CAL, RET, CCC, RCC, JMP, JCC, 
        PUSH, LOAD, ALU, RLC, RRC, LDR, INP, instr_OUT, MOV
    );
    
    signal current_instr : instr_t; -- Holds the currently decoded instruction

    -- Opcode field aliases for readability
    signal x : std_logic_vector(1 downto 0); -- type indicator
    signal y : std_logic_vector(2 downto 0); -- variable / register
    signal z : std_logic_vector(2 downto 0); -- secondary indicator
    
    begin
    -- m-register --
    m_reg <= h_reg & l_reg; -- m_reg is no real register just a wiring of both - h and l registers
    
    
    alu_in_a <= signed(alu_reg_a);
    alu_in_b <= signed(alu_reg_b);

    -----------------------------async reset-----------------------------|
    process (reset)
        begin
            if reset = '1' then
                --output control flags--|
                ctrl_pc_l_out <= '0';
                ctrl_pc_h_out <= '0';
                ctrl_ir_out <= '0';
                ctrl_alu_out <= '0';
                ctrl_ram_out <= '0';
                ctrl_ar_out <= '0';
                ctrl_br_out <= '0';
                ctrl_cr_out <= '0';
                ctrl_dr_out <= '0';
                ctrl_er_out <= '0';
                ctrl_lr_out <= '0';
                ctrl_hr_out <= '0';
                ctrl_mr_out <= '0';

                --input control flags--|
                ctrl_pc_l_in <= '0';
                ctrl_pc_h_in <= '0';
                ctrl_ir_in <= '0';
                ctrl_mar_h_in <= '0';
                ctrl_mar_l_in <= '0';
                ctrl_ar_in <= '0';
                ctrl_br_in <= '0';
                ctrl_cr_in <= '0';
                ctrl_dr_in <= '0';
                ctrl_er_in <= '0';
                ctrl_lr_in <= '0';
                ctrl_hr_in <= '0';
                ctrl_mr_in <= '0';
                ctrl_ram_in <= '0';

                --instruction register--|
                i_reg <= (others => '0');

                --general purpose register--|
                a_reg <= (others => '0');
                b_reg <= (others => '0');
                c_reg <= (others => '0');
                d_reg <= (others => '0');
                e_reg <= (others => '0');
                l_reg <= (others => '0');
                h_reg <= (others => '0');
                m_reg <= (others => '0');

                --bus declaration--|
                data_bus <= (others => '0');

                --program counter--|
                pc <= (others => '0');
                pc_next <= (others => '0');
                ctrl_pc_inc <= '0';

                pc_h <= (others => '0');
                pc_l <= (others => '0');
                pc_load_h <= '0';
                pc_load_l <= '0';

                --alu--|
                alu_reg_a <= (others => '0');
                alu_reg_b <= (others => '0');
                alu_in_a <= (others => '0');
                alu_in_b <= (others => '0');

                alu_result <= (others => '0');

                f_overflow <= '0';
                f_zero <= '0';
                f_parity <= '0';
                f_sign <= '0';
                f_comp <= '0';

                ctrl_alu <= (others => '0');


                --control unit--|
                current_instr <= NOP;

                x <= (others => '0');
                y <= (others => '0');
                z <= (others => '0');
            end if;
    end process;


    ------------------------------data bus-------------------------------|
    process (ctrl_pc_l_out,ctrl_pc_h_out, ctrl_ir_out, ctrl_ar_out, ctrl_br_out, ctrl_cr_out, ctrl_dr_out, ctrl_er_out, 
             ctrl_lr_out, ctrl_hr_out, ctrl_alu_out)
    begin
        if ctrl_pc_l_out = '1' then
            data_bus <= pc_l;
        elsif ctrl_pc_h_out = '1' then
            data_bus <= pc_h;            
        elsif ctrl_ir_out = '1' then
            data_bus <= i_reg;
        elsif ctrl_ar_out = '1' then
            data_bus <= a_reg;
        elsif ctrl_br_out = '1' then
            data_bus <= b_reg;
        elsif ctrl_cr_out = '1' then
            data_bus <= c_reg;
        elsif ctrl_dr_out = '1' then
            data_bus <= d_reg;
        elsif ctrl_er_out = '1' then
            data_bus <= e_reg;
        elsif ctrl_hr_out = '1' then
            data_bus <= h_reg;
        elsif ctrl_lr_out = '1' then
            data_bus <= l_reg;
        elsif ctrl_alu_out = '1' then
            data_bus <= alu_result;
        else
        --mem(mar) when ctrl_ram_out = '1' else memory is implemented later on
        data_bus <= (others => '0');
        end if;

        if ctrl_ir_in = '1' then
            i_reg <= data_bus;
        elsif ctrl_ar_in = '1' then
            a_reg <= data_bus;
        elsif ctrl_br_in = '1' then
            b_reg <= data_bus;
        elsif ctrl_cr_in = '1' then
            c_reg <= data_bus;
        elsif ctrl_dr_in = '1' then
            d_reg <= data_bus;
        elsif ctrl_er_in = '1' then
            e_reg <= data_bus;
        elsif ctrl_hr_in = '1' then
            h_reg <= data_bus;
        elsif ctrl_lr_in = '1' then
            l_reg <= data_bus;
        end if;
    end process;


    ---------------------------------ALU----------------------------------|
    process(alu_reg_a, alu_reg_b, alu_in_a, alu_in_b, ctrl_alu)
        variable tmp_res : signed (8 downto 0);
    begin
    case ctrl_alu is
        when "000" =>   --ADD
        tmp_res := resize(alu_in_a, 9) + resize(alu_in_b, 9);
        
        when "001" =>   --SUBTRACT
        tmp_res := resize(alu_in_a, 9) - resize(alu_in_b, 9);
        
        when "010" => --AND
        tmp_res := signed('0' & (alu_reg_a and alu_reg_b));

        when "011" => --OR
        tmp_res := signed('0' & (alu_reg_a or alu_reg_b));
        
        when "100" => --NOT (just reg a)
        tmp_res := signed('0' & (not alu_reg_a));

        when "101" => --XOR
        tmp_res := signed('0' & (alu_reg_a xor alu_reg_b));

        when "110" => --COMPARE
        if (alu_reg_a = alu_reg_b) then
            f_comp <= '1';
        else
            f_comp <= '0';
        end if;
        tmp_res := "000000000";

        when "111" =>
        --undefined - set everything 0
        tmp_res := "000000000";
        
        when others =>
        tmp_res := "000000000";
            
        end case;

        alu_result <= std_logic_vector(tmp_res(7 downto 0));

    --flag logic
    if tmp_res = 0 then
        f_zero <= '1';  --zero flag if result is equal to 0
    else
        f_zero <= '0';
    end if;

    -- Overflow - only needed for ADD and SUBTRACT
    if ctrl_alu = "000" or ctrl_alu = "001" then
        f_overflow <= tmp_res(8) xor tmp_res(7);
    end if;
    
    f_sign <= tmp_res(8);

    f_parity <= tmp_res(0);  --parity is odd if LSB equals '1'

    end process;

    


--▇▅▆▇▆▅▅█
        
    --------------------------program counter----------------------------|
    process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0'); -- set pc to 0 on reset
        elsif rising_edge(clk) then
            if ctrl_pc_l_in = '1' then
                pc(7 downto 0) <= data_bus;
            elsif ctrl_pc_h_in = '1' then
                pc(15 downto 8) <= data_bus;
            elsif ctrl_pc_inc = '1' then
                pc <= std_logic_vector(unsigned(pc) + 1);
            end if;
        end if;
    end process;

    

    --control unit
    
    ---------------------------------------------------------------------|
    -- Instruction Decoder
    ---------------------------------------------------------------------|
    process(x, y, z)
    begin
        -- Default value to ensure clean synthesis
        current_instr <= NOP;

        case x is
            --------------------------------------------------------------
            -- Type 00: No Variables
            --------------------------------------------------------------
            when "00" =>
                case z is
                    when "000" =>
                        if y = "000" then current_instr <= NOP;
                        elsif y = "001" then current_instr <= INP;
                        end if;
                    when "001" =>
                        if y = "001" then current_instr <= instr_OUT;
                        else current_instr <= RST;
                        end if;
                    when "010"  => current_instr <= JMP;
                    when "100"  => current_instr <= CAL;
                    when "101"  => current_instr <= RET;
                    when others => --current_instr stays the same
                end case;

            --------------------------------------------------------------
            -- Type 01: Ops with Vars
            --------------------------------------------------------------
            when "01" =>
                case z is
                    when "000"  => current_instr <= INR;
                    when "001"  => current_instr <= DCR;
                    when "010"  => current_instr <= RLC;
                    when "011"  => current_instr <= RRC;
                    when "100"  => current_instr <= LDR;
                    when "101"  => current_instr <= PUSH;
                    when "110"  => current_instr <= LOAD;
                    when others => --current_instr stays the same
                end case;

            --------------------------------------------------------------
            -- Type 10: Move OP 
            --------------------------------------------------------------
            when "10" =>
                current_instr <= MOV;

            --------------------------------------------------------------
            -- Type 11: Conditionals + ALU 
            --------------------------------------------------------------
            when "11" =>
                case z is
                    when "000" | "001" => current_instr <= ALU;
                    when "100"         => current_instr <= CCC;
                    when "101"         => current_instr <= RCC;
                    when "110"         => current_instr <= JCC;
                    when others        => current_instr <= ALU;
                end case;

            when others =>
                current_instr <= NOP;
        end case;
    end process;



end Behavioral;
