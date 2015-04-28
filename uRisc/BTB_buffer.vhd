library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity BTB_buffer is
	generic(
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 1+8+16+2 -- sum of all the contents of the memory: Valid bit, Tag, Target, Pred bits 
		);
  port (
  		clk           	: in std_logic;

		-- Read ops
		readAddr     	: in std_logic_vector(15 downto 0);
		pcOut         	: out std_logic_vector(15 downto 0);
		predictionOut 	: out std_logic;

		-- Write ops
		writeAddr	  	: in std_logic_vector(15 downto 0);
		targetAddr		: in std_logic_vector(15 downto 0);
		taken		  	: in std_logic;
		we            	: in std_logic
  );
end entity;

architecture Behavioral of BTB_buffer is

type MEM_TYPE is array (0 to (2**ADDR_WIDTH)-1) of STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

	---- Word
	-- mem(26) = valid bit
	-- mem(25 downto 18) = tag: addr MSB
	-- mem(17 downto 2) = target addr
	-- mem(1 downto 0) = prediction bits
	signal mem : MEM_TYPE := (others => "000000000000000000000000000");
	signal tmp, tmp_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
	
	signal tag	: std_logic_vector(7 downto 0);
	signal oldPredBits, newPredBits : std_logic_vector(1 downto 0);
	signal prediction : std_logic_vector(1 downto 0);
	signal lastReadValid, BTBHit	: std_logic;


begin

---------------------- Writing ----------------------
	newPredBits(1) <= oldPredBits(0) 		and ((oldPredBits(1) or taken) or (oldPredBits(1) and taken));
	newPredBits(0) <= (not oldPredBits(0)) 	and ((oldPredBits(1) or taken) or (oldPredBits(1) and taken));
	
	with BTBHit select
		prediction <= 	newPredBits 		when '1',
						taken & (not taken)	when '0',
						"00"	when others;

	tmp <= '1' & writeAddr(7 downto 0) & targetAddr & prediction;

	-- Writing is synchronous
	Write_Mem : process(clk, we)
	begin
		if clk'event and clk = '1' then
			if we = '1' then
				mem(conv_integer(writeAddr(15 downto 8))) <= tmp;
			end if ;
		end if ;
	end process ; -- Write_Mem

-------------------- Reading -----------------------
	oldPrediction : process(clk, we) -- to be used by the write operation
	begin
		if clk'event and clk = '1' then
			oldPredBits <= tmp_out(1 downto 0); -- prediction bits
			lastReadValid <= tmp_out(26); -- valid bit
			BTBHit <= '1'; -- TO DO!!!!!! 
		end if;
	end process;

	-- Reading is asynchronous
	tmp_out <= mem(conv_integer(writeAddr(15 downto 8)));
	tag <= tmp_out(25 downto 18);
	pcOut <= tmp_out(17 downto 2);
	predictionOut <= oldPredBits(1);

end Behavioral; -- Behavioral