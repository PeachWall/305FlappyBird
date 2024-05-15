library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity display_controller is
  port
  (
    bg_r, bg_g, bg_b          : in std_logic_vector(3 downto 0);
    bird_r, bird_g, bird_b    : in std_logic_vector(3 downto 0);
    bird_a                    : std_logic;
    pipe_r, pipe_g, pipe_b    : in std_logic_vector(3 downto 0); -- to be added when we have pipe
    pipe_on                   : std_logic;
    floor_r, floor_g, floor_b : in std_logic_vector(3 downto 0); -- floor
    floor_on                  : std_logic;
    score_r, score_g, score_b : in std_logic_vector(3 downto 0);
    score_on                  : std_logic;
    cloud_r, cloud_g, cloud_b : in std_logic_vector(3 downto 0);
    cloud_on                  : std_logic;
    r_out, g_out, b_out       : out std_logic_vector(3 downto 0)
  );
end entity display_controller;

architecture beh of display_controller is

  function get_color(c_Bird, c_pipes, c_bg, c_floor, c_score, c_cloud : std_logic_vector(3 downto 0);
    s_bird, s_pipes, s_floor, s_score, s_cloud                          : std_logic) return std_logic_vector is
  begin
    if (s_score = '1') then
      return c_score;
    elsif (s_bird = '1') then
      return c_Bird;
    elsif (s_floor = '1') then
      return c_floor;
    elsif (s_pipes = '1') then
      return c_pipes;
    elsif (s_cloud = '1') then
      return c_cloud;
    else
      return c_bg;
    end if;
  end function;
begin
  -- r_out <= bird_r when bird_a = '1' else
  --   pipe_r when pipe_on = '1' else
  --   bg_r;

  -- g_out <= bird_r when bird_a = '1' else
  --   pipe_r when pipe_on = '1' else
  --   bg_r;

  -- b_out <= bird_r when bird_a = '1' else
  --   pipe_r when pipe_on = '1' else
  --   bg_r;

  r_out <= get_color(bird_r, pipe_r, bg_r, floor_r, score_r, cloud_r, bird_a, pipe_on, floor_on, score_on, cloud_on);
  g_out <= get_color(bird_g, pipe_g, bg_g, floor_g, score_g, cloud_g, bird_a, pipe_on, floor_on, score_on, cloud_on);
  b_out <= get_color(bird_b, pipe_b, bg_b, floor_b, score_b, cloud_b, bird_a, pipe_on, floor_on, score_on, cloud_on);
end architecture;