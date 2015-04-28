LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY BTB_tb IS
END BTB_tb;
 
ARCHITECTURE behavior OF BTB_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BTB
    PORT(
         clk : IN  std_logic;
         readAddr : IN  std_logic_vector(15 downto 0);
         pcOut : OUT  std_logic_vector(15 downto 0);
         predictionOut : OUT  std_logic;
         writeAddr : IN  std_logic_vector(15 downto 0);
         targetAddr : IN  std_logic_vector(15 downto 0);
         taken : IN  std_logic;
         we : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal readAddr : std_logic_vector(15 downto 0) := (others => '0');
   signal writeAddr : std_logic_vector(15 downto 0) := (others => '0');
   signal targetAddr : std_logic_vector(15 downto 0) := (others => '0');
   signal taken : std_logic := '0';
   signal we : std_logic := '0';

 	--Outputs
   signal pcOut : std_logic_vector(15 downto 0);
   signal predictionOut : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BTB PORT MAP (
          clk => clk,
          readAddr => readAddr,
          pcOut => pcOut,
          predictionOut => predictionOut,
          writeAddr => writeAddr,
          targetAddr => targetAddr,
          taken => taken,
          we => we
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
      wait for clk_period;
      -- insert stimulus here 
      wait for clk_period;
      readAddr <= X"0000";
      wait for clk_period;
      writeAddr <= X"0000";
      targetAddr <= X"0FF0";
      taken <= '1';
      we <= '1';
      wait for clk_period;
      we <= '0';
      taken <= '0';
      readAddr <= X"0000";
      wait for clk_period*2;
      readAddr <= X"0001";
      wait for clk_period;
      readAddr <= X"010F";
      wait for clk_period;
      writeAddr <= X"010F";
      targetAddr <= X"AAAA";
      taken <= '1';
      we <= '1';
      wait for clk_period;
      we <= '0';
      taken <= '0';
      readAddr <= X"010F";
      wait for clk_period;
      readAddr <= X"000F";

      wait;
   end process;

END;
