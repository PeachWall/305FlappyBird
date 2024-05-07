library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity background is
  port
  (
    red, green, blue : out std_logic_vector(3 downto 0)

  );
end entity background;

architecture beh of background is
begin
  red   <= "0111";
  green <= "1111";
  blue  <= "1111";
end architecture;