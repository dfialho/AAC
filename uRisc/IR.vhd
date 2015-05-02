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
	0 	=> X"4803",
	1 	=> X"8988",
	2 	=> X"05fe",
	3 	=> X"90d0",
	4 	=> X"98d8",
	5 	=> X"2fff",
	6 	=> X"0000",
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
