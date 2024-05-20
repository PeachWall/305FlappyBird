library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
package util is
  -- STATE MACHINE DECLERATIONS
  type player_states is (NORMAL, DEAD, PAUSED, INVINCIBLE, FAST, SLOW, BIG, SMALL);
  type pipe_states is (FAST, SLOW);
  type game_states is (MENU, TRAINING, EASY, MEDIUM, HARD, FINISH);
  type ability_types is(MONEY, LIFE, BIG, SMALL);

  -- SCALING FACTOR FOR GAME EXCEPT FOR BIRD
  constant scale         : integer := 2;
  constant screen_height : integer := 479;
  constant screen_width  : integer := 639;
  constant half_height   : integer := 239;
end package;

package body util is
end package body;