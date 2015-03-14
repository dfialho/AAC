library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ALU is
    Port ( 
            -- entradas e saídas a maiúsculas
            OP          : in  STD_LOGIC_VECTOR (4 downto 0);
            A           : in  STD_LOGIC_VECTOR (15 downto 0);
            B           : in  STD_LOGIC_VECTOR (15 downto 0);
            C_OUTPUT    : out  STD_LOGIC_VECTOR (15 downto 0);

            -- ordem dos bits da flag: S O C Z
            FLAGS       : out  STD_LOGIC_VECTOR (3 downto 0)
        );             
end ALU;

architecture Behavioral of ALU is
    signal sel_A, sel_B, shifted_out    : std_logic;
    signal sel_ops                      : std_logic_vector (2 downto 0);

    signal or_op, and_op, xor_op        : std_logic_vector (15 downto 0);
    signal mux_A, mux_B                 : std_logic_vector (15 downto 0);
    signal const8, constRes             : std_logic_vector (15 downto 0);
    signal shifted, ones_zeros          : std_logic_vector (15 downto 0);
    signal fast_ops, result             : std_logic_vector (15 downto 0);
    
    signal adder                        : std_logic_vector (16 downto 0);

begin

    -- selects (choose between input and not input)
    sel_A <= OP(4) and ((not OP(3) and OP(2)) or (not OP(1) and OP(0)));
    sel_B <= OP(4) and ((not OP(2) and OP(0)) or (not OP(3) and (OP(1) and not OP(0))));

    -- muxes --
    mux_A <= not A when sel_A = '0' else A;
    mux_B <= not B when sel_B = '0' else B;

    -- adder
        -- entradas de 17 bits para ter o carry out
    with OP(2 downto 0) select
        adder <=    ('0'&A) + ('0'&B)           when    "000",
                    ('0'&A) + ('0'&B) + '1'     when    "001",
                    ('0'&A) + '1'               when    "011",
                    ('0'&A) + not ('0'&B)       when    "100",
                    ('0'&A) + not ('0'&B) +'1'  when    "101",
                    ('0'&A) - 1                 when    "110",
                    X"0000"&'0'                 when others;

    -- constantes -- A é o valor do registo C e B é a constante.
    const8      <= A(15 downto 8) & B(7 downto 0) when OP(0)='0' else B(15 downto 8) & A(7 downto 0);     
    constRes    <= B when OP(1)='0' else const8;

    -- shifts
    shifted     <= A(14 downto 0)&'0' when OP(0)='0' else A(15)&A(15 downto 1);
    shifted_out <= A(15) when OP(0)='0' else A(0);

    --  ones / zeros (confirmado que é optimizado e expande OP(0) para os 16 fios)
    ones_zeros <= X"0000" when OP(0) = '1' else X"FFFF";

    -- logic ops
    or_op   <= mux_A or mux_B;
    and_op  <= mux_A and mux_B;
    xor_op  <= A xor B when OP(0) = '0' else not (A xor B);

    -- cálculo de flags
    -- S
    FLAGS(3) <= result(15);
    -- O
    FLAGS(2) <= '0' when adder(16) = adder (15) else '1';
    -- C
    FLAGS(1) <= adder(16) when OP(3)='1' else shifted_out;
    -- Z
    FLAGS(0) <= '1' when result = X"0000" else '0';

    --  escolher o sinal de controlo para o mux de saída (não sei se isto cria lógica como quero ou se faz um mux)
    with OP select 
        sel_ops <=  "000"   when "01000", -- SHIFT
                    "000"   when "01001", -- SHIFT
                    "001"   when "01100", -- CONST
                    "001"   when "01110", -- CONST
                    "001"   when "01111", -- CONST
                    "100"   when "10000", -- ONES_ZEROS
                    "110"   when "10001", -- AND
                    "110"   when "10010", -- AND
                    "011"   when "10011", -- Mux_B
                    "110"   when "10100", -- AND
                    "010"   when "10101", -- Mux_A
                    "111"   when "10110", -- XOR
                    "101"   when "10111", -- OR
                    "110"   when "11000", -- AND
                    "111"   when "11001", -- XNOR
                    "010"   when "11010", -- Mux_A
                    "101"   when "11011", -- OR
                    "011"   when "11100", -- Mux_B
                    "101"   when "11101", -- OR
                    "101"   when "11110", -- OR
                    "100"   when "11111", -- ONES_ZEROS
                    "000"   when others;

    --  mux de saída
    with sel_ops select
        fast_ops <= shifted     when "000",
                    constRes    when "001",
                    mux_A       when "010",
                    mux_B       when "011",
                    ones_zeros  when "100",
                    or_op       when "101",
                    and_op      when "110",
                    xor_op      when "111",
                    X"0000"     when others;

    result <= adder(15 downto 0) when OP(4 downto 3) = "00" else fast_ops;
    C_OUTPUT <= result; -- o result é usado porque é necessário um sinal para calcular a FLAG Z

end Behavioral;
