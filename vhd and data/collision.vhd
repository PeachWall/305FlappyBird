library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity collision is
  port
  (
    bird_on, pipe_on, floor_on : in std_logic;
    point_area_on              : in std_logic;
    point_collided             : out std_logic;
    points                     : out std_logic_vector(9 downto 0);
    -- add powerup collisions
    collided : out std_logic
  );
end entity collision;

-- need a way to track only 1 collision each time the bird passes a pipe it has collided with

architecture beh of collision is
  signal s_point_collided : std_logic;
begin
  collided <= '1' when ((bird_on = '1' and pipe_on = '1') or (bird_on = '1' and floor_on = '1')) else
    '0';

  s_point_collided <= '1' when bird_on = '1' and point_area_on = '1' else
    '0';

  point_collided <= s_point_collided;
  process (s_point_collided)
    variable count : integer range 0 to 253 := 0;

  begin
    if (rising_edge(s_point_collided)) then
      if (count /= 253) then
        count := count + 1;
      else
        count := 0;
      end if;
    end if;

    points <= std_logic_vector(to_unsigned(count, points'length));
  end process;

end architecture;