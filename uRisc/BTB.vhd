library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity BTB is
	generic(
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 1+8+16+2 -- sum of all the contents of the memory: Valid bit, Tag, Target, Pred bits 
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
		taken		  	: in std_logic;
		we            	: in std_logic
  );
end entity;

architecture Behavioral of BTB is

type MEM_TYPE is array (0 to (2**ADDR_WIDTH)-1) of STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

	---- Word
	-- mem(26) = valid bit
	-- mem(25 downto 18) = tag: addr MSB
	-- mem(17 downto 2) = target addr
	-- mem(1 downto 0) = prediction bits
	signal mem : MEM_TYPE := (others => "000000000000000000000000000");
	signal dataFromEntry, dataToWrite	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	
	signal tag	: std_logic_vector(7 downto 0);
	signal oldPredBits, readPredBits, newPredBits : std_logic_vector(1 downto 0);
	signal prediction : std_logic_vector(1 downto 0);
	signal lastReadValid, BTBHit, didLastHit	: std_logic;

begin

---------------------- Writing ----------------------
	newPredBits(1) <= oldPredBits(0) 		and ((oldPredBits(1) or taken) or (oldPredBits(1) and taken));
	newPredBits(0) <= (not oldPredBits(0)) 	and ((oldPredBits(1) or taken) or (oldPredBits(1) and taken));
	
	with didLastHit and lastReadValid select
		prediction <= 	newPredBits 		when '1',
						taken & (not taken)	when '0',
						"00"	when others;

	dataToWrite <= '1' & writeAddr(15 downto 8) & targetAddr & prediction;

	-- Writing is synchronous
	Write_Mem : process(clk, we)
	begin
		if clk'event and clk = '1' then
			if we = '1' then
				mem(conv_integer(writeAddr(7 downto 0))) <= dataToWrite;
			end if ;
		end if ;
	end process ; -- Write_Mem

-------------------- Reading -----------------------
	-- Reading is asynchronous
	dataFromEntry <= mem(conv_integer(readAddr(7 downto 0)));

	tag <= dataFromEntry(25 downto 18);
	BTBHit <= '1' when tag = readAddr(15 downto 8) else '0';

	pcOut <= dataFromEntry(17 downto 2);

	readPredBits <= dataFromEntry(1 downto 0);
	predictionOut <= readPredBits(1) and BTBHit and dataFromEntry(26);

	process(clk) -- Delay the read prediction bits so the new bits calculation can be made on the write stage
	begin
		if clk'event and clk = '1' then
			oldPredBits <= readPredBits;
			lastReadValid <= dataFromEntry(26); -- valid bit
			didLastHit <= BTBHit;
		end if ;
	end process ;	

end Behavioral; -- Behavioral