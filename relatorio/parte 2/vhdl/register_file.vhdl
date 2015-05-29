library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Reg is
	port(
			-- Input
			RC   : in std_logic_vector(2 downto 0);
			RA   : in std_logic_vector(2 downto 0);
			RB   : in std_logic_vector(2 downto 0);
			WE   : in std_logic;
			clk  : in std_logic;
			data : in std_logic_vector(15 downto 0);

			-- Ouput
			A_out : out std_logic_vector(15 downto 0);
			B_out : out std_logic_vector(15 downto 0)
	);
end Reg;

architecture Behavioral of Reg is

signal selC : std_logic_vector(7 downto 0) := (others => '0');
signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := (others => '0');
signal AA, BA : std_logic_vector(2 downto 0) := (others => '0');

begin
---------------------------- MUX Select -----------------------------------------
	AA <= RA;
	BA <= RB;

------------------------- Register Decoder --------------------------------------
	selC <= "00000001" when RC = "000" and WE = '1' else
			  "00000010" when RC = "001" and WE = '1' else
			  "00000100" when RC = "010" and WE = '1' else
			  "00001000" when RC = "011" and WE = '1' else
			  "00010000" when RC = "100" and WE = '1' else
			  "00100000" when RC = "101" and WE = '1' else
			  "01000000" when RC = "110" and WE = '1' else
			  "10000000" when RC = "111" and WE = '1' else
			  "00000000";

------------------------------- Registers ---------------------------------------
-- Register 0
process(clk)
	begin
		if clk'event and clk = '1' then
			if selC(0) = '1' then
				r0 <= data;
			end if;
		end if;
	end process;

-- Register 1
process(clk)
	begin
		if clk'event and clk = '1' then
			if selC(1) = '1' then
				r1 <= data;
			end if;
		end if;
	end process;

-- Register 2
process(clk)
	begin
		if clk'event and clk = '1' then
			if selC(2) = '1' then
				r2 <= data;
			end if;
		end if;
	end process;

-- Register 3
process(clk)
	begin
		if clk'event and clk = '1' then
			if selC(3) = '1' then
				r3 <= data;
			end if;
		end if;
	end process;

-- Register 4
process(clk)
	begin
		if clk'event and clk = '1' then
			if selC(4) = '1' then
				r4 <= data;
			end if;
		end if;
	end process;

-- Register 5
process(clk)
	begin
		if clk'event and clk = '1' then
			if selC(5) = '1' then
				r5 <= data;
			end if;
		end if;
	end process;

-- Register 6
process(clk)
	begin
		if clk'event and clk = '1' then
			if selC(6) = '1' then
				r6 <= data;
			end if;
		end if;
	end process;

-- Register 7
process(clk)
	begin
		if clk'event and clk = '1' then
			if selC(7) = '1' then
				r7 <= data;
			end if;
		end if;
	end process;

------------------------------ EXIT ---------------------------------------
	A_out <= r0 when AA = "000" else
				r1 when AA = "001" else
				r2 when AA = "010" else
				r3 when AA = "011" else
				r4 when AA = "100" else
				r5 when AA = "101" else
				r6 when AA = "110" else
				r7;

	B_out <= r0 when BA = "000" else
				r1 when BA = "001" else
				r2 when BA = "010" else
				r3 when BA = "011" else
				r4 when BA = "100" else
				r5 when BA = "101" else
				r6 when BA = "110" else
				r7;

end Behavioral;
