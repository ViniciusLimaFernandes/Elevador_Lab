--  Idecode module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE IEEE.NUMERIC_STD.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ReadData		: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				RegWrite 	: IN 	STD_LOGIC;
				RegDst 		: IN 	STD_LOGIC;
				MemToReg		: IN	STD_LOGIC;
				Sign_extend : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				clock,reset	: IN 	STD_LOGIC );
END Idecode;

ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array	: register_file;
	SIGNAL write_reg_ID 		: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL write_data			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_Rs_ID			: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL read_Rt_ID			: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL write_Rd_ID		: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL write_Rt_ID		: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL Immediate_value	: STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
	read_Rs_ID 	<= Instruction(25 DOWNTO 21);
   read_Rt_ID 	<= Instruction(20 DOWNTO 16);
   write_Rd_ID	<= Instruction(15 DOWNTO 11);
   write_Rt_ID	<= Instruction(20 DOWNTO 16);
   Immediate_value <= Instruction(15 DOWNTO 0);
	
	-- Read Register 1 Operation
	read_data_1 <= register_array(CONV_INTEGER(read_Rs_ID));
	--read_data_1 <= register_array(TO_INTEGER(UNSIGNED(read_Rs_ID)));
	-- Read Register 2 Operation		 
	read_data_2 <= register_array(CONV_INTEGER(read_Rt_ID));
	--read_data_2 <= register_array(TO_INTEGER(UNSIGNED(read_Rt_ID)));
	
	-- Mux for Register Write Address
   write_reg_ID <= write_Rd_ID WHEN RegDst = '1'
						ELSE write_Rt_ID;
	
	-- Mux to bypass data memory for Rformat instructions
	write_data <= ALU_result WHEN MemToReg='0' ELSE
						ReadData;

	-- Sign Extend 16-bits to 32-bits
   Sign_extend <= X"0000" & Immediate_value
		WHEN Immediate_value(15) = '0'
		ELSE	X"FFFF" & Immediate_value;

PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		IF reset = '1' THEN
			-- Initial register values on reset are register = reg#
			-- use loop to automatically generate reset logic 
			-- for all registers
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
				--register_array(i) <= STD_LOGIC_VECTOR(TO_SIGNED( i, 32 ));
 			END LOOP;
		-- Write back to register - don't write to register 0
  		ELSIF RegWrite = '1' AND write_reg_ID /= "00000" THEN
		      register_array( CONV_INTEGER( write_reg_ID)) <= write_data;
				--register_array( TO_INTEGER(UNSIGNED( write_reg_ID))) <= write_data;
		END IF;
	END PROCESS;
END behavior;


