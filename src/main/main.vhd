--Codigo VHDL de um controlador de elevador de tres andares.
--reset : faz com que o elevador retorne ao tÃ©rreo.
--enable : quando inativo (0), desabilita o painel de controle, nÃ£o atendendo Ã s chamadas
--Torna - se ativo
--quando o elevador estÃ¡ no estado PARADO.
--motor : (00) parado; (01) para cima; (10) para baixo.
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
		clk, reset : IN std_logic;
		--Switch para os sensores
		SW : IN std_logic_vector(3 DOWNTO 0);
		--Botoes para os andares
		KEY : IN std_logic_vector(2 DOWNTO 0);
		motor : OUT std_logic_vector(1 DOWNTO 0);
		--Porta
		LEDG : OUT std_logic_vector(0 downto 0)
	);
END elevador;
ARCHITECTURE controlador OF elevador IS
	TYPE state IS (parado, subindo, descendo);
	SIGNAL atual : state := parado;
	SIGNAL prox : state;
	SIGNAL enable : std_logic;
	SIGNAL andar : std_logic_vector(1 DOWNTO 0) := "00";
	SIGNAL seguinte : std_logic_vector(1 DOWNTO 0);

	--Declara��o de sensores
	SIGNAL sensor_up : std_logic_vector;
	SIGNAL sensor_mid_up : std_logic_vector;
	SIGNAL sensor_mid_down : std_logic_vector;
	SIGNAL sensor_down : std_logic_vector;
BEGIN
	sensor_up <= SW(3);
	sensor_mid_up <= SW(2);
	sensor_mid_down <= SW(1);
	sensor_down <= SW(0);
	porta <= LEDG(0);

	--Logica dos botoes
	PROCESS(KEY, seguinte)
	BEGIN
		--Selecao do primeiro andar
		IF(KEY(0) = 1) THEN
			seguinte <= "00"
		END IF;
		--Selecao do segundo andar
		IF(KEY(1) = 1) THEN
			seguinte <= "01"
		END IF;
		--Selecao do terceiro andar
		IF(KEY(2) = 1) THEN
			seguinte <= "10"
		END IF;
	END PROCESS;	

	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
			atual <= parado;
		ELSIF (clk'EVENT AND clk = '1') THEN
			atual <= prox;
			IF (prox = subindo AND andar /= "11") THEN
				andar <= andar + 1;
			ELSIF (prox = descendo AND andar /= "00") THEN
				andar <= andar - 1;
			END IF;
		END IF;
	END PROCESS;
	
	--Logica de operacao com os sensores
	PROCESS (sensores,andar)
		BEGIN
			CASE sensores IS	
				--Quando o sensor de cima estiver ativo
				WHEN "1000" =>
					andar <= "10";
				--Quando o sensor do meio estiver ativo
				WHEN "0110" => 
					andar <= "01";
				--Quando o sensor de baixo estiver ativo
				WHEN "0001" =>
					andar <= "00";
			END CASE;
	END PROCESS;			

	--Logica para definir o proximo andar
	PROCESS (andar, seguinte)
		BEGIN
			CASE andar IS
				--Elevador no primeiro andar
				WHEN "00" => 
					IF seguinte > "00" THEN
						prox <= subindo;
					ELSE
						prox <= parado;
					END IF;
				--Elevador no segundo andar
				WHEN "01" => 
					IF seguinte = "00" THEN
						prox <= descendo;
					ELSIF (seguinte > "01") THEN
						prox <= subindo;
					ELSE
						prox <= parado;
					END IF;
				--Elevador no terceiro andar
				WHEN "10" => 
					IF seguinte = "00" OR seguinte = "01" THEN
						prox <= descendo;
					ELSIF (seguinte = "10") THEN
						prox <= parado;
					ELSE
						prox <= subindo;
				END IF;
				WHEN "11" => 
					IF seguinte < "11" THEN
						prox <= descendo;
					ELSE
						prox <= parado;
					END IF;
				END CASE;
			END PROCESS;
			
			--Movimentos dos elevador
			PROCESS (atual, andar)
			BEGIN
				CASE atual IS
					WHEN parado => 
						porta <= '1';
						motor <= "00";
						enable <= '1';
					WHEN subindo => 
						porta <= '0';
						motor <= "01";
						enable <= '0';
					WHEN descendo => 
						porta <= '0';
						motor <= "10";
						enable <= '0';
				END CASE;
			END PROCESS;
END controlador;