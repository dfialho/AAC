----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    14:59:41 03/08/2015
-- Design Name:
-- Module Name:    uRisc - Behavioral
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
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uRisc is
	port(
		clk : in std_logic;
		prediction_miss_count_out : out std_logic_vector(15 downto 0);
		cycle_count_out : out std_logic_vector(15 downto 0);
		output : out std_logic
	);
end uRisc;

architecture Behavioral of uRisc is

	-- BTB
	component BTB is
		generic(
				ADDR_WIDTH : integer := 8;
				DATA_WIDTH : integer := 1+8+16+2 -- sum of all the contents of the memory: Valid bit, Tag, Target, Pred bits
			);
		port (
	  		clk           	: in std_logic;

			-- Read ops
			readAddr     	: in std_logic_vector(15 downto 0);
			pcOut         	: out std_logic_vector(15 downto 0);
			predictionOut 	: out std_logic; -- 1: take it, 0: don't take it

			-- Write ops
			writeAddr	  	: in std_logic_vector(15 downto 0);
			targetAddr		: in std_logic_vector(15 downto 0);
			taken		  		: in std_logic;
			we            	: in std_logic
		);
	end component;

	-- memoria de instrucoes (ROM)
	component DualPortMemory is
		Generic(
	    	ADDR_SIZE : positive := 16
	  	);
	  	Port(
		    addr: in std_logic_vector(ADDR_SIZE - 1 downto 0);
		    do  : out std_logic_vector(15 downto 0)
	  	);
	end component;

	-- decoder
	COMPONENT ID
    	PORT(
    		--Inputs
			Instr : IN  std_logic_vector(15 downto 0);		-- instrucao de entrada
			-- Outputs
			WE : OUT  std_logic;							-- write enable do register	file
			RA : OUT  std_logic_vector(2 downto 0);			-- selecao do registo A
			RB : OUT  std_logic_vector(2 downto 0);			-- selecao do registo B
			WC : OUT  std_logic_vector(2 downto 0);			-- selecao do registo C de escrita
			OP : OUT  std_logic_vector(4 downto 0);			-- opcode de 5 bits
			const : OUT  std_logic_vector(15 downto 0);		-- valor para as operacoes de constantes
			cond_JMP : OUT  std_logic_vector(3 downto 0);	-- sinal de condicao de jump
			mem_write : OUT  std_logic;						-- write enable da memoria de dados
			OP_JMP : OUT  std_logic_vector(1 downto 0);		-- op de condicao
			sel_out : OUT  std_logic_vector(1 downto 0);	-- seleciona o mux a entrada do file register
			mux_A : OUT  std_logic;							-- seleciona a entrada A da ALU
			flags_we   : out std_logic_vector(3 downto 0);	-- write enable dos registos das flags
			destiny_JMP : OUT  std_logic_vector(15 downto 0)-- sinal para somar ao PC + 1 (IMM)
        );
    END COMPONENT;

	-- bloco de verificacao de condicao de salto
	component CheckCond
		Port (
			-- Inputs
			cond : in  std_logic_vector (3 downto 0);
			flag_zero : in  std_logic;		-- Z
			flag_negative : in  std_logic;	-- N
			flag_carry : in  std_logic;		-- C
			flag_overflow : in  std_logic;	-- V
			opcode : in  std_logic_vector (1 downto 0);

			-- Outputs
			sel_PC : out  std_logic_vector(1 downto 0)
		);
	end component;

	-- register file
	component Reg
		Port (
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
	end component;

	-- ALU
	component ALU
    Port (
      -- entradas e saídas a maiúsculas
      OP          : in  STD_LOGIC_VECTOR (4 downto 0);
      A           : in  STD_LOGIC_VECTOR (15 downto 0);
      B           : in  STD_LOGIC_VECTOR (15 downto 0);
      C_OUTPUT    : out  STD_LOGIC_VECTOR (15 downto 0);

			-- ordem dos bits da flag: S O C Z
      FLAGS       : out  STD_LOGIC_VECTOR (3 downto 0)
    );
	end component;

	-- memoria de dados (RAM)
	component Data_RAM
		generic (
				DATA_WIDTH :integer := 16;
	      ADDR_WIDTH :integer := 16
	    );
	    port (
	    	-- inputs
			clk     : in std_logic;                                	-- clock
			address : in std_logic_vector (ADDR_WIDTH-1 downto 0); 	-- address
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0); 	-- data input
			we      : in std_logic;                                	-- write enable
			-- outputs
			data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)	-- data output
	    );
	end component;

	-- bloco trata o forwarding dos registos de entrada
	component forward_selector
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
	end component;

	-- registo do PC
	signal pc : std_logic_vector(15 downto 0) := (others => '0');									-- valor do PC actual
	signal pc_we : std_logic;																											-- write enable do registo do PC

	-- registo das flags
	signal flags : std_logic_vector(3 downto 0) := (others => '0'); 	-- ordem das flags: Z N C V
	signal flags_we : std_logic_vector(3 downto 0) := (others => '0'); 	-- wirte enables dos registos da flags
	signal flag_Z, flag_V, flag_N, flag_C : std_logic := '0';

	-- sinais de ligacao do bloco de verificacao de condicao de salto
	signal cond_jmp : std_logic_vector(3 downto 0) := (others => '0');	-- sinal que indica a condicao de salto
	signal op_jmp : std_logic_vector(1 downto 0) := (others => '0');	-- codigo de operacao de salto
	signal sel_PC : std_logic_vector(1 downto 0) := (others => '0');	-- sinal de selecao do proximo PC

	-- sinais de ligacao relacionados com o PC
	signal pc_next : std_logic_vector(15 downto 0) := (others => '0');	-- proximo valor a guardar no registo do PC
	signal pc_inc : std_logic_vector(15 downto 0) := (others => '0');	-- valor do PC + 1
	signal pc_jmp : std_logic_vector(15 downto 0) := (others => '0');	-- sinal de PC + jump + 1
	signal jmp : std_logic_vector(15 downto 0) := (others => '0');		-- sinal de jump

	-- sinais de ligacao da memoria de instrucoes
	signal instr : std_logic_vector(15 downto 0) := (others => '0');	-- sinal com a instrucao selecionada pelo PC

	-- sinais do register file
	signal sel_reg_A : std_logic_vector(2 downto 0) := (others => '0');	-- sinal de selecao do registo A
	signal reg_A : std_logic_vector(15 downto 0) := (others => '0');	-- sinal do registo A
	signal sel_reg_B : std_logic_vector(2 downto 0) := (others => '0');	-- sinal de selecao do registo B
	signal reg_B : std_logic_vector(15 downto 0) := (others => '0');	-- sinal do registo B
	signal sel_reg_C : std_logic_vector(2 downto 0) := (others => '0');	-- sinal de selecao do registo de escrica RC
	signal reg_data : std_logic_vector(15 downto 0) := (others => '0');	-- sinal do registo C de escrita
	signal reg_we : std_logic := '0';									-- write enable do register file
	signal sel_data : std_logic_vector(1 downto 0) := (others => '0');	-- sinal que seleciona a origem dos dados a
																		-- armazenar no register file
	-- sinais da memoria de dados
	signal mem_we : std_logic := '0';									-- write enable da memoria de dados
	signal mem_data_out : std_logic_vector(15 downto 0) := (others => '0'); -- sinal de saida de dados da memoria

	-- sinais da ALU
	signal sel_A : std_logic := '0';														-- seleciona saida do mux A
	signal alu_A : std_logic_vector(15 downto 0) := (others => '0');	-- entrada A da ALU
	signal alu_OP : std_logic_vector(4 downto 0) := (others => '0');	-- sinal de selecao da operacao da ALU
	signal alu_flags : std_logic_vector(3 downto 0) := (others => '0');	-- sinais das flags apos uma operacao da ALU
	signal alu_S : std_logic_vector(15 downto 0) := (others => '0');	-- resultado da operacao da ALU
	signal const : std_logic_vector(15 downto 0) := (others => '0');	-- valor da constante para a ALU

	-- sinais usados para o forwarding
	signal sel_regA_src : std_logic := '0';
	signal sel_regB_src : std_logic := '0';
	signal forward_regA : std_logic_vector(15 downto 0) := (others => '0');	-- sinal de forward do registo A
	signal forward_regB : std_logic_vector(15 downto 0) := (others => '0');	-- sinal de forward do registo B

	-- sinais usados nos muxes de forwarding
	signal mux_A_out : std_logic_vector(15 downto 0) := (others => '0');
	signal alu_B : std_logic_vector(15 downto 0) := (others => '0');	-- entrada B da ALU

	-- sinais de registos pipeline
	-- primeiro andar de pipeline
	signal pipe1_instruction : std_logic_vector(15 downto 0) := (others => '0');		-- instrução
	signal pipe1_pc_inc : std_logic_vector(15 downto 0) := (others => '0');				-- PC + 1
	signal pipe1_pc : std_logic_vector(15 downto 0) := (others => '0');
	signal pipe1_taken : std_logic := '0';
	--signal pipe1_btb_jmp_addr : std_logic_vector(15 downto 0) := (others => '0');

	-- segundo andar de pipeline
	signal pipe2_rst : std_logic := '0';															-- sinal de reset do segundo andar de pipeline
	signal pipe2_pc_inc : std_logic_vector(15 downto 0) := (others => '0');							-- PC + 1
	--signal pipe2_jmp_cond : std_logic_vector(3 downto 0) := (others => '0');							-- condição de salto
	--signal pipe2_jmp_op : std_logic_vector(1 downto 0) := (others => '0');								-- operação de salto
	--signal pipe2_jmp_dest : std_logic_vector(15 downto 0) := (others => '0');						-- destino de salto
	signal pipe2_alu_op : std_logic_vector(4 downto 0) := (others => '0');								-- operação da ALU
	signal pipe2_mem_we : std_logic := '0';																				-- write enable da memória de dados
	signal pipe2_sel_reg_C : std_logic_vector(2 downto 0) := (others => '0');			-- selector do registo de escrita (WC)
	signal pipe2_reg_we : std_logic := '0';																				-- write enable do register file
	signal pipe2_sel_data : std_logic_vector(1 downto 0) := (others => '0');			-- selector da origem do dados a escrever no RF
	signal pipe2_A : std_logic_vector(15 downto 0) := (others => '0');						-- operando A da ALU
	signal pipe2_B : std_logic_vector(15 downto 0) := (others => '0');						-- operando B da ALU
	signal pipe2_flags_we : std_logic_vector(3 downto 0) := (others => '0');			-- write enables das flags (Z N C V)

	-- terceiro andar de pipeline
	signal pipe3_alu_s : std_logic_vector(15 downto 0) := (others => '0');				-- resultado da operação da ALU
	signal pipe3_pc_inc : std_logic_vector(15 downto 0) := (others => '0');				-- PC + 1
	signal pipe3_sel_data : std_logic_vector(1 downto 0) := (others => '0');			-- selector da origem do dados a escrever no RF
	signal pipe3_mem_data_out : std_logic_vector(15 downto 0) := (others => '0');	-- dados de saida da memória
	signal pipe3_reg_we : std_logic := '0';																				-- write enable do register file
	signal pipe3_sel_reg_C : std_logic_vector(2 downto 0) := (others => '0');			-- selector do registo de escrita (WC)

	-- sinais da BTB
	signal taken : std_logic := '0';																-- indica se assume o salto ou não
	signal btb_jmp_addr : std_logic_vector(15 downto 0) := (others => '0');			-- endereco de salto

	-- sinais de resolução de conflitos de controlo
	signal to_jmp : std_logic := '0';															-- sinal que indica que foi feito um salto
	signal btb_we : std_logic := '0';															-- write enable da BTB
	signal smash : std_logic := '0';																-- indicar que se pretende esmagar instruções anteriores

	-- sinais do bloco de next pc
	signal mux_op_pc : std_logic_vector(15 downto 0) := (others => '0');				-- valor do pc tendo em conta a operacao e condicao de salto
	signal mux_taken_pc : std_logic_vector(15 downto 0) := (others => '0');			-- valor do pc dependente se o salto foi tomado ou nao
	signal mux_smash_pc : std_logic_vector(15 downto 0) := (others => '0');			-- valor do pc tendo em conta se a operacao no fetch é para ser esmagada

	signal prediction_miss_count : std_logic_vector(15 downto 0) := (others => '0');
	signal cycle_count : std_logic_vector(15 downto 0) := (others => '0');

