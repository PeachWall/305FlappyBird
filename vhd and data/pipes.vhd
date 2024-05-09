library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

entity pipes is
  port
  (
    clk                          : in std_logic;
    v_sync                       : in std_logic;
    pixel_row, pixel_column      : in std_logic_vector(9 downto 0);
    red_out, green_out, blue_out : out std_logic_vector(3 downto 0);
    pipe_on                      : out std_logic
  );
end entity pipes;

architecture rtl of pipes is
  component random_gen is
    port
    (
      clk, reset, enable : in std_logic;
      Q                  : out ieee.numeric_std.signed(7 downto 0)
    );
  end component;
  constant screen_height : integer := 479;
  constant screen_width  : integer := 639;
  constant half_width    : integer := 239;
  constant gap_size      : integer := 64;
  constant x_speed       : integer := 1;
  constant distance      : integer := 319;

  constant scale : integer                               := 2;
  constant size  : ieee.numeric_std.unsigned(7 downto 0) := shift_left("00010000", scale - 1); -- 16 * 2^(scale - 1)

  -- Top and Bottom pipes
  signal pipe1_top_on, pipe1_bottom_on : std_logic;
  signal pipe2_top_on, pipe2_bottom_on : std_logic;

  -- x and y position for pipes
  signal pipe1_y_pos, pipe2_y_pos : integer range 120 to 360 := 360;

  signal pipe1_x_pos : std_logic_vector(10 downto 0) := conv_std_logic_vector(screen_width, 11);
  signal pipe2_x_pos : std_logic_vector(10 downto 0) := conv_std_logic_vector(screen_width + distance, 11);

  signal s_pipe_on : std_logic;

  signal random_num : ieee.numeric_std.signed(7 downto 0);
begin

  -- Output either top or bottom pipe is being drawn
  s_pipe_on <= pipe1_bottom_on or pipe1_top_on or pipe2_bottom_on or pipe2_top_on;
  pipe_on   <= s_pipe_on;

  -- Pipe1 : TOP AND BOTTOM
  pipe1_top_on <= '1' when ('0' & pixel_column >= pipe1_x_pos) and ('0' & pixel_column < pipe1_x_pos + to_integer(size))
    and (pixel_row >= 0) and (pixel_row < pipe1_y_pos - gap_size) else
    '0';

  pipe1_bottom_on <= '1' when ('0' & pixel_column >= pipe1_x_pos) and ('0' & pixel_column < pipe1_x_pos + to_integer(size))
    and (pixel_row  <= screen_height) and (pixel_row > pipe1_y_pos + gap_size) else
    '0';

  -- Pipe2 : TOP AND BOTTOM
  pipe2_top_on <= '1' when ('0' & pixel_column >= pipe2_x_pos) and ('0' & pixel_column < pipe2_x_pos + to_integer(size))
    and (pixel_row >= 0) and (pixel_row < pipe2_y_pos - gap_size) else
    '0';

  pipe2_bottom_on <= '1' when ('0' & pixel_column >= pipe2_x_pos) and ('0' & pixel_column < pipe2_x_pos + to_integer(size))
    and (pixel_row  <= screen_height) and (pixel_row > pipe2_y_pos + gap_size) else
    '0';

  red_out   <= (others => s_pipe_on);
  green_out <= (others => '0');
  blue_out  <= (others => s_pipe_on);

  PER_FRAME : process (v_sync)

  begin
    if (rising_edge(v_sync)) then
      pipe1_x_pos <= pipe1_x_pos - x_speed;
      pipe2_x_pos <= pipe2_x_pos - x_speed;

      if (pipe1_x_pos =- to_integer(size) * scale) then
        pipe1_y_pos <= to_integer(random_num) + half_width;
        pipe1_x_pos <= conv_std_logic_vector(screen_width, 11);
      end if;

      if (pipe2_x_pos =- to_integer(size) * scale) then
        pipe2_y_pos <= to_integer(random_num + half_width;
        pipe2_x_pos <= conv_std_logic_vector(screen_width, 11);
      end if;
    end if;
  end process;

  RNG : random_gen
  port map
  (
    clk    => clk,
    reset  => '0',
    enable => '1',
    Q      => random_num
  );
end architecture;