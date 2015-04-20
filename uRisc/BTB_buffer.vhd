library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity BTB_buffer is
	generic(
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 27 -- sum of all the contents of the memory
		);
  port (
  	-- Input
		clk           : in std_logic;
		addr_MSB      : in std_logic_vector(7 downto 0);
		we            : in std_logic;
		tag_LSB_in    : in std_logic_vector(7 downto 0);
		pc_in         : in std_logic_vector(15 downto 0);
		dirty_bit_in  : in std_logic;
		prediction_in : in std_logic_vector(1 downto 0);


		-- Output
		tag_LSB_out    : out std_logic_vector(7 downto 0);
		pc_out         : out std_logic_vector(15 downto 0);
		dirty_bit_out  : out std_logic;
		prediction_out : out std_logic_vector(1 downto 0)
  );
end entity; -- BTB_buffer

architecture Behavioral of BTB_buffer is

type MEM_TYPE is array (0 to (2**ADDR_WIDTH)-1) of STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

	---- Word
	-- mem(26) = dirty bit
	-- mem(25 downto 18) = tag with the less significant bits
	-- mem(17 downto 2) = PC
	-- mem(1 downto 0) = prediction bits
	signal mem : MEM_TYPE := (others => "100000000000000000000000001");
	signal tmp, tmp_out : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

	tmp <= dirty_bit_in & tag_LSB_in & pc_in & prediction_in;

---------------------- Writing ----------------------
	-- Writing is synchronous
	Write_Mem : process(clk, we)
	begin
		if clk'event and clk = '1' then
			if we = '1' then
				mem(conv_integer(addr_MSB)) <= tmp;
			end if ;
		end if ;
	end process ; -- Write_Mem

	-------------------- Reading -----------------------
	-- Reading is asynchronous
	tmp_out <= mem(conv_integer(addr_MSB));
	dirty_bit_out <= tmp_out(26);
	tag_LSB_out <= tmp_out(25 downto 18);
	pc_out <= tmp_out(17 downto 2);
	prediction_out <= tmp_out(1 downto 0);


end Behavioral; -- Behavioral
