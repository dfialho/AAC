library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity forward_selector is
	port(
		-- Input
		sel_regA : in std_logic_vector(2 downto 0);			-- selector do registo A
      sel_regB : in std_logic_vector(2 downto 0);   		-- selector do registo B
      regA_en : in std_logic;                       		-- indica se se pretende ler do registo A
      regB_en : in std_logic;                       		-- indica se se pretende ler do registo B

		sel_regC_ex : in std_logic_vector(2 downto 0);		-- selector do registo de escrita no andar EX/MEM
		sel_regC_wb : in std_logic_vector(2 downto 0);		-- selector do registo de escrita no andar WB
		regC_en_ex : in std_logic;									-- enable do registo de escrita no andar EX/MEM
		regC_en_wb : in std_logic;									-- enable do registo de escrita no andar WB

		ex_op : in std_logic_vector(4 downto 0);				-- operao a ser executada no andar de execução

		forward_alu : in std_logic_vector(15 downto 0);		-- sinal de forward da ALU
		forward_mem : in std_logic_vector(15 downto 0);		-- sinal de forward da memória
		forward_wb : in std_logic_vector(15 downto 0);		-- sinal de forward do andar de write back

		-- Ouput
		sel_regA_forward : out std_logic;						-- indica que o registo A vem do sinal de forward
		sel_regB_forward : out std_logic;						-- indica que o registo B vem do sinal de forward
		forward_regA : out std_logic_vector(15 downto 0);	-- sinal de forward a ser carregado para o operador A da ALU
		forward_regB : out std_logic_vector(15 downto 0)	-- sinal de forward a ser carregado para o operador B da ALU
	);
end forward_selector;

architecture Behavioral of forward_selector is

	signal loap_op : std_logic := '0';
	-- sinais para definir fonte do registo A
	signal regA_forward_ex : std_logic := '0';
	signal regA_forward_wb : std_logic := '0';
	signal regA_ex_equal : std_logic := '0';
	signal regA_wb_equal : std_logic := '0';
	signal regA_forward_ex_src : std_logic_vector(15 downto 0) := (others => '0');

	-- sinais para definir fonte do registo B
	signal regB_forward_ex : std_logic := '0';
	signal regB_forward_wb : std_logic := '0';
	signal regB_ex_equal : std_logic := '0';
	signal regB_wb_equal : std_logic := '0';
	signal regB_forward_ex_src : std_logic_vector(15 downto 0) := (others => '0');

begin

	-- identificar se a operação no andar de ex/mem é um LOAD da memória
	loap_op <= '1' when ex_op = "01010" else '0';

	--------------------------------------------------
	-- circuito que seleciona a origem do registo A --
	--------------------------------------------------

	-- circuito de fonte do WB
	regA_wb_equal <= '1' when sel_regA = sel_regC_wb else '0';
	regA_forward_wb <= regC_en_wb and regA_en and regA_wb_equal;

	-- circuito de fonte do EX/MEM
	regA_ex_equal <= '1' when sel_regA = sel_regC_ex else '0';
	regA_forward_ex <= regC_en_ex and regA_en and regA_ex_equal;

	-- selecionar sinal de forward caso um o registo de leitura esteja a ser escrito num dos andares de ex/mem ou wb
	sel_regA_forward <= regA_forward_ex or regA_forward_wb;

	-- mux que seleciona se o forward do andar de ex/mem vem da memoria ou da ALU
	regA_forward_ex_src <= forward_mem when loap_op = '1' else forward_alu;

	-- mux que seleciona se o forward vem do andar de ex/mem ou wb
	forward_regA <= regA_forward_ex_src when regA_forward_ex = '1' else forward_wb;

	--------------------------------------------------
	-- circuito que seleciona a origem do registo B --
	--------------------------------------------------

	-- circuito de fonte do WB
	regB_wb_equal <= '1' when sel_regB = sel_regC_wb else '0';
	regB_forward_wb <= regC_en_wb and regB_en and regB_wb_equal;

	-- circuito de fonte do EX/MEM
	regB_ex_equal <= '1' when sel_regB = sel_regC_ex else '0';
	regB_forward_ex <= regC_en_ex and regB_en and regB_ex_equal;

	-- selecionar sinal de forward caso um o registo de leitura esteja a ser escrito num dos andares de ex/mem ou wb
	sel_regB_forward <= regB_forward_ex or regB_forward_wb;

	-- mux que seleciona se o forward do andar de ex/mem vem da memoria ou da ALU
	regB_forward_ex_src <= forward_mem when loap_op = '1' else forward_alu;

	-- mux que seleciona se o forward vem do andar de ex/mem ou wb
	forward_regB <= regB_forward_ex_src when regB_forward_ex = '1' else forward_wb;

end Behavioral;
