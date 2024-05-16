library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
package util is
  type player_state is (NORMAL, DEAD, PAUSED, INVINCIBLE, FAST, SLOW, BIG, SMALL);
  function player_state_to_std_logic_vector(signal state : in player_state) return std_logic_vector;
  function std_logic_vector_to_player_state(signal vec   : in std_logic_vector(2 downto 0)) return player_state;
end package;

package body util is
  function player_state_to_std_logic_vector(signal state : in player_state) return std_logic_vector is
  begin
    case state is
      when NORMAL     => return "000";
      when DEAD       => return "001";
      when PAUSED     => return "010";
      when INVINCIBLE => return "011";
      when FAST       => return "100";
      when SLOW       => return "101";
      when BIG        => return "110";
      when SMALL      => return "111";
    end case;
  end function;

  function std_logic_vector_to_player_state(signal vec : in std_logic_vector(2 downto 0)) return player_state is
  begin
    case vec is
      when "000" => return NORMAL;
      when "001" => return DEAD;
      when "010" => return PAUSED;
      when "011" => return INVINCIBLE;
      when "100" => return FAST;
      when "101" => return SLOW;
      when "110" => return BIG;
      when "111" => return SMALL;
    end case;
  end function;
end package body;