begin

	-- registo do PC; este registo nao precisa de enable porque esta sempre a ser actualizado
	process(clk)
	begin
		if clk'event and clk = '1' then
			pc <= pc_next;
		end if;
	end process;

	-- incrementador do PC
	pc_inc <= pc + '1';

	-- BTB
	Inst_BTB : BTB port map (
  		clk => clk,
		-- Read ops
		readAddr => pc,						-- PC directamente do registo
		pcOut => btb_jmp_addr,				-- endereco armazenado na BTB
		predictionOut => taken,				-- sinal de indicacao de salto
		-- Write ops
		writeAddr => pipe1_pc,				-- PC no andar de ID
		targetAddr => pc_jmp,				-- endereco de salto calculado no bloco NextPC
		taken => to_jmp,						-- indicacao de que o salto foi ou não tomado
		we => btb_we							-- write enable da btb
	);

	-- memoria de instrucoes
	Inst_rom : DualPortMemory port map (
        -- Input
        addr => pc,
        -- Output
        do => instr
	);

	-- primeiro andar de pipeline
	process(clk)
	begin
		if clk'event and clk = '1'then
			if smash = '1' then
				pipe1_instruction <= X"0000";
				pipe1_pc_inc <= X"0000";
				pipe1_pc <= X"0000";
				pipe1_taken <= '0';
			else
				pipe1_instruction <= instr;
				pipe1_pc_inc <= pc_inc;
				pipe1_pc <= pc;
				pipe1_taken <= taken;
			end if;
		end if;
	end process;

	-- decoder
	Inst_decoder : ID port map (
		--Inputs
		Instr => pipe1_instruction,
		-- Outputs
		WE => reg_we,
		RA => sel_reg_A,
		RB => sel_reg_B,
		WC => sel_reg_C,
		OP => alu_OP,
		const => const,
		cond_JMP => cond_jmp,
		mem_write => mem_we,
		OP_JMP => op_jmp,
		sel_out => sel_data,
		mux_A => sel_A,
		flags_we => flags_we,
		destiny_JMP => jmp
	);

	-- file register
	Inst_file_regiser : Reg port map (
		-- Input
		RC => pipe3_sel_reg_C,
		RA => sel_reg_A,
		RB => sel_reg_B,
		WE => pipe3_reg_we,
		clk => clk,
		data => reg_data,
		-- Ouput
		A_out => reg_A,
		B_out => reg_B
	);

	-- muxes de selecao da entrada A e B da ALU
	mux_A_out <= reg_A when sel_A = '1' else const;

	-- muxes que selecionam se os registos de leitura vem do register file ou do sinal de forwarding
	alu_A <= forward_regA when sel_regA_src = '1' else mux_A_out;
	alu_B <= forward_regB when sel_regB_src = '1' else reg_B;

	inst_forward_selector: forward_selector port map (
		-- Input
		sel_regA => sel_reg_A,
      sel_regB => sel_reg_B,
      regA_en => sel_A,
      regB_en => '1',

		sel_regC_ex => pipe2_sel_reg_C,
		sel_regC_wb => pipe3_sel_reg_C,
		regC_en_ex => pipe2_reg_we,
		regC_en_wb => pipe3_reg_we,

		ex_op => pipe2_alu_op,

		forward_alu => alu_S,
		forward_mem => mem_data_out,
		forward_wb => reg_data,

		-- Ouput
		sel_regA_forward => sel_regA_src,
		sel_regB_forward => sel_regB_src,
		forward_regA => forward_regA,
		forward_regB => forward_regB
	);

	-- determinar se foi feito um salto
	to_jmp <= sel_PC(0) or sel_PC(1);

	-- escreve-se na btb caso se trate de uma instrucao de salto condicional
	btb_we <= not cond_jmp(3);

	-- é necessario esmagar	a intrucao no fetch caso se pretenda saltar e não se tenha tomado o salto no fetch ou ao contrario
	smash <= pipe1_taken xor to_jmp;

	-- segundo andar de pipeline
	process(clk)
	begin
		if clk'event and clk = '1' then
			pipe2_pc_inc <= pipe1_pc_inc;
			pipe2_alu_op <= alu_OP;
			pipe2_mem_we <= mem_we;
			pipe2_sel_reg_C <= sel_reg_C;
			pipe2_reg_we <= reg_we;
			pipe2_sel_data <= sel_data;
			pipe2_A <= alu_A;
			pipe2_B <= alu_B;
			pipe2_flags_we <= flags_we;
		end if;
	end process;

	-- ALU
	Inst_ALU : ALU port map (
      -- entradas e saídas a maiúsculas
      OP => pipe2_alu_op,
      A => pipe2_A,
      B => pipe2_B,
      C_OUTPUT => alu_S,
      FLAGS => alu_flags
  );

	-- registo das flags
	process(clk)
	begin
		if clk'event and clk = '1' then
			-- flags: Z N C V alu_flags: N V C Z
			if pipe2_flags_we(0) = '1' then
				flags(0) <= alu_flags(2);
			end if;
			if pipe2_flags_we(1) = '1' then
				flags(1) <= alu_flags(1);
			end if;
			if pipe2_flags_we(2) = '1' then
				flags(2) <= alu_flags(3);
			end if;
			if pipe2_flags_we(3) = '1' then
				flags(3) <= alu_flags(0);
			end if;
		end if;
	end process;

	-- forwarding das flags -- flags: Z N C V alu_flags: N V C Z
	flag_Z <= alu_flags(0) when pipe2_flags_we(3) = '1' else flags(3);
	flag_N <= alu_flags(3) when pipe2_flags_we(2) = '1' else flags(2);
	flag_C <= alu_flags(1) when pipe2_flags_we(1) = '1' else flags(1);
	flag_V <= alu_flags(2) when pipe2_flags_we(0) = '1' else flags(0);

	-- bloco de verificacao de condicao de salto
	Inst_CheckCond : CheckCond port map (
		-- Inputs
		cond => cond_jmp,
		flag_zero => flag_Z,
		flag_negative => flag_N,
		flag_carry => flag_C,
		flag_overflow => flag_V,
		opcode => op_jmp,
		-- Outputs
		sel_PC => sel_PC
	);

	------------------------------------
	-- determinar proximo valor do PC --
	------------------------------------

	-- somador do PC+1 do andar de ID + jmp
	pc_jmp <= pipe1_pc_inc + jmp;

	-- mux de selecao do proximo PC
	with sel_PC select
	mux_op_pc <=	pc_inc when "00",	-- PC+1 do fetch
					pc_jmp when "01",
					reg_B when "10",	-- testar se isto esta correcto
					reg_B when "11",
					X"0000" when others;

	-- mux que seleciona o proximo PC tendo em conta se o salto foi tomado ou nao
	mux_taken_pc <= pipe1_pc_inc when pipe1_taken = '1' else mux_op_pc;

	-- mux que seleciona o proximo PC tendo em conta se a operacao no fetch é para ser esmagada
	mux_smash_pc <= mux_taken_pc when smash = '1' else pc_inc;

	-- mux que seleciona se o pc é carregado com o endereço determinado no andar de ID ou com o endereço aramzenado na BTB
	-- o pc só é caregado com o endereço da BTB caso o salto seja para ser tomado e não se pretenda esmagar a operação no andar de fetch
	pc_next <= btb_jmp_addr when (taken and (not smash)) = '1' else mux_smash_pc;

	-- memoria de dados
	Inst_data_ram : Data_RAM port map (
    	-- inputs
		clk => clk,
		address => pipe2_A,
		data_in => pipe2_B,
		we => pipe2_mem_we,
		-- outputs
		data_out => mem_data_out
  );

	-- terceiro andar de pipeline
	process(clk)
	begin
		if clk'event and clk = '1' then
			pipe3_alu_s <= alu_S;
			pipe3_pc_inc <= pipe2_pc_inc;
			pipe3_sel_data <= pipe2_sel_data;
			pipe3_mem_data_out <= mem_data_out;
			pipe3_reg_we <= pipe2_reg_we;
			pipe3_sel_reg_C <= pipe2_sel_reg_C;
		end if;
	end process;

	-- mux de selecao de entrada do register file
	with pipe3_sel_data select
	reg_data <=	pipe3_alu_s when "00",
					pipe3_mem_data_out when "01",
					pipe3_pc_inc when "10",
					X"0000" when others;

	-- registo que conta falha na predicao de salto
	process(clk)
	begin
		if clk'event and clk = '1' then
			if smash = '1' then
				prediction_miss_count <= prediction_miss_count + '1';
			end if;
		end if;
	end process;

	process(clk)
	begin
		if clk'event and clk = '1' then
			cycle_count <= cycle_count + '1';
		end if;
	end process;

	cycle_count_out <= cycle_count;
	prediction_miss_count_out <= prediction_miss_count;

end Behavioral;
