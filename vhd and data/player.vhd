library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity player is
  port
  (
    clk, vert_sync, mouse   : in std_logic;
    collided                : in std_logic;
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    red, green, blue        : out std_logic_vector(3 downto 0);
    bird_on                 : out std_logic
  );
end entity player;

architecture behavioural of player is
  component bird_sprite_rom_12 is
    port
    (
      clock        : in std_logic;
      row, col     : in std_logic_vector(3 downto 0);
      pixel_output : out std_logic_vector(12 downto 0)
    );
  end component;
  constant scale : integer              := 2;
  constant size  : unsigned(7 downto 0) := shift_left("00010000", scale - 1); -- 16 * 2^(scale - 1)

  -- Data related to Movement
  signal player_y_pos     : std_logic_vector(9 downto 0);
  signal player_x_pos     : std_logic_vector(9 downto 0);
  signal move_x, move_y   : std_logic_vector(9 downto 0);

  constant gravity : integer := 2;

  -- Data related to ROM
  signal pixel_rgba             : std_logic_vector(3 downto 0);
  signal sprite_on              : std_logic;
  signal rom_address, rom_pixel : std_logic_vector (9 downto 0);
  signal prev_row               : std_logic_vector(9 downto 0);
  signal rgba                   : std_logic_vector(12 downto 0);

  signal vec_sprite_on : std_logic_vector(3 downto 0);

  signal sprite_row, sprite_col : std_logic_vector(3 downto 0);

begin

  move_x <= player_x_pos;
  move_y <= player_y_pos;

  sprite_on <= '1' when (('0' & pixel_column >= move_x) and ('0' & pixel_column < move_x + to_integer(size)) -- x_pos - size <= pixel_column <= x_pos + size
    and ('0' & pixel_row >= move_y) and ('0' & pixel_row < move_y + to_integer(size))) else -- y_pos - size <= pixel_row <= y_pos + size
    '0';

  Move_Player : process (vert_sync)
    variable y_velocity : std_logic_vector (9 downto 0);
    variable hold       : std_logic:= '0';
    begin
      -- Move ball once every vertical sync
      if (rising_edge(vert_sync)) then
        -- if mouse clicked
        if (mouse = '1' and hold = '0') then
          hold       := '1';
          y_velocity := std_logic_vector(to_signed(32, 10));
        else
          if (y_velocity >= std_logic_vector(to_signed(16 * gravity, 10))) then
            y_velocity := std_logic_vector(to_signed(16 * gravity, 10));
          else
            y_velocity := std_logic_vector(signed(y_velocity) + gravity);
          end if;
        end if;
        player_y_pos <= player_y_pos + y_velocity(9 downto 2);
  
        -- check if ball is at the floor or at ceiling
        if( player_y_pos >= std_logic_vector(to_unsigned(440, 10))) then
          player_y_pos <= std_logic_vector(to_unsigned(472, 10));
          y_velocity := std_logic_vector(to_unsigned(0,10));
        elsif (player_y_pos <= std_logic_vector(to_unsigned(0, 10))) then
          player_y_pos <= std_logic_vector(to_unsigned(0, 10));
          y_velocity := std_logic_vector(to_unsigned(0,10));
        end if;
  
        if (mouse = '0') then
          hold := '0';
        end if;
  
      end if;
  end process Move_Player;

  vec_sprite_on <= (others => sprite_on);

  red     <= rgba(11 downto 8) and vec_sprite_on;
  green   <= rgba(7 downto 4) and vec_sprite_on;
  blue    <= rgba(3 downto 0) and vec_sprite_on;
  bird_on <= rgba(12);

  -- Get the pixel coordinates in terms of the row and column address
  address : process (sprite_on, pixel_column, pixel_row)
    variable col_d, row_d   : unsigned(9 downto 0) := (others => '0');
    variable temp_c, temp_r : unsigned(9 downto 0) := (others => '0');

  begin
    if (sprite_on = '1') then
      temp_c := unsigned(pixel_column - move_x); -- Gets the pixels from 0 - size
      temp_r := unsigned(pixel_row - move_y);
    else
      temp_c := (others => '0');
      temp_r := (others => '0');
    end if;
    col_d := shift_right(temp_c, scale - 1); -- divide be powers of 2 to change size
    row_d := shift_right(temp_r, scale - 1);

    sprite_row <= std_logic_vector(row_d(3 downto 0));
    sprite_col <= std_logic_vector(col_d(3 downto 0));
  end process;

  SPRITE_ROM : bird_sprite_rom_12
  port map
  (
    clock        => clk,
    row          => sprite_row,
    col          => sprite_col,
    pixel_output => rgba
  );
end architecture;