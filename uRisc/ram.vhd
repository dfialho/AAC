library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Data_RAM is
	generic (
		DATA_WIDTH :integer := 16;
        ADDR_WIDTH :integer := 16
    );

    port (
    	-- inputs
		clk     : in std_logic;                                	-- clock
		address : in std_logic_vector (ADDR_WIDTH-1 downto 0); 	-- address
		data_in : in std_logic_vector (DATA_WIDTH-1 downto 0); 	-- data input
		we      : in std_logic;                                	-- write enable
		-- outputs
		data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)	-- data output
    );
end entity;

architecture Behavorial of Data_RAM is
	type MEM_TYPE is array (0 to (2**ADDR_WIDTH)-1) of STD_LOGIC_VECTOR(15 downto 0);
	constant InitValue : MEM_TYPE := (
	77 	=> X"000c",
	78 	=> X"0007",
	79 	=> X"000b",
	80 	=> X"0013",
	81 	=> X"0011",
	82 	=> X"0015",
	83 	=> X"0009",
	84 	=> X"0017",
	85 	=> X"000f",
	86 	=> X"0005",
	87 	=> X"0003",
	88 	=> X"0001",
	89 	=> X"000d",
	others => X"0000");

	shared variable mem : MEM_TYPE := InitValue;

begin

	process (clk) begin
        if clk'event and clk = '1' then
        	if we = '1' then
        		mem(conv_integer(address)) := data_in;
        	end if;
        end if;
    end process;

		-- leitura assíncrona
		data_out <= mem(conv_integer(address));

end architecture;
