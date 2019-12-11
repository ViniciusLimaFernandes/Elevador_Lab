
-- Libraries
LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;

--  Entity Declaration - Testbench
ENTITY tb_maq1 IS
END tb_maq1;

--  Architecture Body
ARCHITECTURE arq OF tb_maq1 IS

 
 
 
COMPONENT maq1
    port(
      in1 : in std_logic;                                                                                                                               
      out1 : out std_logic;                                                                                                                                                   
      clk : in std_logic                                                                                                                                                           
    );        
end component; 

 

 -- signals
 signal in1           : std_logic := '0';
 signal out1          : std_logic := '0';
 signal clk           : std_logic := '0'; 
 signal bitvector     : std_logic_vector(15 downto 0) := (others => '0');
 
--------------------------------------------------------------------------------
-- TestBench Architecture
--------------------------------------------------------------------------------
BEGIN
 
inst_maq1 : maq1
    Port map (      
      in1   => in1,
      out1   => out1,
      clk   => clk
    );             


ClockGenProc:
 PROCESS
  BEGIN
   clk <= '0';
   WAIT FOR 10ns;
   clk <= '1';
   WAIT FOR 10ns;
 END PROCESS;
 
BitGenProc:
 PROCESS
  BEGIN
    bitvector <= "0101010010110101";
    for i in 0 to bitvector'length-1 loop
      in1 <= bitvector(i);
      wait until rising_edge(clk); 
    end loop;
    wait;    
 END PROCESS;
  



END arq;
-- End of file








