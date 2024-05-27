library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
package util is
  -- STATE MACHINE DECLERATIONS
  type player_states is (NORMAL, BIG, SMALL);
  type speed_states is (NORMAL, FAST, SLOW);
  type game_states is (MENU, PLAY, COLLIDE, PAUSED, FINISH);
  type ability_types is(MONEY, LIFE, BIG, SMALL, FAST, SLOW, BOMB);

  -- SCALING FACTOR FOR GAME EXCEPT FOR BIRD
  constant scale         : integer := 2;
  constant screen_height : integer := 479;
  constant screen_width  : integer := 639;
  constant half_height   : integer := 239;
end package;

package body util is
end package body;