library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity background is
  port
  (
    bg_rgb_out : out std_logic_vector(11 downto 0)
  );
end entity background;

architecture beh of background is
  signal red, green, blue : std_logic_vector(3 downto 0);
begin
  red   <= "0111";
  green <= "1111";
  blue  <= "1111";

  bg_rgb_out <= red & green & blue;
end architecture;