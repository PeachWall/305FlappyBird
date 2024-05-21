library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.util.all;

entity collision is
  port
  (
    clk                                    : in std_logic;
    bird_on, pipe_on, floor_on, ability_on : in std_logic;
    point_box_on                           : in std_logic;
    -- add powerup collisions
    collided           : out std_logic;
    ability_collided   : out std_logic;
    point_box_collided : out std_logic
  );
end entity collision;

-- need a way to track only 1 collision each time the bird passes a pipe it has collided with

architecture beh of collision is
begin

  process (clk)
  begin
    if (rising_edge(clk)) then
      if ((bird_on = '1' and pipe_on = '1') or (bird_on = '1' and floor_on = '1')) then
        collided <= '1';
      elsif (bird_on = '1' and point_box_on = '1') then
        point_box_collided <= '1';
      elsif (bird_on = '1' and ability_on = '1') then
        ability_collided <= '1';
      else
        collided           <= '0';
        ability_collided   <= '0';
        point_box_collided <= '0';
      end if;
    end if;
  end process;
end architecture;