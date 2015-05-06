library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity BTB is
	generic(
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 1+8+16+1 -- sum of all the contents of the memory: Valid bit, Tag, Target, Pred bits
		);
  port (
  		clk           	: in std_logic;

		-- Read ops
		readAddr     	: in std_logic_vector(15 downto 0);
		pcOut         	: out std_logic_vector(15 downto 0);
		predictionOut 	: out std_logic; -- 1: take it, 0: don't take it

		-- Write ops
		writeAddr	  	: in std_logic_vector(15 downto 0);
		targetAddr		: in std_logic_vector(15 downto 0);
		taken		  		: in std_logic;
		we            	: in std_logic
  );
end entity;

architecture Behavioral of BTB is

type MEM_TYPE is array (0 to (2**ADDR_WIDTH)-1) of STD_LOGIC_VECTOR(25 downto 0);

	signal mem : MEM_TYPE := (others => "00000000000000000000000000");
	signal dataFromEntry	: std_logic_vector(25 downto 0) := (others => '0');

	signal tag	: std_logic_vector(7 downto 0);
	signal prediction : std_logic_vector(1 downto 0);
	signal BTBHit	: std_logic;

begin

---------------------- Writing ----------------------

	-- Writing is synchronous
	Write_Mem : process(clk, we)
	begin
		if clk'event and clk = '1' then
			if we = '1' then
				mem(conv_integer(writeAddr(7 downto 0))) <= '1' & writeAddr(15 downto 8) & targetAddr & taken;
			end if ;
		end if ;
	end process ; -- Write_Mem

-------------------- Reading -----------------------
	-- Reading is asynchronous
	dataFromEntry <= mem(conv_integer(readAddr(7 downto 0)));

	tag <= dataFromEntry(24 downto 17);
	BTBHit <= '1' when tag = readAddr(15 downto 8) else '0';

	pcOut <= dataFromEntry(16 downto 1);

	predictionOut <= dataFromEntry(0) and BTBHit and dataFromEntry(25);


end Behavioral; -- Behavioral
