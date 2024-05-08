library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity display_controller is
  port
  (
    bg_r, bg_g, bg_b       : in std_logic_vector(3 downto 0);
    bird_r, bird_g, bird_b : in std_logic_vector(3 downto 0);
    bird_a                 : std_logic;
    pipe_r, pipe_g, pipe_b : in std_logic_vector(3 downto 0); -- to be added when we have pipe
    pipe_on                : std_logic;
    r_out, g_out, b_out    : out std_logic_vector(3 downto 0)
  );
end entity display_controller;

architecture beh of display_controller is

  -- COLOR INPUT (C = COLOR WHETHER ITS R, G, OR B) => "XCCC" WHERE X IF IT IS ON
  function get_color(color1, color2, color3 : std_logic_vector(4 downto 0)) return std_logic_vector is
  begin
    if (color1(4) = '1') then
      return color1;
    elsif (color2(4) = '1') then
      return color2;
    else
      return color3;
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

  r_out <= get_color(bird_a & bird_r, pipe_on & pipe_r, bg_r);
  g_out <= get_color(bird_a & bird_g, pipe_on & pipe_g, bg_g);
  b_out <= get_color(bird_a & bird_b, pipe_on & pipe_b, bg_b);
end architecture;