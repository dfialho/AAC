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
  0 => X"77FF", -- Binary value for address 0
  1 => X"C005",
  2 => X"C400",
  3 => X"3000",
  4 => X"2FFF", -- value for address 5
  5 => X"601D",
  6 => X"580F",
  7 => X"901C",
  8 => X"3807",
  others => X"0000"); -- value for all addresses not previously defined
  -- declare the signal correspondent to the RAM memory
  -- ... and define an initial value
  shared variable myRAM : MEM_TYPE := InitValue0;

begin

  -- architecture for port A
  process (clk) begin
    if rising_edge(clk) then
      do <= RAM(conv_integer(addr));
    end if;
  end process;

end Behavioral;
