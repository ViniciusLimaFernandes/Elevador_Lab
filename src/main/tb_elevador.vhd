library ieee;
use ieee.std_logic_1164.all;

entity tb_elevador is
end tb_elevador;

architecture tb of tb_elevador is

    component elevador
        port (SW   : in std_logic_vector (17 downto 0);
              KEY  : in std_logic_vector (2 downto 0);
              LEDR : out std_logic_vector (17 downto 0);
              LEDG : out std_logic_vector (0 downto 0));
    end component;

    signal SW   : std_logic_vector (17 downto 0);
    signal KEY  : std_logic_vector (2 downto 0);
    signal LEDR : std_logic_vector (17 downto 0);
    signal LEDG : std_logic_vector (0 downto 0);

    constant TbPeriod : time := 1000 ns; 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : elevador
    port map (SW   => SW,
              KEY  => KEY,
              LEDR => LEDR,
              LEDG => LEDG);

    -- Gerador de clock
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';


    stimuli : process
    begin
        SW <= (others => '0');
        KEY <= (others => '0');

        wait for 100 * TbPeriod;

        -- Para o clock quando terminar a simulação
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

configuration cfg_tb_elevador of tb_elevador is
    for tb
    end for;
end cfg_tb_elevador;