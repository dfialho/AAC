--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:48:18 03/06/2015
-- Design Name:   
-- Module Name:   E:/Lab1/test_id.vhd
-- Project Name:  Lab1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ID
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
 
ENTITY test_id IS
END test_id;
 
ARCHITECTURE behavior OF test_id IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ID
    PORT(
         Instr : IN  std_logic_vector(15 downto 0);
         clk : IN  std_logic;
         WE : OUT  std_logic;
         RA : OUT  std_logic_vector(2 downto 0);
         RB : OUT  std_logic_vector(2 downto 0);
         WC : OUT  std_logic_vector(2 downto 0);
         OP : OUT  std_logic_vector(4 downto 0);
         const : OUT  std_logic_vector(15 downto 0);
         cond_JMP : OUT  std_logic_vector(3 downto 0);
         mem_write : OUT  std_logic;
         OP_JMP : OUT  std_logic_vector(1 downto 0);
         sel_out : OUT  std_logic_vector(1 downto 0);
         mux_A : OUT  std_logic;
         mux_B : OUT  std_logic;
         R_const : OUT  std_logic;
         destiny_JMP : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Instr : std_logic_vector(15 downto 0) := (others => '0');
   signal clk : std_logic := '0';

 	--Outputs
   signal WE : std_logic;
   signal RA : std_logic_vector(2 downto 0);
   signal RB : std_logic_vector(2 downto 0);
   signal WC : std_logic_vector(2 downto 0);
   signal OP : std_logic_vector(4 downto 0);
   signal const : std_logic_vector(15 downto 0);
   signal cond_JMP : std_logic_vector(3 downto 0);
   signal mem_write : std_logic;
   signal OP_JMP : std_logic_vector(1 downto 0);
   signal sel_out : std_logic_vector(1 downto 0);
   signal mux_A : std_logic;
   signal mux_B : std_logic;
   signal R_const : std_logic;
   signal destiny_JMP : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ID PORT MAP (
          Instr => Instr,
          clk => clk,
          WE => WE,
          RA => RA,
          RB => RB,
          WC => WC,
          OP => OP,
          const => const,
          cond_JMP => cond_JMP,
          mem_write => mem_write,
          OP_JMP => OP_JMP,
          sel_out => sel_out,
          mux_A => mux_A,
          mux_B => mux_B,
          R_const => R_const,
          destiny_JMP => destiny_JMP
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
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		Instr <= "0000000000000000" after 20ns, -- NOP
					---------------- ALU ---------------
					-- WC = R2
					-- RA = R1
					-- RB = R3
					"1001000000001011" after 40ns, -- C = A + B
					"1001000001001011" after 60ns, -- C = A + B + 1
					"1001000011001011" after 80ns, -- C = A + 1
					"1001000100001011" after 100ns, -- C = A - B - 1
					"1001000101001011" after 120ns, -- C = A - B
					"1001000110001011" after 140ns, -- C = A - 1
					"1001001000001011" after 160ns, -- C = Shift Lógico Esquerdo
					"1001001001001011" after 180ns, -- C = Shift Aritmético Direito
 					"1001010000001011" after 200ns, -- C = 0
					"1001010001001011" after 220ns, -- C = A&B
					"1001010010001011" after 240ns, -- C = !A&B
					"1001010011001011" after 260ns, -- C = B
					"1001010100001011" after 280ns, -- C = A&!B
					"1001010101001011" after 300ns, -- C = A
					"1001010110001011" after 320ns, -- C = A xor B
					"1001010111001011" after 340ns, -- C = A|B  
					"1001011000001011" after 360ns, -- C = !A&!B
					"1001011001001011" after 380ns, -- C = !(A xor B)
					"1001011010001011" after 400ns, -- C = !A
					"1001011011001011" after 420ns, -- C = !A|B
					"1001011100001011" after 440ns, -- C = !B
					"1001011101001011" after 460ns, -- C = A|!B
					"1001011110001011" after 480ns, -- C = !A|!B
					"1001011111001011" after 500ns, -- C = 1
					---------------- Constants ---------------
					-- WC = R5
					--- Format I
					-- 11 bit Constant =  749
					-- Format II
					-- 8 bit constant = -102
					"0110101011101101" after 520ns, -- C = constant
					"1110100011100110" after 540ns, -- C = Const8|(C&0xff00)
					"1110110011100110" after 560ns, -- C = (Const8 << 8)|(C&0x00ff)
					---------------- Control -----------------
					--- Format I
					-- JMP destiny I = -106
					--- Format II 
					-- JMP destiny II = 1
					-- Format III
					-- RB = R6
					----- Format I
					"0000010010010110" after 580ns, -- Jump False Negative
					"0000010110010110" after 600ns, -- Jump False Zero
					"0000011010010110" after 620ns, -- Jump False Carry
					"0000011110010110" after 640ns, -- Jump False Negative or Zero
					"0000000010010110" after 660ns, -- Jump False True
					"0000001110010110" after 680ns, -- Jump False OVFL
					"0001010010010110" after 700ns, -- Jump True Negative
					"0001010110010110" after 720ns, -- Jump True Zero
					"0001011010010110" after 740ns, -- Jump True Carry
					"0001011110010110" after 760ns, -- Jump True Negative or Zero
					"0001000010010110" after 780ns, -- Jump True True
					"0001001110010110" after 800ns, -- Jump True OVFL
					------ Format II
					"0010000000000001" after 820ns, -- Jump
					------ Format III
					"0011000000000110" after 840ns, -- Jump and Link 
 					"0011100000000110" after 860ns, -- Jump Register
					--------------- Memory ------------------
					-- WC = R4
					-- RA = R3
					-- RB = R2
					"1010001010011010" after 880ns, -- Load
					"1010001011011010" after 900ns; -- Store
					
		

      wait;
   end process;

END;
