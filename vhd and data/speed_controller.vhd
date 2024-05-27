library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.util.all;

entity speed_controller is
  port
  (
    points      : in std_logic_vector(9 downto 0);
    game_state  : in std_logic_vector(2 downto 0);
    speed_state : in std_logic_vector(2 downto 0);
    difficulty  : in std_logic_vector(2 downto 0);
    speed_out   : out std_logic_vector(2 downto 0)
  );
end entity speed_controller;

architecture rtl of speed_controller is
  signal cur_game_state  : game_states;
  signal cur_speed_state : speed_states;

  signal base_speed : std_logic_vector(2 downto 0) := "010";
begin

  cur_game_state  <= game_states'val(to_integer(unsigned(game_state)));
  cur_speed_state <= speed_states'val(to_integer(unsigned(speed_state)));

  base_speed <= "010" when difficulty /= "100" and points <= 10 else
    "011";

  speed_out <=
    "000" when (cur_game_state = PAUSED or cur_game_state = COLLIDE or cur_game_state = FINISH) else
    base_speed when cur_speed_state = NORMAL else
    std_logic_vector(to_unsigned(to_integer(unsigned(base_speed)) * 2, 3)) when cur_speed_state = FAST else
    std_logic_vector(to_unsigned(to_integer(unsigned(base_speed)) / 2, 3)) when cur_speed_state = SLOW else
    "010";

end architecture;