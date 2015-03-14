--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    17:45:48 03/02/2015
-- Design Name:
-- Module Name:    ID - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID is
	port(
		-- Input
		Instr : in std_logic_vector(15 downto 0);
		clk   : in std_logic;

		-- Output
		WE        : out std_logic;
		RA        : out std_logic_vector(2 downto 0);
		RB        : out std_logic_vector(2 downto 0);
		WC        : out std_logic_vector(2 downto 0);
		OP        : out std_logic_vector(4 downto 0);
		const     : out std_logic_vector(15 downto 0);
		cond_JMP  : out std_logic_vector(3 downto 0);
		mem_write : out std_logic;
		OP_JMP    : out std_logic_vector(1 downto 0);
		sel_out   : out std_logic_vector(1 downto 0);
		mux_A     : out std_logic;
		mux_B     : out std_logic;
		destiny_JMP: out std_logic_vector(15 downto 0)
	);
end ID;

architecture Behavioral of ID is

signal class : std_logic_vector(1 downto 0);

begin

---------------------- Instruction Class ---------------------------------------

	class <= Instr(15 downto 14);

---------------------- Operation ALU/Memory ------------------------------------
-- ALU Instruction Format:
-- class <= Instr(15 downto 14) := "10"
-- WC <= Instr(13 downto 11)
-- OP <=	Instr(10 downto 6)
-- RA <= Instr(5 downto 3)
-- RB <= Instr(2 downto 0)

	OP <= Instr(10 downto 6);

  ------------------------ Registers ALU ---------------------------------------
	RA <= Instr(5 downto 3);
	RB <= Instr(13 downto 11) when class = "11" else
				Instr(2 downto 0);
	WC <= "111" when class = "00" and Instr(13 downto 12) = "11" and
				Instr(11) = '0' else
				Instr(13 downto 11);

---------------------------- Constants -----------------------------------------
-- Constants Instruction Format:
-- class <= Instr(15 downto 14) := "01" or "11"
-- WC <= Instr(13 downto 11)
--- Format I => class = "01"
-- const <= Instr(10 downto 0)
--- Format II => class = "11"
-- R <= Instr(10)
-- Don't Care (X) <= Instr(9 downto 8)
-- const <= Instr(7 downto 0)

-- Sign extend constant and select the correct one
	const <= Instr(10)&Instr(10)&Instr(10)&Instr(10)&Instr(10)&Instr(10 downto 0)
						when class = "01" else
					 Instr(7)&Instr(7)&Instr(7)&Instr(7)&Instr(7)&Instr(7)&Instr(7)&
					 Instr(7)&Instr(7 downto 0) when class = "11" else
					 X"0000";


----------------------------- Control ------------------------------------------
-- Control Instruction Format:
-- class <= Instr(15 downto 14) := "00"
-- OP <= Instr(13 downto 12)
--- Format I => OP = "00" or "01"
-- cond <= Instr(11 downto 8)
-- offset <= Instr(7 downto 0)
--- Format II => OP = "10"
-- offset <= Instr(11 downto 0)
--- Format III => OP = "11"
-- R <= Instr(11)
-- Don't Care (X) <= Instr(10 downto 3)
-- RB <= Instr(2 downto 0)

---- Jump operation
	OP_JMP <= Instr(13 downto 12);

---- Jump condition
-- If the operation lacks a condition, signal "1000" will be sent by default.
	cond_JMP <= Instr(11 downto 8) when class = "00" and
	 						(Instr(13 downto 12) = "00" or Instr(13 downto 12) = "01") else
							"1000";

-- Jump Destiny
	destiny_JMP <= Instr(7)&Instr(7)&Instr(7)&Instr(7)&Instr(7)&Instr(7)&
								 Instr(7)&Instr(7)&Instr(7 downto 0) when
								 (Instr(13 downto 12) = "00" or Instr(13 downto 12) = "01") and class = "00" else
								 Instr(11)&Instr(11)&Instr(11)&Instr(11)&Instr(11 downto 0)
								 when Instr(13 downto 12) = "10" and class = "00" else
								 X"0000";


--------------------------- Write Enable ---------------------------------------

	WE <= '1' when (class = "01" or (class = "10" and Instr(10 downto 6) /= "01010" and
				Instr(10 downto 6) /= "01011") or class = "11") or
				(class = "00" and Instr(11) = '0' and Instr(13 downto 12) = "11") else
				'0';

-------------------------- Selection Output ------------------------------------
---- Selects the output of the final Mux in the WB stage.
-- 00 => ALU
-- 01 => Memory (Will only write to register if store operation is executed)
-- 10 => PC + 1
-- 11 => Don't Care (X)

	sel_out <= "10" when Instr(11) = '0' and class = "00" else
						 "00" when class = "01" or class = "11" or (class = "10"
						 and Instr(10 downto 6) /= "01010") else
						 "01" when class = "10" and Instr(10 downto 6) = "01010" else
 						 "11";

------------------------- Select ALU A Input -----------------------------------
-- Selects Register when instruction class is ALU or Memory else
-- selects constant

	mux_A <= '1' when class = "10" else
					 '0';

------------------------- Select ALU B Input -----------------------------------
-- Selects Register when instruction class is ALU or Memory else
-- selects constant

	mux_B <= '1' when class = "10" or class = "11" else
					 '0';

------------------------ Memory Write Enable -----------------------------------
	mem_write <= '1' when class = "10" and Instr(10 downto 6) = "01011" else
					 '0';

end Behavioral;
