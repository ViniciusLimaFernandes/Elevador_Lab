--  Execute module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALUSrc			: IN  STD_LOGIC;
			SignExtend		: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL BImput	: STD_LOGIC_VECTOR(31 DOWNTO 0 );
BEGIN
	BImput <= Read_data_2 WHEN ALUSrc = '0' ELSE
					SignExtend;
					
	ALU_Result <= Read_data_1 + BImput;
	
END behavior;

