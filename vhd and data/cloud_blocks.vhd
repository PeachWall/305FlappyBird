library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_misc.all;
use work.util.all;

entity cloud_blocks is
  port
  (
    clk                     : in std_logic;
    v_sync                  : in std_logic;
    speed                   : in std_logic_vector(2 downto 0);
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    clouds_rgb_out          : out std_logic_vector(11 downto 0);
    cloud_on                : out std_logic
  );
end entity cloud_blocks;

architecture rtl of cloud_blocks is
  constant screen_height : integer := 479;
  constant screen_width  : integer := 639;
  constant half_width    : integer := 239;

  constant sprite_width  : integer := 240 * scale;
  constant sprite_height : integer := 80 * scale;

  -- x and y position for cloud_blocks
  signal c_on          : std_logic;
  signal y_pos         : std_logic_vector(9 downto 0);
  signal x_pos         : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(screen_width, 10));
  signal cloud_on_mask : std_logic_vector(3 downto 0);

  signal sprite_row : std_logic_vector(5 downto 0);
  signal sprite_col : std_logic_vector(6 downto 0);
  signal argb       : std_logic_vector(12 downto 0);

  component cloud_rom is
    port
    (
      clock        : in std_logic;
      row          : in std_logic_vector(5 downto 0);
      col          : in std_logic_vector(6 downto 0);
      pixel_output : out std_logic_vector(12 downto 0)
    );
  end component;

begin

  cloud_on_mask <= (others => c_on);

  y_pos <= std_logic_vector(to_unsigned(312, 10));

  -- cloud on when pixel is within the cloud_blocks
  c_on <= '1' when ('0' & pixel_row >= '0' & y_pos) else
    '0';

  -- Set argb values of sprite
  clouds_rgb_out <= argb(11 downto 0);
  cloud_on       <= argb(12);

  MOVE : process (v_sync)
    variable temp_speed : std_logic_vector(11 downto 0) := "00" & x_pos;
  begin
    if (rising_edge(v_sync)) then
      -- Sub-pixelling for slower movement
      temp_speed := temp_speed - speed;
    end if;

    x_pos <= temp_speed(11 downto 2);
  end process;

  SPRITE : process (pixel_row, pixel_column)
    variable col_d, row_d   : unsigned(9 downto 0) := (others => '0');
    variable temp_c, temp_r : unsigned(9 downto 0) := (others => '0');

  begin
    if (c_on = '1') then
      temp_c := unsigned(pixel_column - x_pos);
      temp_r := unsigned(pixel_row - y_pos);
    else
      temp_c := (others => '0');
      temp_r := (others => '0');
    end if;
    col_d := temp_c / scale; -- divide be powers of 2 to change size
    row_d := temp_r / scale;

    sprite_row <= std_logic_vector(row_d(5 downto 0));
    sprite_col <= std_logic_vector(col_d(6 downto 0));
  end process;

  SPRITE_ROM : cloud_rom
  port map
  (
    clock        => clk,
    row          => sprite_row,
    col          => sprite_col,
    pixel_output => argb
  );
end architecture;