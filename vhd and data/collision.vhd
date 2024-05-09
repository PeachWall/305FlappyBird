library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity collision is
  port
  (
    bird_on, pipe_on, floor_on : in std_logic;
    collided    : out std_logic
  );
end entity collision;

architecture rtl of collision is
begin
  collided <= '1' when ((bird_on = '1' and pipe_on = '1') or (bird_on = '1' and floor_on = '1')) else
    '0';

end architecture;