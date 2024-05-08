library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity bird_top_entity_12 is
  port
  (
    CLOCK_50               : in std_logic;
    VGA_R, VGA_G, VGA_B    : out std_logic_vector(3 downto 0);
    h_sync_out, v_sync_out : out std_logic;
    LEDR                   : out std_logic_vector(9 downto 0);
    SW                     : in std_logic_vector(9 downto 0)
  );
end entity;

architecture beh of bird_top_entity_12 is

  component VGA_SYNC_12 is
    port
    (
      clock_25Mhz                   : in std_logic;
      red, green, blue              : in std_logic_vector (3 downto 0);
      horiz_sync_out, vert_sync_out : out std_logic;
      red_out, green_out, blue_out  : out std_logic_vector (3 downto 0);
      pixel_row, pixel_column       : out std_logic_vector(9 downto 0)
    );
  end component;

  component bird is
    port
    (
      clk                     : in std_logic;
      pixel_row, pixel_column : in std_logic_vector(9 downto 0);
      v_sync                  : in std_logic;
      rgba                    : in std_logic_vector(12 downto 0);
      rom_addr_out            : out std_logic_vector (3 downto 0);
      x_pos, y_pos            : in std_logic_vector(9 downto 0);
      red, green, blue        : out std_logic_vector(3 downto 0);
      alpha                   : out std_logic;
      sprite_row, sprite_col  : out std_logic_vector(3 downto 0)
    );
  end component;

  component bird_sprite_rom_12 is
    port
    (
      row, col     : in std_logic_vector(3 downto 0);
      clock        : in std_logic;
      pixel_output : out std_logic_vector(12 downto 0)
    );
  end component;

  component clock_divider is
    port
    (
      Clk_in  : in std_logic;
      divider : in integer;
      clk_out : out std_logic := '0'
    );
  end component;

  component background is
    port
    (
      red, green, blue : out std_logic_vector(3 downto 0)
    );
  end component;

  component pipes is
    port
    (
      v_sync                       : in std_logic;
      pixel_row, pixel_column      : in std_logic_vector(9 downto 0);
      red_out, green_out, blue_out : out std_logic_vector(3 downto 0);
      pipe_on                      : out std_logic
    );
  end component;

  component display_controller is
    port
    (
      bg_r, bg_g, bg_b       : in std_logic_vector(3 downto 0);
      bird_r, bird_g, bird_b : in std_logic_vector(3 downto 0);
      bird_a                 : std_logic;
      pipe_r, pipe_g, pipe_b : in std_logic_vector(3 downto 0); -- to be added when we have pipe
      pipe_on                : std_logic;
      r_out, g_out, b_out    : out std_logic_vector(3 downto 0)
    );
  end component;

  signal CLOCK_25, s_v_sync : std_logic;

  signal s_pixel_row            : std_logic_vector(9 downto 0);
  signal s_pixel_column         : std_logic_vector(9 downto 0);
  signal s_red, s_green, s_blue : std_logic_vector(3 downto 0);
  signal s_alpha                : std_logic;

  signal bg_red, bg_green, bg_blue            : std_logic_vector(3 downto 0);
  signal M                                    : std_logic_vector(15 downto 0);
  signal rom_addr, s_sprite_row, s_sprite_col : std_logic_vector(3 downto 0);
  signal s_rgba                               : std_logic_vector(12 downto 0);

  signal pipes_red, pipes_green, pipes_blue : std_logic_vector(3 downto 0);
  signal s_pipe_on                          : std_logic;

  signal s_red_out, s_green_out, s_blue_out : std_logic_vector(3 downto 0);
begin

  CLOCK_25mhz : Clock_Divider
  port map
  (
    Clk_in  => CLOCK_50,
    divider => 1,
    clk_out => CLOCK_25
  );

  s_rom : bird_sprite_rom_12
  port
  map(
  row          => s_sprite_row,
  col          => s_sprite_col,
  clock        => CLOCK_25,
  pixel_output => s_rgba
  );

  c : bird
  port
  map(
  clk          => CLOCK_25,
  pixel_row    => s_pixel_row,
  pixel_column => s_pixel_column,
  v_sync       => s_v_sync,
  rgba         => s_rgba,
  rom_addr_out => rom_addr,
  x_pos        => CONV_STD_LOGIC_VECTOR(150, 10),
  y_pos        => CONV_STD_LOGIC_VECTOR(150, 10),
  red          => s_red,
  green        => s_green,
  blue         => s_blue,
  alpha        => s_alpha,
  sprite_row   => s_sprite_row,
  sprite_col   => s_sprite_col
  );

  BG : background
  port
  map(
  red   => bg_red,
  green => bg_green,
  blue  => bg_blue
  );

  MY_PIPES : pipes
  port
  map(
  v_sync       => s_v_sync,
  pixel_row    => s_pixel_row,
  pixel_column => s_pixel_column,
  red_out      => pipes_red,
  green_out    => pipes_green,
  blue_out     => pipes_blue,
  pipe_on      => s_pipe_on
  );

  DISPLAY : display_controller
  port
  map(
  bg_r    => bg_red,
  bg_g    => bg_green,
  bg_b    => bg_blue,
  bird_r  => s_red,
  bird_g  => s_green,
  bird_b  => s_blue,
  bird_a  => s_alpha,
  pipe_r  => pipes_red,
  pipe_g  => pipes_green,
  pipe_b  => pipes_blue,
  pipe_on => s_pipe_on,
  r_out   => s_red_out,
  g_out   => s_green_out,
  b_out   => s_blue_out
  );

  VGA : VGA_SYNC_12
  port
  map
  (
  clock_25Mhz    => CLOCK_25,
  red            => s_red_out,
  green          => s_green_out,
  blue           => s_blue_out,
  red_out        => VGA_R,
  green_out      => VGA_G,
  blue_out       => VGA_B,
  horiz_sync_out => h_sync_out,
  vert_sync_out  => s_v_sync,
  pixel_row      => s_pixel_row,
  pixel_column   => s_pixel_column
  );

  v_sync_out <= s_v_sync;
  LEDR       <= SW;

end beh; -- beh