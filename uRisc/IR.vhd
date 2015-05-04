library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DualPortMemory is
  Generic(
    ADDR_SIZE : positive := 16
  );
  Port(
    addr: in std_logic_vector(ADDR_SIZE - 1 downto 0);
    do  : out std_logic_vector(15 downto 0)
  );
end DualPortMemory;

architecture Behavioral of DualPortMemory is

  -- declare a type of matrix of words... the memory
  type MEM_TYPE is array (0 to (2**ADDR_SIZE)-1) of STD_LOGIC_VECTOR(15 downto 0);
  -- declare a constant with the memory initial value
	constant InitValue : MEM_TYPE := (
	0 	=> X"f04d",
	1 	=> X"f400",
	2 	=> X"c05a",
	3 	=> X"c400",
	4 	=> X"c82c",
	5 	=> X"cc00",
	6 	=> X"92b0",
	7 	=> X"9832",
	8 	=> X"a298",
	9 	=> X"aa98",
	10 	=> X"3001",
	11 	=> X"0000",
	12 	=> X"82dd",
	13 	=> X"9190",
	14 	=> X"05f8",
	15 	=> X"0000",
	16 	=> X"f04d",
	17 	=> X"f400",
	18 	=> X"bab0",
	19 	=> X"f04d",
	20 	=> X"f400",
	21 	=> X"82b0",
	22 	=> X"8180",
	23 	=> X"b0f0",
	24 	=> X"a8f0",
	25 	=> X"8ab0",
	26 	=> X"92a8",
	27 	=> X"994a",
	28 	=> X"1404",
	29 	=> X"0000",
	30 	=> X"a548",
	31 	=> X"8d50",
	32 	=> X"9560",
	33 	=> X"82f1",
	34 	=> X"82ea",
	35 	=> X"b0f0",
	36 	=> X"8180",
	37 	=> X"05f2",
	38 	=> X"0000",
	39 	=> X"b9b8",
	40 	=> X"05ea",
	41 	=> X"0000",
	42 	=> X"2fff",
	43 	=> X"0000",
	44 	=> X"82c1",
	45 	=> X"80c0",
	46 	=> X"82c2",
	47 	=> X"80c0",
	48 	=> X"82c3",
	49 	=> X"80c0",
	50 	=> X"82c4",
	51 	=> X"80c0",
	52 	=> X"82c6",
	53 	=> X"480f",
	54 	=> X"5001",
	55 	=> X"7000",
	56 	=> X"9c62",
	57 	=> X"1502",
	58 	=> X"0000",
	59 	=> X"b035",
	60 	=> X"a260",
	61 	=> X"aa28",
	62 	=> X"8988",
	63 	=> X"05f8",
	64 	=> X"0000",
	65 	=> X"ad70",
	66 	=> X"b280",
	67 	=> X"8180",
	68 	=> X"a280",
	69 	=> X"8180",
	70 	=> X"9a80",
	71 	=> X"8180",
	72 	=> X"9280",
	73 	=> X"8180",
	74 	=> X"8a80",
	75 	=> X"3807",
	76 	=> X"0000",
	others => X"0000");
  -- value for all addresses not previously defined
  -- declare the signal correspondent to the RAM memory
  -- ... and define an initial value
  shared variable RAM : MEM_TYPE := InitValue;

begin

  -- architecture for port A
--  process (clk) begin
--    if rising_edge(clk) then
      do <= RAM(conv_integer(addr));
--    end if;
--  end process;

end Behavioral;
