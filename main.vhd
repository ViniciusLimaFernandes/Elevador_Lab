CÃ³digo VHDL de um controlador de elevador de trÃªs andares.
reset: faz com que o elevador retorne ao tÃ©rreo.
enable: quando inativo (0), desabilita o painel de controle, nÃ£o atendendo Ã s chamadas
. Torna-se ativo
quando o elevador estÃ¡ no estado PARADO.
motor: (00) - parado; (01) - para cima; (10) - para baixo.
porta: (1) - aberta; (0) - fechada.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity elevador is
port(
clk, reset : in std_logic;
seletor: in std_logic_vector(1 downto 0);
motor : out std_logic_vector(1 downto 0);
porta : out std_logic
);
end elevador;
architecture controlador of elevador is
type state is (parado, subindo, descendo);
signal atual : state := parado;
signal prox : state;
signal enable : std_logic;
signal andar : std_logic_vector(1 downto 0) := "00";
signal seguinte : std_logic_vector(1 downto 0);
begin
 process (clk, reset)
 begin
if(reset = '1') then
atual <= parado;
elsif(clk'event and clk = '1') then
atual <= prox;
if(prox = subindo and andar /= "11") then
andar <= andar + 1;
elsif(prox = descendo and andar /= "00") then
andar <= andar - 1;
end if;
end if;
end process;
process(andar, seguinte)
begin
case andar is
when "00" =>
if seguinte > "00" then
prox <= subindo;
else
prox <= parado;
end if;
when "01" =>
if seguinte = "00" then
prox <= descendo;
elsif( seguinte > "01") then
prox <= subindo;
else
prox <= parado;
end if;
when "10" =>
if seguinte = "00" or seguinte =
 "01" then
prox <= descendo;
elsif(seguinte = "10") then
prox <= parado;
else
prox <= subindo;
end if;
when "11" =>
if seguinte < "11" then
prox <= descendo;
else
prox <= parado;
end if;
end case;
end process;
process(atual, andar )
begin
case atual is
when parado =>
porta <= '1';
motor <= "00";
enable <= '1';
when subindo =>
porta <= '0';
motor <= "01";
enable <= '0';
when descendo =>
porta <= '0';
motor <= "10";
enable <= '0';
end case;
end process;
process (enable, seletor)
begin
if (enable = '1') then
seguinte <= seletor;
end if;
end process;
end controlador;