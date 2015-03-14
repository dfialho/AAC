----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:49:21 03/08/2015 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( 
    			clk		: in std_logic; 
    			OP 		: in  STD_LOGIC_VECTOR (4 downto 0);
           	A	: in  STD_LOGIC_VECTOR (15 downto 0);
           	B	: in  STD_LOGIC_VECTOR (15 downto 0);
           	C_output	: out  STD_LOGIC_VECTOR (15 downto 0);
           	Flags 	: out  STD_LOGIC_VECTOR (7 downto 0));
end ALU;

architecture Behavioral of ALU is
	signal sel_A, sel_B 				: std_logic;
	signal sel_OPS 					: std_logic_vector (2 downto 0);

	signal or_op, and_op, xor_op 	: std_logic_vector (15 downto 0);
	signal mux_A, mux_B 				: std_logic_vector (15 downto 0);
	signal shifted, const, adder	: std_logic_vector (15 downto 0);
	signal result			: std_logic_vector (15 downto 0);

begin

	-- selects (choose between input and not input)
	sel_A <= OP(4) and ((not OP(3) and OP(2)) or (not OP(1) and OP(0)));
	sel_B <= OP(4) and ((not OP(2) and OP(0)) or (not OP(3) and (OP(1) and not OP(0))));

	-- adder
	with OP(2 downto 0) select
		adder <= A + B 		when	"000",
					A + B + '1' 	when	"001",
					A + '1' 		when	"011",
					A + not B  	when	"100",
					A + not B +'1' 		when	"101",
					A - 1    when 	"110",
					X"0000" 		when others;

	-- shifts
	shifted <= A(14 downto 0)&'0' when OP(0)='0' else A(15)&A(15 downto 1);
	
	-- muxes --
	mux_A <= not A when sel_A = '0' else A;
	mux_B <= not B when sel_B = '0' else B;

	--  ones / zeros
	const <= X"0000" when OP(0) = '1' else X"FFFF";

	-- logic ops
	or_op 	<= mux_A or mux_B;
	and_op 	<= mux_A and mux_B;
	xor_op	<= A xor B when OP(0) = '0' else not (A xor B);


	--  escolher o sinal de controlo para o mux de saída (não sei se isto cria lógica como quero ou se faz um mux)
	with OP select 
		sel_OPS <=  "000" 	when "00000", -- ADD
						"000"		when "00001", -- ADD
						"000" 	when "00011", -- ADD
						"000"		when "00100", -- ADD
						"000"		when "00101", -- ADD
						"000"		when "00110", -- ADD
						"001" 	when "01000", -- SHIFT
						"001" 	when "01001", -- SHIFT
						"100" 	when "10000", -- CONST
						"110" 	when "10001", -- AND
						"110"		when "10010", -- AND
						"011" 	when "10011", -- Mux_B
						"110" 	when "10100", -- AND
						"010" 	when "10101", -- Mux_A
						"111" 	when "10110", -- XOR
						"101" 	when "10111", -- OR
						"110" 	when "11000", -- AND
						"111" 	when "11001", -- XNOR
						"010" 	when "11010", -- Mux_A
						"101"		when "11011", -- OR
						"011" 	when "11100", -- Mux_B
						"101"		when "11101", -- OR
						"101" 	when "11110", -- OR
						"100" 	when "11111", -- CONST
						"000" 	when others;

	--  mux de saída
	with sel_OPS select
		C_output <=	adder			when "000",
						shifted		when "001",
						mux_A			when "010",
						mux_B			when "011",
						const			when "100",
						or_op			when "101",
						and_op		when "110",
						xor_op		when "111",
						X"0000"		when others;


end Behavioral;

