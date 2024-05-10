library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.std_logic_misc.all;

entity floor is
  port
  (
    v_sync                             : in std_logic;
    rgba                               : in std_logic_vector(12 downto 0);
    pixel_row, pixel_column            : in std_logic_vector(9 downto 0);
    speed                              : in std_logic_vector(1 downto 0);
    floor_sprite_tile                  : out std_logic;
    floor_sprite_row, floor_sprite_col : out std_logic_vector(3 downto 0);
    red, green, blue                   : out std_logic_vector(3 downto 0);
    floor_on                           : out std_logic);
end floor;

architecture behavior of floor is

  constant size         : integer := 16;
  constant scale        : integer := 2;
  constant screen_width : integer := 639;

  signal f_on          : std_logic;
  signal x_pos         : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(screen_width, 10);
  signal y_pos         : std_logic_vector(9 downto 0);
  signal floor_on_mask : std_logic_vector(3 downto 0);
begin

  floor_on_mask <= (others => f_on);

  y_pos <= CONV_STD_LOGIC_VECTOR(440, 10);

  f_on <= '1' when ('0' & pixel_row >= '0' & y_pos) else
    '0';

  -- Set RGBA values of sprite
  red      <= rgba(11 downto 8) and floor_on_mask;
  green    <= rgba(7 downto 4) and floor_on_mask;
  blue     <= rgba(3 downto 0) and floor_on_mask;
  floor_on <= f_on;

  MOVEMENT : process (v_sync)
  begin
    if (ieee.std_logic_1164.rising_edge(v_sync)) then
      x_pos <= x_pos - speed;

      if (x_pos <= 0) then
        x_pos     <= CONV_STD_LOGIC_VECTOR(screen_width, 10);
      end if;
    end if;
  end process;

  SPRITE : process (pixel_row, pixel_column)
    variable col_d, row_d   : ieee.numeric_std.unsigned(9 downto 0) := (others => '0');
    variable temp_c, temp_r : ieee.numeric_std.unsigned(9 downto 0) := (others => '0');
  begin
    if (f_on = '1') then
      --temp_c := ieee.numeric_std.unsigned(pixel_column - x_pos); -- Gets the pixels from 0 - size
      temp_c := ieee.numeric_std.unsigned(pixel_column - x_pos);
      temp_r := ieee.numeric_std.unsigned(pixel_row - y_pos);
    else
      temp_c := (others => '0');
      temp_r := (others => '0');
    end if;
    col_d := shift_right(temp_c, scale - 1); -- divide be powers of 2 to change size
    row_d := shift_right(temp_r, scale - 1);

    floor_sprite_row <= std_logic_vector(row_d(3 downto 0));
    floor_sprite_col <= std_logic_vector(col_d(3 downto 0));

    floor_sprite_tile <= or_reduce(std_logic_vector(row_d(9 downto 4)));
  end process;

end behavior;