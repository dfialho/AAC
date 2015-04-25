library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity forward_selector is
	port(
		-- Input
		sel_regA : in std_logic_vector(3 downto 0);			-- selector do registo A
      sel_regB : in std_logic_vector(3 downto 0);   		-- selector do registo B
      regA_en : in std_logic;                       		-- indica se se pretende ler do registo A
      regB_en : in std_logic;                       		-- indica se se pretende ler do registo B
      sel_regC_ex : in std_logic_vector(15 downto 0);		-- selector do registo de escrita no andar EX/MEM
		sel_regC_wb : in std_logic_vector(15 downto 0);		-- selector do registo de escrita no andar WB
		regC_en_ex : in std_logic;									-- enable do registo de escrita no andar EX/MEM
		regC_en_wb : in std_logic;									-- enable do registo de escrita no andar WB
		alu_op : in std_logic_vector(4 downto 0);				-- operao a ser executada na ALU

		-- Ouput
		sel_regA_src : out std_logic_vector(3 downto 0);	-- selector da origem do registo A
		sel_regB_src : out std_logic_vector(3 downto 0);	-- selector da origem do registo B
		stall : out std_logic										-- indica que  necessrio fazer Stall
	);
end forward_selector;

architecture Behavioral of forward_selector is

	signal loap_op : std_logic := '0';
	-- sinais para definir fonte do registo A
	signal regA_forward_ex : std_logic := '0';
	signal regA_forward_ex_prev : std_logic := '0';
	signal regA_forward_wb : std_logic := '0';
	signal regA_ex_equal : std_logic := '0';
	signal regA_wb_equal : std_logic := '0';

	-- sinais para definir fonte do registo B
	signal regB_forward_ex : std_logic := '0';
	signal regB_forward_ex_prev : std_logic := '0';
	signal regB_forward_wb : std_logic := '0';
	signal regB_ex_equal : std_logic := '0';
	signal regB_wb_equal : std_logic := '0';

	-- sinais para indicar execucao de operacao de instrucao NOP
	signal stall_A : std_logic := '0';
	signal stall_B : std_logic := '0';

begin

	loap_op <= '1' when alu_op = "01010" else '0';

	--------------------------------------------------
	-- circuito que seleciona a origem do registo A --
	--------------------------------------------------

	-- circuito de fonte do WB
	regA_wb_equal <= '1' when sel_regA = sel_regC_wb else '0';
	regA_forward_wb <= regC_en_wb and regA_en and regA_wb_equal;

	-- circuito de fonte do EX/MEM
	regA_ex_equal <= '1' when sel_regA = sel_regC_ex else '0';
	regA_forward_ex_prev <= regC_en_ex and regA_en and regA_ex_equal;
	regA_forward_ex <= regA_forward_ex_prev and not(loap_op);

	-- o bit mais significativo do sinal de selecao de saida indica se o valor do registo A vem
	-- de algum forward ou directamente do file register
	sel_regA_src(1) <= regA_forward_ex or regA_forward_wb;

	-- o bit menos significativo do sinal de selecao de saida indica se o valor do registo A vem
	-- do andar de WB ou EX/MEM caso seja necessario fazer forward
	-- no caso de nao ser necessario fazer forward este bit  ignorado
	sel_regA_src(0) <= not regA_forward_wb;

	--------------------------------------------------
	-- circuito que seleciona a origem do registo B --
	--------------------------------------------------

	-- circuito de fonte do WB
	regB_wb_equal <= '1' when sel_regB = sel_regC_wb else '0';
	regB_forward_wb <= regC_en_wb and regB_en and regB_wb_equal;

	-- circuito de fonte do EX/MEM
	regB_ex_equal <= '1' when sel_regB = sel_regC_ex else '0';
	regB_forward_ex_prev <= regC_en_ex and regB_en and regB_ex_equal;
	regB_forward_ex <= regB_forward_ex_prev and not(loap_op);

	-- o bit mais significativo do sinal de selecao de saida indica se o valor do registo B vem
	-- de algum forward ou directamente do file register
	sel_regB_src(1) <= regB_forward_ex or regB_forward_wb;

	-- o bit menos significativo do sinal de selecao de saida indica se o valor do registo B vem
	-- do andar de WB ou EX/MEM caso seja necessario fazer forward
	-- no caso de nao ser necessario fazer forward este bit  ignorado
	sel_regB_src(0) <= not regB_forward_wb;

	-------------------------------------------------------------------------------------------------
	-- Circuito que indica se  preciso fazer Stall 															  --
	--  necessario fazer Stall quando  necessario fazer forward do andar de EX/MEM e a instrucao --
	-- que se encontra nesse andar corresponde a um LOAD da memria (01010)								  --
	-------------------------------------------------------------------------------------------------
	stall_A <= regA_forward_ex_prev and not(regA_forward_ex);
	stall_B <= regB_forward_ex_prev and not(regB_forward_ex);
	stall <= stall_A or stall_B;

end Behavioral;
