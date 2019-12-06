LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Exp04 IS
	PORT(	reset				: IN STD_LOGIC;
			clock48MHz		: IN STD_LOGIC;
			LCD_RS, LCD_E	: OUT	STD_LOGIC;
			LCD_RW, LCD_ON	: OUT STD_LOGIC;
			DATA				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			clockPB			: IN STD_LOGIC;
-- DESCOMENTE PARA SIMULAR (use o botão)
-- COMENTE PARA FAZER UPLOAD PARA A PLACA
			DisplayDataOut	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUResultOut	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ReadDataOut		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			PCAddrOut		: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			SignExtendOut	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			readData1Out	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			readData2Out	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUSrcOut		: OUT STD_LOGIC;
			MemToRegOut		: OUT STD_LOGIC;
			MemReadOut		: OUT STD_LOGIC;
			MemWriteOut	 	: OUT STD_LOGIC;
-- Mantenha o sinal abaixo sem comentar
			InstrALU			: IN STD_LOGIC);
END Exp04;

ARCHITECTURE exec OF Exp04 IS
COMPONENT LCD_Display
	GENERIC(NumHexDig: Integer:= 11);
	PORT(	reset, clk_48Mhz	: IN	STD_LOGIC;
			HexDisplayData		: IN  STD_LOGIC_VECTOR((NumHexDig*4)-1 DOWNTO 0);
			LCD_RS, LCD_E		: OUT	STD_LOGIC;
			LCD_RW				: OUT STD_LOGIC;
			DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

COMPONENT Ifetch
	PORT(	reset			: in STD_LOGIC;
			clock			: in STD_LOGIC;
			PC_out		: out STD_LOGIC_VECTOR(9 DOWNTO 0);
			Instruction	: out STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;

COMPONENT Control
	PORT( Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			RegDst 		: OUT STD_LOGIC;
			RegWrite 	: OUT STD_LOGIC;
			ALUSrc		: OUT STD_LOGIC;
			MemToReg		: OUT STD_LOGIC;
			MemRead		: OUT STD_LOGIC;
			MemWrite		: OUT STD_LOGIC);
END COMPONENT;

COMPONENT Idecode
	PORT(		read_data_1	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ReadData		: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				RegWrite 	: IN 	STD_LOGIC;
				RegDst 		: IN 	STD_LOGIC;
				MemToReg		: IN	STD_LOGIC;
				Sign_extend : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				clock,reset	: IN 	STD_LOGIC );
END COMPONENT;

COMPONENT Execute
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALUSrc			: IN  STD_LOGIC;
			SignExtend		: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END COMPONENT;

COMPONENT Dmemory
	PORT(	read_data 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 				: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   	MemRead, Memwrite	: IN 	STD_LOGIC;
         clock,reset			: IN 	STD_LOGIC );
END COMPONENT;

SIGNAL DataInstr 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL RegDst		: STD_LOGIC;
SIGNAL RegWrite	: STD_LOGIC;
SIGNAL clock		: STD_LOGIC;
SIGNAL DisplayData: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL PCAddr		: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL ALUResult	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SignExtend	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL readData1	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL readData2	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ALUSrc		: STD_LOGIC;
SIGNAL MemToReg	: STD_LOGIC;
SIGNAL MemRead 	: STD_LOGIC;
SIGNAL MemWrite 	: STD_LOGIC;
SIGNAL ReadData	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL HexDisplayData : STD_LOGIC_VECTOR(43 DOWNTO 0);

BEGIN
	LCD_ON <= '1';
	
	DisplayData <= DataInstr WHEN InstrALU='0' ELSE
						ALUResult WHEN MemToReg='0' ELSE
						ReadData;
	clock <= NOT clockPB;				
	HexDisplayData <= "00" & PCAddr & DisplayData;
	
	lcd: LCD_Display
	PORT MAP(
		reset				=> reset,
		clk_48Mhz		=> clock48MHz,
		HexDisplayData	=> HexDisplayData,
		LCD_RS			=> LCD_RS,
		LCD_E				=> LCD_E,
		LCD_RW			=> LCD_RW,
		DATA_BUS			=> DATA);
	
	IFT: Ifetch
	PORT MAP(
		reset			=> reset,
		clock 		=> clock,
		PC_out		=> PCAddr,
		Instruction	=> DataInstr);

	CTR: Control
	PORT MAP(
		Opcode 	=>	DataInstr(31 DOWNTO 26),
		RegDst 	=> RegDst,
		RegWrite => RegWrite,
		ALUSrc	=> ALUSrc,
		MemToReg	=> MemToReg,
		MemRead	=> MemRead,
		MemWrite	=> MemWrite);

	IDEC: Idecode
	PORT MAP(
		read_data_1	=> readData1,
		read_data_2	=> readData2,
		Instruction => DataInstr,
		ALU_result	=> ALUResult,
		ReadData		=> ReadData,
		RegWrite 	=> RegWrite,
		RegDst 		=> RegDst,
		MemToReg		=> MemToReg,
		Sign_extend => SignExtend,
		clock			=> clock,
		reset			=> reset);

	EXE: Execute
	PORT MAP(
		Read_data_1	=> readData1,
		Read_data_2 => readData2,
		ALU_Result 	=>	ALUResult,
		ALUSrc		=> ALUSrc,
		SignExtend	=> SignExtend);

	DMEM: DMemory
	PORT MAP (	
		read_data 	=> ReadData,
      address 		=> ALUResult(7 DOWNTO 0),
      write_data 	=> ReadData2,
	   MemRead		=> MemRead, 
		Memwrite		=> MemWrite,
      clock			=> clock,
		reset			=> reset);
		
-- DESCOMENTE OS SINAIS ABAIXO PARA SIMULAR (use o botão)
-- COMENTE PARA FAZER UPLOAD PARA A PLACA
	DisplayDataOut <= DisplayData;
	ALUResultOut <= ALUResult;
	ReadDataOut <= ReadData;
	PCAddrOut <= PCAddr;
	SignExtendOut <= SignExtend;
	readData1Out <= readData1;
	readData2Out <= readData2;
	ALUSrcOut <= ALUSrc;
	MemToRegOut <= MemToReg;
	MemReadOut <= MemRead;
	MemWriteOut <= MemWrite;
END exec;