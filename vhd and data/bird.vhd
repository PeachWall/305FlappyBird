library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity bird is
  port
  (
	 clk                     : in std_logic;
	 rgba                    : in std_logic_vector(12 downto 0);
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    x_pos, y_pos            : in std_logic_vector(9 downto 0);
	 sprite_row, sprite_col  : out std_logic_vector(3 downto 0);
    red, green, blue        : out std_logic_vector(3 downto 0);
    alpha                   : out std_logic
  );
end entity bird;

architecture rtl of bird is
  constant scale : integer              := 2;
  constant size  : unsigned(7 downto 0) := shift_left("00010000", scale - 1); -- 16 * 2^(scale - 1)

  signal pixel_rgba             : std_logic_vector(3 downto 0);
  signal sprite_on              : std_logic;
  signal rom_address, rom_pixel : std_logic_vector (9 downto 0);
  signal prev_row               : std_logic_vector(9 downto 0);

  signal vec_sprite_on : std_logic_vector(3 downto 0);
begin

  sprite_on <= '1' when (('0' & pixel_column >= x_pos) and ('0' & pixel_column < x_pos + to_integer(size)) -- x_pos - size <= pixel_column <= x_pos + size
    and ('0' & pixel_row >= y_pos) and ('0' & pixel_row < y_pos + to_integer(size))) else -- y_pos - size <= pixel_row <= y_pos + size
    '0';

  vec_sprite_on <= (others => sprite_on);

  red   <= rgba(11 downto 8) and vec_sprite_on;
  green <= rgba(7 downto 4) and vec_sprite_on;
  blue  <= rgba(3 downto 0) and vec_sprite_on;
  alpha <= rgba(12);

  -- Get the pixel coordinates in terms of the row and column address
  address : process (sprite_on, pixel_column, pixel_row)
    variable col_d, row_d   : unsigned(9 downto 0) := (others => '0');
    variable counter        : integer range 0 to scale;
    variable temp_c, temp_r : unsigned(9 downto 0) := (others => '0');

  begin
    if (sprite_on = '1') then
      temp_c := unsigned(pixel_column - x_pos); -- Gets the pixels from 0 - size
      temp_r := unsigned(pixel_row - y_pos);
    else
      temp_c := (others => '0');
      temp_r := (others => '0');
    end if;
    col_d := shift_right(temp_c, scale - 1); -- divide be powers of 2 to change size
    row_d := shift_right(temp_r, scale - 1);

    sprite_row <= std_logic_vector(row_d(3 downto 0));
    sprite_col <= std_logic_vector(col_d(3 downto 0));
  end process;
end architecture;