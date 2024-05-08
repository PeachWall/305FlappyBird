library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity collision is
  port
  (
    bird_on, pipe_on : in std_logic;
    pipe_collided    : out std_logic
  );
end entity collision;

architecture rtl of collision is
begin
  pipe_collided <= '1' when (bird_on = '1' and pipe_on = '1') else
    '0';

end architecture;