library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.util.all;

entity display_controller is
  port
  (
    bg_rgb                       : in std_logic_vector(11 downto 0);
    bird_rgb                     : in std_logic_vector(11 downto 0);
    bird_on                      : in std_logic;
    pipe_rgb                     : in std_logic_vector(11 downto 0);
    pipe_on                      : in std_logic;
    floor_rgb                    : in std_logic_vector(11 downto 0);
    floor_on                     : in std_logic;
    text_rgb                     : in std_logic_vector(11 downto 0);
    text_on                      : in std_logic;
    cloud_rgb                    : in std_logic_vector(11 downto 0);
    cloud_on                     : in std_logic;
    ability_rgb                  : in std_logic_vector(11 downto 0);
    ability_on                   : in std_logic;
    menu_rgb                     : in std_logic_vector(11 downto 0);
    menu_on                      : in std_logic;
    difficulty                   : in std_logic_vector(2 downto 0);
    red_out, green_out, blue_out : out std_logic_vector(3 downto 0)
  );
end entity display_controller;

architecture beh of display_controller is
  signal rgb            : std_logic_vector(11 downto 0);
  signal cur_game_state : game_states;
begin

  rgb <=
    text_rgb when text_on = '1' else
    menu_rgb when menu_on = '1' else
    bird_rgb when bird_on = '1' else
    floor_rgb when floor_on = '1' else
    pipe_rgb when pipe_on = '1' else
    ability_rgb when ability_on = '1' else
    cloud_rgb when cloud_on = '1' else
    bg_rgb;

  red_out <= rgb(7 downto 4) when difficulty = "100" and rgb = pipe_rgb else
    rgb(11 downto 8);
  green_out <= rgb(11 downto 8) when difficulty = "100" and rgb = pipe_rgb else
    rgb(7 downto 4);
  blue_out <= rgb(3 downto 0);
end architecture;