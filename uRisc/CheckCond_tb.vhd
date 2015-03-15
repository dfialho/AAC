--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:17:58 03/15/2015
-- Design Name:   
-- Module Name:   /home/david/Development/AAC/uRisc/CheckCond_tb.vhd
-- Project Name:  uRisc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CheckCond
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
USE ieee.std_logic_unsigned.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY CheckCond_tb IS
END CheckCond_tb;
 
ARCHITECTURE behavior OF CheckCond_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CheckCond
    PORT(
         clk : IN  std_logic;
         cond : IN  std_logic_vector(3 downto 0);
         flag_zero : IN  std_logic;
         flag_negative : IN  std_logic;
         flag_carry : IN  std_logic;
         flag_overflow : IN  std_logic;
         opcode : IN  std_logic_vector(1 downto 0);
         sel_PC : OUT  std_logic_vector(1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal cond : std_logic_vector(3 downto 0) := (others => '0');
   signal flags : std_logic_vector(3 downto 0) := (others => '0');
   signal opcode : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal sel_PC : std_logic_vector(1 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CheckCond PORT MAP (
          clk => clk,
          cond => cond,
          flag_zero => flags(3),
          flag_negative => flags(2),
          flag_carry => flags(1),
          flag_overflow => flags(0),
          opcode => opcode,
          sel_PC => sel_PC
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
      wait for clk_period;
      -- insert stimulus here 

      flags <= "0000";
      opcode <= "00";
      cond <= "0000";
      for i in 0 to 1023 loop
        wait for clk_period;
        opcode <= opcode + '1';

        if opcode = "11" then 
          cond <= cond + '1';
        end if;

        if cond = "1111" and opcode = "11" then
          flags <= flags + '1';
        end if;
      end loop;

      wait for clk_period;

      wait;
   end process;

END;
