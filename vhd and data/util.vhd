library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
package util is
  -- STATE MACHINE DECLERATIONS
  type player_state is (NORMAL, DEAD, PAUSED, INVINCIBLE, FAST, SLOW, BIG, SMALL);
  type pipe_state is (FAST, SLOW);
  type game_state is (MENU, TRAINING, EASY, MEDIUM, HARD, FINISH);

  -- SCALING FACTOR FOR GAME EXCEPT FOR BIRD
  constant scale : integer := 2;
end package;

package body util is
end package body;