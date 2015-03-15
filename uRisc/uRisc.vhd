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
		-- Inputs
		clk : in std_logic
	);
end uRisc;

architecture Behavioral of uRisc is
	
	-- memoria de instrucoes (ROM)
	component DualPortMemory is
		Generic(
	    	ADDR_SIZE : positive := 16
	  	);
	  	Port(
		    clk : in std_logic;
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
			mux_B : OUT  std_logic;							-- seleciona a entrada B da ALU
			destiny_JMP : OUT  std_logic_vector(15 downto 0)-- sinal para somar ao PC + 1 (IMM)
        );
    END COMPONENT;

	-- bloco de verificacao de condicao de salto
	component CheckCond 
		Port (
			-- Inputs 
	    	clk : in  std_logic;
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

	-- registo do PC
	signal pc : std_logic_vector(15 downto 0) := (others => '0');		-- valor do PC actual
	-- registo das flags
	signal flags : std_logic_vector(3 downto 0) := (others => '0'); 	-- ordem das flags: Z N C V

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
	signal reg_C : std_logic_vector(15 downto 0) := (others => '0');	-- sinal do registo C de escrita
	signal reg_we : std_logic := '0';									-- write enable do register file
	signal sel_data : std_logic_vector(1 downto 0) := (others => '0');	-- sinal que seleciona a origem dos dados a
																		-- armazenar no register file
	-- sinais da memoria de dados
	signal mem_we : std_logic := '0';									-- write enable da memoria de dados
	signal mem_data_out : std_logic_vector(15 downto 0) := (others => '0'); -- sinal de saida de dados da memoria

	-- sinais da ALU
	signal sel_A : std_logic;											-- seleciona a origem da entrada A da ALU
	signal alu_A : std_logic_vector(15 downto 0) := (others => '0');	-- entrada A da ALU
	signal alu_OP : std_logic_vector(4 downto 0) := (others => '0');	-- sinal de selecao da operacao da ALU
	signal alu_flags : std_logic_vector(3 downto 0) := (others => '0');	-- sinais das flags apos uma operacao da ALU
	signal alu_S : std_logic_vector(15 downto 0) := (others => '0');	-- resultado da operacao da ALU
	signal const : std_logic_vector(15 downto 0) := (others => '0');	-- valor da constante para a ALU

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

	-- somador do PC + 1 + jp
	pc_jmp <= pc_inc + jmp;

	-- mux de selecao do proximo PC
	with sel_PC select
	pc_next <=	pc_inc 	when "00",
				pc_jmp 	when "01",
				reg_B 	when "11",
				X"0000" when others;

	-- memoria de instrucoes
	Inst_rom : DualPortMemory port map (
        -- Input
        addr => pc,
        clk => clk,
        -- Output
        do => instr
	);

	-- decoder
	Inst_decoder : ID port map (
		--Inputs 
		Instr => instr,			-- instrucao de entrada
		-- Outputs
		WE => reg_we, 			-- write enable do register	file
		RA => sel_reg_A,		-- selecao do registo A
		RB => sel_reg_B,		-- selecao do registo B
		WC => sel_reg_C,		-- selecao do registo C de escrita
		OP => alu_OP,			-- opcode de 5 bits
		const => const,			-- valor para as operacoes de constantes
		cond_JMP => cond_jmp,		-- sinal de condicao de jump
		mem_write => mem_we,	-- wirte enable da memoria de dados
		OP_JMP => op_jmp,		-- op de condicao
		sel_out => sel_data,	-- seleciona o mux a entrada do file register
		mux_A => sel_A,			-- seleciona a entrada A da ALU
		mux_B => open,			-- seleciona a entrada B da ALU
		destiny_JMP => jmp 		-- sinal para somar ao PC + 1 (IMM)
	);

	-- file register
	Inst_file_regiser : Reg port map (
		-- Input
		RC => sel_reg_C,
		RA => sel_reg_A,
		RB => sel_reg_B,
		WE => reg_we,
		clk => clk,
		data => reg_C,
		-- Ouput
		A_out => reg_A,
		B_out => reg_B
	);

	-- mux de selecao da entrada A da ALU
	alu_A <= reg_A when sel_A = '1' else const;

	-- ALU
	Inst_ALU : ALU port map (
        -- entradas e saídas a maiúsculas
        OP => alu_OP,
        A => alu_A,
        B => reg_B,
        C_OUTPUT => alu_S,
        FLAGS => alu_flags
    );            

	-- registo das flags
	process(clk)
	begin
		if clk'event and clk = '1' then
			-- flags: Z N C V alu_flags: N V C Z
			flags <= alu_flags(0) & alu_flags(3) & alu_flags(1) & alu_flags(2);
		end if;
	end process;

	-- bloco de verificacao de condicao de salto
	Inst_CheckCond : CheckCond port map (
		-- Inputs 
    	clk => clk,
		cond => cond_jmp,
		flag_zero => flags(3),
		flag_negative => flags(2),
		flag_carry => flags(1),
		flag_overflow => flags(0),
		opcode => op_jmp,
		-- Outputs
		sel_PC => sel_PC
	);

	-- memoria de dados
	Inst_data_ram : Data_RAM port map (
    	-- inputs
		clk => clk,
		address => reg_A,
		data_in => reg_B,
		we => mem_we,
		-- outputs
		data_out => mem_data_out
    );

	-- mux de selecao de entrada do register file
	with sel_data select
	reg_C <=	alu_S 			when "00",
				mem_data_out 	when "01",
				pc_inc 			when "10",
				X"0000" 		when others;

end Behavioral;

