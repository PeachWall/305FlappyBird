library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.std_logic_misc.all;

entity cloud_blocks is
  port
  (
    clk                          : in std_logic;
    v_sync                       : in std_logic;
    speed                        : in std_logic_vector(1 downto 0);
    pixel_row, pixel_column      : in std_logic_vector(9 downto 0);
    rgba                         : in std_logic_vector(12 downto 0);
    sprite_row, sprite_col        : out std_logic_vector(3 downto 0);
    cloud_frame                  : out std_logic;
    red, green, blue             : out std_logic_vector(3 downto 0);
    cloud_on                     : out std_logic
  );
end entity cloud_blocks;

architecture rtl of cloud_blocks is
  constant screen_height : integer := 479;
  constant screen_width  : integer := 639;
  constant half_width    : integer := 239;
  constant s_speed         : integer := 1;

  constant scale : integer := 2;
  constant size  : integer := 80;

  -- x and y position for cloud_blocks
  signal c_on          : std_logic;
  signal y_pos         : std_logic_vector(9 downto 0);
  signal x_pos         : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(screen_width, 10);
  signal cloud_on_mask : std_logic_vector(3 downto 0);

begin

  cloud_on_mask <= (others => c_on);

  y_pos <= CONV_STD_LOGIC_VECTOR(400, 10);

  -- cloud on when pixel is within the cloud_blocks
    c_on <= '1' when ('0' & pixel_row >= '0' & y_pos) else '0';

  -- Set RGBA values of sprite
  red      <= rgba(11 downto 8) and cloud_on_mask ;
  green    <= rgba(7 downto 4)  and cloud_on_mask;
  blue     <= rgba(3 downto 0)  and cloud_on_mask;

  cloud_on <= c_on;

  MOVE : process (v_sync)
  begin
    if (rising_edge(v_sync)) then
      x_pos <= x_pos - s_speed;

      if (x_pos <= 0) then
        x_pos <= conv_std_logic_vector(screen_width, 10);
      end if;
    end if;
  end process;

  SPRITE : process (pixel_row, pixel_column)
    variable col_d, row_d   : ieee.numeric_std.unsigned(9 downto 0) := (others => '0');
    variable temp_c, temp_r : ieee.numeric_std.unsigned(9 downto 0) := (others => '0');
  begin 
    if (c_on = '1') then
      --temp_c := ieee.numeric_std.unsigned(pixel_column - x_pos); -- Gets the pixels from 0 - size
      temp_c := ieee.numeric_std.unsigned(pixel_column - x_pos);
      temp_r := ieee.numeric_std.unsigned(pixel_row - y_pos);
    else
      temp_c := (others => '0');
      temp_r := (others => '0');
    end if;
    
    col_d := shift_right(temp_c, scale - 1); -- divide be powers of 2 to change size
    row_d := shift_right(temp_r, scale - 1);

    sprite_row <= std_logic_vector(row_d(3 downto 0));
    sprite_col <= std_logic_vector(col_d(3 downto 0));

    cloud_frame <= or_reduce(std_logic_vector(row_d(9 downto 4)));
  end process;
    
        
end architecture;