library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

entity pipes is
  port
  (
    v_sync                       : in std_logic;
    pixel_row, pixel_column      : in std_logic_vector(9 downto 0);
    red_out, green_out, blue_out : out std_logic_vector(3 downto 0);
    pipe_on                      : out std_logic
  );
end entity pipes;

architecture rtl of pipes is
  constant screen_height : integer := 479;
  constant screen_width  : integer := 639;
  constant size          : integer := 16;
  constant gap_size      : integer := 32;
  constant scale         : integer := 1;

  -- Top and Bottom pipes
  signal pipe1_top_on, pipe1_bottom_on : std_logic;
  signal pipe2_top_on, pipe2_bottom_on : std_logic;

  -- x and y position for pipes
  signal pipe1_y_pos, pipe2_y_pos : std_logic_vector(9 downto 0) := conv_std_logic_vector(200, 10);
  signal pipe1_x_pos, pipe2_x_pos : std_logic_vector(9 downto 0) := conv_std_logic_vector(480, 10);
begin

  -- Output either top or bottom pipe is being drawn
  pipe_on <= pipe1_bottom_on or pipe1_top_on or pipe2_bottom_on or pipe2_top_on;

  -- Pipe1 : TOP AND BOTTOM
  pipe1_top_on <= '1' when (pixel_column >= pipe1_x_pos) and (pixel_column < pipe1_x_pos + size)
    and (pixel_row >= 0) and (pixel_row < pipe1_y_pos - gap_size);

  pipe1_bottom_on <= '1' when (pixel_column >= pipe1_x_pos) and (pixel_column < pipe1_x_pos + size)
    and (pixel_row >= pipe1_y_pos + gap_size) and (pixel_row < screen_height);

  -- Pipe2 : TOP AND BOTTOM
  pipe2_top_on <= '1' when (pixel_column >= pipe2_x_pos) and (pixel_column < pipe2_x_pos + size)
    and (pixel_row >= 0) and (pixel_row < pipe2_y_pos - gap_size);

  pipe2_bottom_on <= '1' when (pixel_column >= pipe2_x_pos) and (pixel_column < pipe2_x_pos + size)
    and (pixel_row >= pipe2_y_pos + gap_size) and (pixel_row < screen_height);

  red_out   <= (others => pipe_on);
  green_out <= (others => '0');
  blue_out  <= (others => pipe_on);
end architecture;