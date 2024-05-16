library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity abilities is
  port
  (
    pipe_passed                  : in std_logic;
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    pipe1_x_in                  : in std_logic_vector(10 downto 0);
    ability1_type                : out std_logic_vector(2 downto 0);
    r,g,b                       : out std_logic_vector(3 downto 0);
    ability1_on                  : out std_logic
  );
end entity abilities;

architecture beh of abilities is
SIGNAL ability_width : integer := 16;
SIGNAL ability1_x_pos : std_logic_vector(10 downto 0);
SIGNAL ability1_y_pos : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(200, 11));

begin
  ability1_x_pos <= std_logic_vector(to_unsigned(to_integer(unsigned(pipe1_x_in)) - 100, 11));

  ability1_on <= '1' when  ((pixel_row >= ability1_y_pos and pixel_row < ability1_y_pos + ability_width) and (pixel_column >= ability1_x_pos and pixel_column <= ability1_x_pos + ability_width)) else 
  '0';
  
  r <= "0000";
  g <= "0000";
  b <= "0000";
end architecture;