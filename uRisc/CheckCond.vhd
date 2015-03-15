----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:47:14 03/08/2015 
-- Design Name: 
-- Module Name:    CheckCond - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CheckCond is
    Port ( 
    	-- Inputs 
    	clk : in  std_logic;
		cond : in  std_logic_vector (3 downto 0);
		flag_zero : in  std_logic;
		flag_negative : in  std_logic;
		flag_carry : in  std_logic;
		flag_overflow : in  std_logic;
		opcode : in  std_logic_vector (1 downto 0);
		
		-- Outputs
		sel_PC : out  std_logic
	);
end CheckCond;

architecture Behavioral of CheckCond is
	signal c0_xnor_c1 : std_logic;	-- cond(0) xnor cond(1)
	signal cond_op : std_logic;		-- resultado obtido a partir do sinal da condicao
	signal c2_1 : std_logic;		-- valor de cond_op quando C2 é 1
	signal c2_0 : std_logic;		-- valor de cond_op quando C2 é 0
	
begin
	
	c0_xnor_c1 <= cond(0) xnor cond(1);

	-- cond_op para cond(2) = 0
	c2_0 <= ((flag_overflow and cond(0)) or (not cond(0))) and c0_xnor_c1;

	-- cond_op para cond(2) = 1
	c2_1 <= (((flag_carry and cond(1)) or flag_zero) and cond(0)) or (c0_xnor_c1 and flag_negative);

	-- mux 2:1 do cond_op
	cond_op <= c2_1 when cond(2) = '1' else c2_0;

	-- logica definida pelo OP
	sel_PC <= cond(3) or ((not cond(3)) and ((cond_op xnor opcode(0)) or opcode(1)));

end Behavioral;

