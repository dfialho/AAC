--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:08:59 03/14/2015
-- Design Name:   
-- Module Name:   /home/ricardo/Desktop/AAC - Xilinx/uRisc/ALU_testbench.vhd
-- Project Name:  uRisc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ALU
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ALU_testbench IS
END ALU_testbench;
 
ARCHITECTURE behavior OF ALU_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         OP : IN  std_logic_vector(4 downto 0);
         A : IN  std_logic_vector(15 downto 0);
         B : IN  std_logic_vector(15 downto 0);
         C_OUTPUT : OUT  std_logic_vector(15 downto 0);
         FLAGS : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal OP : std_logic_vector(4 downto 0) := (others => '0');
   signal A : std_logic_vector(15 downto 0) := (others => '0');
   signal B : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal C_OUTPUT : std_logic_vector(15 downto 0);
   signal FLAGS : std_logic_vector(3 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name

	signal clk : std_logic := '0';
 
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          OP => OP,
          A => A,
          B => B,
          C_OUTPUT => C_OUTPUT,
          FLAGS => FLAGS
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 30 ns;	

      wait for clk_period;
  
  		A <= X"0001";
  		B <= X"FFF0";
  		
    -- ADDER
      -- A + B
      OP <= "00000";
  		wait for clk_period;
      -- A + B + 1
      OP <= "00001"; 
      wait for clk_period;
      -- A + 1
      OP <= "00011"; 
      wait for clk_period;
      -- A - B - 1
      OP <= "00100"; 
      wait for clk_period;
      -- A - B           
      OP <= "00101"; 
      wait for clk_period;
      -- A - 1
      OP <= "00110"; 

    -- SHIFTS
      -- SLL
      OP <= "01000"; 
      wait for clk_period;
      -- SRA
      OP <= "01001"; 
      wait for clk_period;

    -- Constantes
      -- Const11
      OP <= "01100"; 
      wait for clk_period;
      -- Const8 Low
      OP <= "01110"; 
      wait for clk_period;
      -- Const8 High
      OP <= "01111"; 
      wait for clk_period;

    -- ASSIGNMENTS
      -- ZEROS
      OP <= "10000"; 
      wait for clk_period;
      -- ONES
      OP <= "11111"; 
      wait for clk_period;
      -- A
      OP <= "10101"; 
      wait for clk_period;
      -- NOT A
      OP <= "11010"; 
      wait for clk_period;
      -- B
      OP <= "10011"; 
      wait for clk_period;
      -- NOT B
      OP <= "11100"; 
      wait for clk_period;

    -- LOGIC
      -- OR
        -- A or B
        OP <= "10111"; 
        wait for clk_period;
        -- not A or B
        OP <= "11011"; 
        wait for clk_period;
        -- A or not B
        OP <= "11101"; 
        wait for clk_period;
        -- not A or not B
        OP <= "11101"; 
        wait for clk_period;
      -- AND
        -- A and B
        OP <= "10001"; 
        wait for clk_period;
        -- not A and B
        OP <= "10010"; 
        wait for clk_period;
        -- A and not B
        OP <= "10100"; 
        wait for clk_period;
        -- not A and not B
        OP <= "11000"; 
        wait for clk_period;
      -- XOR
        -- positive
        OP <= "10110"; 
        wait for clk_period;
        -- negative
        OP <= "11001"; 
        wait for clk_period;


      wait;
   end process;

END;
