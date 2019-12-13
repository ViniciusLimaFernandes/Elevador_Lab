--Codigo VHDL de um controlador de elevador de tres andares.
--reset : faz com que o elevador retorne ao terreo.
--enable : quando inativo (0), desabilita o painel de controle, nao atendendo as chamadas
--Torna - se ativo
--quando o elevador esta¡ no estado PARADO.
--andares: (00) primeiro andar; (01) segundo andar; (10) terceiro andar.
--botoes: (00) primeiro andar; (01) segundo andar; (10) terceiro andar.
--porta : (1) aberta; (0) fechada.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
ENTITY elevador IS
	PORT (
--		clk, reset : IN std_logic;
--		clk : IN std_logic;
		--Switch para os sensores
		SW : IN std_logic_vector(17 DOWNTO 0);
		--Botoes para os andares
		KEY : IN std_logic_vector(2 DOWNTO 0);
		--Motor
		LEDR : OUT std_logic_vector(2 DOWNTO 0);
		--Porta
		LEDG : OUT std_logic_vector(0 downto 0)
	);
END elevador;

ARCHITECTURE controlador OF elevador IS
	TYPE state IS (parado, subindo, descendo);
	SIGNAL atual : state := parado;
	SIGNAL prox : state;
	SIGNAL enable : std_logic;
	SIGNAL clk : std_logic;
	SIGNAL andar : std_logic_vector(2 DOWNTO 0) := "000";
	SIGNAL seguinte : std_logic_vector(1 DOWNTO 0);
	SIGNAL sensores : std_logic_vector(3 DOWNTO 0);

	--Declaracao de sensores
--	SIGNAL sensor_up : std_logic;
--	SIGNAL sensor_mid_up : std_logic;
--	SIGNAL sensor_mid_down : std_logic;
--	SIGNAL sensor_down : std_logic;
	SIGNAL motorS : std_logic;
	SIGNAL motorP : std_logic;
	SIGNAL motorD : std_logic;
	SIGNAL porta : std_logic;

	BEGIN
--		sensor_up <= SW(3);
--		sensor_mid_up <= SW(2);
--		sensor_mid_down <= SW(1);
--		sensor_down <= SW(0);
		sensores <= SW(3 DOWNTO 0);
		enable <= SW(17);
		LEDG(0) <= porta;
		LEDR(2) <= motorS;	--Motor subindo
		LEDR(1) <= motorP; --Motor descendo
		LEDR(0) <= motorD; --Motor parado
		clk <= sw(16);
		atual <= prox;

	
--	PROCESS (clk, reset)
--		BEGIN
--			IF (reset = '1') THEN
--				atual <= parado;
--			ELSIF (clk'EVENT AND clk = '1') THEN
--				atual <= prox;
--			IF (prox = subindo AND andar /= "11") THEN
--				andar <= andar + 1;
--			ELSIF (prox = descendo AND andar /= "00") THEN
--				andar <= andar - 1;
--			END IF;
--		END IF;
--	END PROCESS;


	--Logica dos botoes
	PROCESS(clk)
	BEGIN
	   if rising_edge (clk) then
		
			--Selecao do primeiro andar
			IF(KEY(0) = '1') THEN
				seguinte <= "00";
			END IF;
			--Selecao do segundo andar
			IF(KEY(1) = '1') THEN
				seguinte <= "01";
			END IF;
			--Selecao do terceiro andar
			IF(KEY(2) = '1') THEN
				seguinte <= "10";
			END IF;
		END IF;
		
	END PROCESS;
	
	--Logica de operacao com os sensores
	PROCESS (clk)
		BEGIN
			if rising_edge (clk) then
				CASE sensores IS	
					--Quando o sensor de cima estiver ativo
					WHEN "1000" =>
						andar <= "100";
					--Quando o sensor do meio estiver ativo
					WHEN "0110" => 
						andar <= "010";
					--Quando o sensor de baixo estiver ativo
					WHEN "0001" =>
						andar <= "001";
					when others =>
						andar <= "000";
				END CASE;
			END IF;
	END PROCESS;			

	--Logica para definir o proximo andar
	PROCESS (clk)
		BEGIN
			if rising_edge (clk) then
				CASE andar IS
					--Elevador no primeiro andar
					WHEN "000" => 
						IF seguinte > "00" THEN
							prox <= subindo;
						ELSE
							prox <= parado;
						END IF;
					--Elevador no segundo andar
					WHEN "010" => 
						IF seguinte = "00" THEN
							prox <= descendo;
						ELSIF (seguinte > "01") THEN
							prox <= subindo;
						ELSE
							prox <= parado;
						END IF;
					--Elevador no terceiro andar
					WHEN "100" => 
						IF seguinte = "00" OR seguinte = "01" THEN
							prox <= descendo;
						ELSIF (seguinte = "10") THEN
							prox <= parado;
						ELSE
							prox <= subindo;
					END IF;
					WHEN "111" => 
						IF seguinte < "11" THEN
							prox <= descendo;
						ELSE
							prox <= parado;
						END IF;
					when others =>
						prox <= parado;
					END CASE;
				END IF;
			END PROCESS;
			
			--Movimentos dos elevador
			PROCESS (clk)
			BEGIN
				if rising_edge (clk) then
					CASE atual IS
						WHEN parado => 
							porta <= '1';
							motorS <= '0';
							motorP <= '1';
							motorD <= '0';
							enable <= '1';
						WHEN subindo => 
							porta <= '0';
							motorS <= '1';
							motorP <= '0';
							motorD <= '0';
							enable <= '0';
						WHEN descendo => 
							porta <= '0';
							motorS <= '0';
							motorP <= '0';
							motorD <= '1';
							enable <= '0';
					END CASE;
				END IF;
			END PROCESS;
END controlador;
