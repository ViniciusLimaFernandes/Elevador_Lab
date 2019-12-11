library IEEE;
use ieee.std_logic_1164.all;                                                                                                                                   
use ieee.std_logic_unsigned.all; 
                                                                                                                                                                                                                                        
entity maq1 is                                                                                                                
 port                                                                                                                                                                                                       
  ( in1 : in std_logic;                                                                                                                               
    out1 : out std_logic;                                                                                                                                                   
    clk : in std_logic                                                                                                                                                           
  );                                                                                                                                                                                                                                                                                                                                             
 end maq1;                                                                                                                        

 
 architecture arq of maq1 is                                                                                                                        
 type sm_type is (s0, s1, s2, s3);                                                                                                                                                     
 signal sm : sm_type;              
 signal sm_old: sm_type;           
 begin
 
  process (clk)
  begin
   if rising_edge (clk) then 
    case sm is
     when s0 => 
	     if in1 = '0' then 
	       sm <= s0;
       else 
	       sm <= s1;
         sm_old <= s0;
       end if;
     when s1 =>    
	     if in1 = '0' then
  	     sm <= s0;
         sm_old <= s1;
       else 
	       sm <= s2;
         sm_old <= s1;
       end if;
     when s2 => 
	     if in1 = '0' then 
	       sm <= s3;
         sm_old <= s2;
       else 
	       sm <= s2;
         sm_old <= s2;	
       end if;		 
     when s3 =>
	     if in1 = '0' then 
	       sm <= s0;
         sm_old <= s3;
       else 
	       sm <= s1;
         sm_old <= s3;	 
	     end if;
     end case;
    end if;
  end process;
  
  process (sm, sm_old, in1)   
    begin                                                                                                                                                                
     case sm is
        when s0 => out1 <= '0';                                                       
        when s1    => 
		  if sm_old = s3 then 
		    out1 <= '1';
	      else
		    out1 <= '0'; 
          end if; 
        when s2   => out1 <= '0';                                                                                                                                                                              
        when s3  => out1 <= '0';
      end case;                                                             
    end process;

  end arq;  
