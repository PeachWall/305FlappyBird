library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity player is
  port
  (
    clk, vert_sync          : in std_logic;
    rgba                    : in std_logic_vector(12 downto 0);
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    mouse                   : in std_logic;
		collided                : in std_logic;
    sprite_row, sprite_col  : out std_logic_vector(3 downto 0);
    red, green, blue        : out std_logic_vector(3 downto 0);
    alpha                   : out std_logic;
		move_x, move_y          : out std_logic_vector(9 downto 0)
  );
end entity player;

architecture behavior of player is
  constant scale : integer              := 2;
  constant size  : unsigned(7 downto 0) := shift_left("00010000", scale - 1); -- 16 * 2^(scale - 1)

  signal pixel_rgba             : std_logic_vector(3 downto 0);
  signal sprite_on              : std_logic;
  signal rom_address, rom_pixel : std_logic_vector (9 downto 0);
  signal prev_row               : std_logic_vector(9 downto 0);

  signal player_x_pos : std_logic_vector(9 downto 0);
  signal player_y_pos : std_logic_vector(9 downto 0);

  signal vec_sprite_on : std_logic_vector(3 downto 0);

  constant gravity : integer := 2;
begin
  move_x <= player_x_pos;
  move_y <= player_y_pos;

  sprite_on <= '1' when (('0' & pixel_column >= player_x_pos) and ('0' & pixel_column < player_x_pos + to_integer(size))
    and ('0' & pixel_row >= player_y_pos) and ('0' & pixel_row < player_y_pos + to_integer(size))) else '0';

  vec_sprite_on <= (others => sprite_on);

  red   <= rgba(11 downto 8) and vec_sprite_on;
  green <= rgba(7 downto 4) and vec_sprite_on;
  blue  <= rgba(3 downto 0) and vec_sprite_on;
  alpha <= rgba(12);

	-- Player control using mouse input
	Move_Player : process (vert_sync)
    variable y_velocity : std_logic_vector (9 downto 0);
    variable hold       : std_logic;
  begin
    -- Move ball once every vertical sync
    if (rising_edge(vert_sync)) then
      -- if mouse clicked
      if (mouse = '1' and hold = '0') then
        hold       := '1';
        y_velocity := - CONV_STD_LOGIC_VECTOR(32, 10);
      else
        if (y_velocity >= CONV_STD_LOGIC_VECTOR(16 * gravity, 10)) then
          y_velocity := CONV_STD_LOGIC_VECTOR(16 * gravity, 10);
        else
          y_velocity := signed(y_velocity) + gravity;
        end if;
      end if;
      player_y_pos <= player_y_pos + y_velocity(9 downto 2);

      -- check if ball is at the floor or at ceiling
      if( player_y_pos >= CONV_STD_LOGIC_VECTOR(440, 10)) then
        player_y_pos := CONV_STD_LOGIC_VECTOR(472, 10); -- This needs to change to account for size changes 
        y_velocity := 0;
      elsei if (player_y_pos <= CONV_STD_LOGIC_VECTOR(0, 10)) then
        player_y_pos := CONV_STD_LOGIC_VECTOR(0, 10);
        y_velocity := 0;
      end if;

      if (mouse = '0') then
        hold := '0';
      end if;
    end if;
  end process Move_Player;

  -- Get the pixel coordinates in terms of the row and column address
  address : process (sprite_on, pixel_column, pixel_row)
    variable col_d, row_d   : unsigned(9 downto 0) := (others => '0');
    variable temp_c, temp_r : unsigned(9 downto 0) := (others => '0');
  begin
    if (sprite_on = '1') then
      temp_c := unsigned(pixel_column - player_x_pos); -- Gets the pixels from 0 - size
      temp_r := unsigned(pixel_row - player_y_pos);
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