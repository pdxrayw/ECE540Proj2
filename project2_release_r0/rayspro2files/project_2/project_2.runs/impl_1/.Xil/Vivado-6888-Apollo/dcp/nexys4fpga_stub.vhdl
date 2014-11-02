-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nexys4fpga is
  Port ( 
    clk : in STD_LOGIC;
    btnL : in STD_LOGIC;
    btnR : in STD_LOGIC;
    btnU : in STD_LOGIC;
    btnD : in STD_LOGIC;
    btnC : in STD_LOGIC;
    btnCpuReset : in STD_LOGIC;
    sw : in STD_LOGIC_VECTOR ( 15 downto 0 );
    led : out STD_LOGIC_VECTOR ( 15 downto 0 );
    seg : out STD_LOGIC_VECTOR ( 6 downto 0 );
    dp : out STD_LOGIC;
    an : out STD_LOGIC_VECTOR ( 7 downto 0 );
    JA : out STD_LOGIC_VECTOR ( 7 downto 0 );
    Hsync : out STD_LOGIC;
    Vsync : out STD_LOGIC;
    vgaRed : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vgaGreen : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vgaBlue : out STD_LOGIC_VECTOR ( 3 downto 0 )
  );

end nexys4fpga;

architecture stub of nexys4fpga is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
begin
end;
