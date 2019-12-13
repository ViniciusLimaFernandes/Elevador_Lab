LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

 ENTITY aula13 IS
   Port (
      SW          : in   std_logic_vector(4 downto 0);
      LEDR        : out  std_logic_vector(0 downto 0)
   );
 END ENTITY;

ARCHITECTURE arq OF aula13 IS

-- Signals
signal A : std_logic := '0';
signal B : std_logic := '0';
signal C : std_logic := '0';
signal SEL : std_logic_vector(1 downto 0) := "00";
signal S : std_logic := '0';

 BEGIN
 
 A <= SW(0);
 B <= SW(1);
 C <= SW(2);
 SEL <= SW(4 downto 3);
 LEDR(0) <= S;
 
proc_main:
 process(A,B,C,SEL)
  BEGIN
   case SEL is
     when "00"=>
       S <= SW(0);
	 when "01"=>
       S <= SW(1);
	 when "10"=>
       S <= SW(2);
	 when others =>
       S <= '0';
	end case;
 end process;

END ARCHITECTURE arq;










