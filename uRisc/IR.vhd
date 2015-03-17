library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DualPortMemory is
  Generic(
    ADDR_SIZE : positive := 16
  );
  Port(
    clk : in std_logic;
    addr: in std_logic_vector(ADDR_SIZE - 1 downto 0);
    do  : out std_logic_vector(15 downto 0)
  );
end DualPortMemory;

architecture Behavioral of DualPortMemory is

  -- declare a type of matrix of words... the memory
  type MEM_TYPE is array (0 to (2**ADDR_SIZE)-1) of STD_LOGIC_VECTOR(15 downto 0);
  -- declare a constant with the memory initial value
  constant InitValue : MEM_TYPE := (
  0 => X"2003",
  1 => X"2055",
  2 => X"2055",
  3 => X"2055",
  4 => X"6000",
  5 => X"c000",
  6 => X"c480",
  7 => X"c8ae",
  8 => X"ccdd",
  9 => X"d0ea",
  10 => X"d47f",
  11 => X"d8c7",
  12 => X"dc2b",
  13 => X"b000",
  14 => X"0301",
  15 => X"a0e0",
  16 => X"b01b",
  17 => X"1301",
  18 => X"a0e0",
  19 => X"b15a",
  20 => X"0401",
  21 => X"a0e0",
  22 => X"b153",
  23 => X"1401",
  24 => X"a0e0",
  25 => X"b152",
  26 => X"0501",
  27 => X"a0e0",
  28 => X"b15a",
  29 => X"1501",
  30 => X"a0e0",
  31 => X"b15b",
  32 => X"0701",
  33 => X"a0e0",
  34 => X"b153",
  35 => X"1701",
  36 => X"a0e0",
  37 => X"b000",
  38 => X"0601",
  39 => X"a0e0",
  40 => X"b013",
  41 => X"1601",
  42 => X"a0e0",
  43 => X"b142",
  44 => X"1301",
  45 => X"2001",
  46 => X"a0e0",
  47 => X"b01b",
  48 => X"0301",
  49 => X"2001",
  50 => X"a0e0",
  51 => X"b15a",
  52 => X"1401",
  53 => X"2001",
  54 => X"a0e0",
  55 => X"b153",
  56 => X"0401",
  57 => X"2001",
  58 => X"a0e0",
  59 => X"b176",
  60 => X"1501",
  61 => X"2001",
  62 => X"a0e0",
  63 => X"b11a",
  64 => X"0501",
  65 => X"2001",
  66 => X"a0e0",
  67 => X"b149",
  68 => X"1701",
  69 => X"2001",
  70 => X"a0e0",
  71 => X"b153",
  72 => X"0701",
  73 => X"2001",
  74 => X"a0e0",
  75 => X"b001",
  76 => X"1601",
  77 => X"2001",
  78 => X"a0e0",
  79 => X"b013",
  80 => X"0601",
  81 => X"2001",
  82 => X"a0e0",
  83 => X"a260",
  84 => X"6be8",
  85 => X"82ec",
  86 => X"2fff",
  87 => X"3807",
  88 => X"3807",
  89 => X"3807",
  others => X"0000"); -- value for all addresses not previously defined
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
