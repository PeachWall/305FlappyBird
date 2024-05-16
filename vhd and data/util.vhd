library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
package util is
  type player_state is (NORMAL, DEAD, PAUSED, INVINCIBLE, FAST, SLOW, BIG, SMALL);
  constant scale : integer := 2;
end package;

package body util is
end package body;