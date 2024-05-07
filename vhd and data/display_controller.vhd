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
    -- pipe_r, pipe_g, pipe_b : in std_logic_vector(3 downto 0); -- to be added when we have pipe
    r_out, g_out, b_out : out std_logic_vector(3 downto 0)
  );
end entity display_controller;

architecture beh of display_controller is

begin
  r_out <= bg_r when bird_a = '0' else
    bird_r;

  g_out <= bg_g when bird_a = '0' else
    bird_g;

  b_out <= bg_b when bird_a = '0' else
    bird_b;
end architecture;