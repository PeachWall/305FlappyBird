library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.util.all;

entity speed_controller is
  port
  (
    switches    : in std_logic_vector(9 downto 0);
    game_state  : in std_logic_vector(2 downto 0);
    speed_state : in std_logic_vector(2 downto 0);
    speed_out   : out std_logic_vector(2 downto 0)
  );
end entity speed_controller;

architecture rtl of speed_controller is
  signal cur_game_state  : game_states;
  signal cur_speed_state : speed_states;
begin

  cur_game_state  <= game_states'val(to_integer(unsigned(game_state)));
  cur_speed_state <= speed_states'val(to_integer(unsigned(speed_state)));

  speed_out <=
    "000" when (cur_game_state = PAUSED or cur_game_state = COLLIDE) else
    "010" when cur_speed_state = NORMAL else
    "110" when cur_speed_state = FAST else
    "001" when cur_speed_state = SLOW else
    "010";

end architecture;