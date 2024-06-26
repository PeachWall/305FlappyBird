library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity bird_top_entity is
  port
  (
    CLOCK_50                                             : in std_logic;
    red_out, green_out, blue_out, h_sync_out, v_sync_out : out std_logic;
    LEDR                                                 : out std_logic_vector(9 downto 0);
    SW                                                   : in std_logic_vector(9 downto 0)
  );
end entity;

architecture beh of bird_top_entity is

  component VGA_SYNC is
    port
    (
      clock_25Mhz, red, green, blue                               : in std_logic;
      red_out, green_out, blue_out, horiz_sync_out, vert_sync_out : out std_logic;
      pixel_row, pixel_column                                     : out std_logic_vector(9 downto 0)
    );
  end component;

  component bird is
    port
    (
      clk                     : in std_logic;
      pixel_row, pixel_column : in std_logic_vector(9 downto 0);
      v_sync                  : in std_logic;
      rgba                    : in std_logic_vector(3 downto 0);
      rom_addr_out            : out std_logic_vector (3 downto 0);
      x_pos, y_pos            : in std_logic_vector(9 downto 0);
      red, green, blue        : out std_logic;
      sprite_row, sprite_col  : out std_logic_vector(3 downto 0)
    );
  end component;

  component bird_sprite_rom is
    port
    (
      row, col     : in std_logic_vector(3 downto 0);
      clock        : in std_logic;
      pixel_output : out std_logic_vector(3 downto 0)
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

  component pipes is
    port
    (
      v_sync                       : in std_logic;
      pixel_row, pixel_column      : in std_logic_vector(9 downto 0);
      red_out, green_out, blue_out : out std_logic_vector(3 downto 0)
    );
  end component;

  signal CLOCK_25                                     : std_logic;
  signal s_pixel_row                                  : std_logic_vector(9 downto 0);
  signal s_pixel_column                               : std_logic_vector(9 downto 0);
  signal s_v_sync, s_red, s_green, s_blue             : std_logic;
  signal pipes_red, pipes_green, pipes_blue           : std_logic_vector(3 downto 0);
  signal M                                            : std_logic_vector(15 downto 0);
  signal rom_addr, s_rgba, s_sprite_row, s_sprite_col : std_logic_vector(3 downto 0);
begin

  CLOCK_25mhz : Clock_Divider
  port map
  (
    Clk_in  => CLOCK_50,
    divider => 1,
    clk_out => CLOCK_25
  );

  s_rom : bird_sprite_rom
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
  x_pos        => CONV_STD_LOGIC_VECTOR(319, 10),
  y_pos        => CONV_STD_LOGIC_VECTOR(239, 10),
  red          => s_red,
  green        => s_green,
  blue         => s_blue,
  sprite_row   => s_sprite_row,
  sprite_col   => s_sprite_col
  );

  MY_PIPES : pipes
  port
  map(
  v_sync       => s_v_sync,
  pixel_row    => s_pixel_row,
  pixel_column => s_pixel_column,
  red_out      => pipes_red,
  green_out    => pipes_green,
  blue_out     => pipes_blue
  );

  VGA : VGA_SYNC
  port
  map
  (
  clock_25Mhz    => CLOCK_25,
  red            => s_red,
  green          => s_green,
  blue           => s_blue,
  red_out        => red_out,
  green_out      => green_out,
  blue_out       => blue_out,
  horiz_sync_out => h_sync_out,
  vert_sync_out  => s_v_sync,
  pixel_row      => s_pixel_row,
  pixel_column   => s_pixel_column
  );

  v_sync_out <= s_v_sync;
  LEDR       <= SW;

end beh; -- beh