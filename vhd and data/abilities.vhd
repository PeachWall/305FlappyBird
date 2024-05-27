library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use work.util.all;

entity abilities is
  port
  (
    clock, reset            : in std_logic;
    vsync                   : in std_logic;
    speed                   : in std_logic_vector(2 downto 0);
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    collided                : in std_logic;
    bird_state              : in std_logic_vector(2 downto 0);
    speed_state             : in std_logic_vector(2 downto 0);
    difficulty              : in std_logic_vector(2 downto 0);
    item_type               : out std_logic_vector(2 downto 0);
    rgb_out                 : out std_logic_vector(11 downto 0);
    ability_on              : out std_logic
  );
end entity abilities;

architecture beh of abilities is
  constant size         : integer := 16;
  constant ability_size : integer := size * scale;
  -- SIGNAL x_pos : std_logic_vector(10 downto 0);

  signal x_pos         : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(832, 11));
  signal y_pos         : integer range 100 to 400      := 360;
  signal ability_reset : std_logic                     := '0';

  signal random_num   : signed(7 downto 0);
  signal ability_type : ability_types := MONEY;

  signal ability_draw : std_logic;

  signal frame : std_logic_vector(3 downto 0);
  signal argb  : std_logic_vector(12 downto 0);

  signal sprite_on : std_logic;

  signal cur_bird_state  : player_states;
  signal cur_speed_state : speed_states;

  signal sprite_row, sprite_col : std_logic_vector(10 downto 0);
  component random_gen is
    port
    (
      clk, reset, enable : in std_logic;
      Q                  : out signed(7 downto 0)
    );
  end component;

  component abilities_rom is
    port
    (
      clock        : std_logic;
      frame        : in std_logic_vector(3 downto 0);
      row, col     : in std_logic_vector(3 downto 0);
      pixel_output : out std_logic_vector(12 downto 0)
    );
  end component;

begin
  item_type       <= std_logic_vector(to_unsigned(ability_types'pos(ability_type), 3));
  cur_bird_state  <= player_states'val(to_integer(unsigned(bird_state)));
  cur_speed_state <= speed_states'val(to_integer(unsigned(speed_state)));

  ability_draw <= '0' when collided = '1' else
    '1' when x_pos = std_logic_vector(to_unsigned(639, 11));

  sprite_on <= '1' when (pixel_row >= y_pos and pixel_row < y_pos + ability_size) and ('0' & pixel_column >= x_pos and '0' & pixel_column < x_pos + ability_size) and ability_draw = '1' else
    '0';
  rgb_out <= argb(11 downto 0);

  ability_on <= argb(12) and sprite_on;

  MOVEMENT : process (vsync, reset)
    variable v_y_pos      : integer range -480 to 480 := 360;
    variable abs_random   : signed(7 downto 0);
    variable frame_count  : integer range 0 to 15        := 0;
    variable v_frame      : std_logic_vector(3 downto 0) := (others => '0');
    variable prev_ability : ability_types;
    variable start_anim   : std_logic;
  begin
    if (reset = '1') then
      x_pos <= std_logic_vector(to_unsigned(832, 11));
    elsif rising_edge(vsync) then
      case ability_type is
        when MONEY =>

          if (prev_ability /= ability_type) then
            frame <= std_logic_vector(to_unsigned(0, 4));
          elsif (frame_count >= 8) then
            if (frame <= 4) then
              frame     <= frame + 1;
            else
              frame <= std_logic_vector(to_unsigned(0, 4));
            end if;
            frame_count := 0;
          else
            frame_count := frame_count + 1;
          end if;
        when LIFE   => frame   <= std_logic_vector(to_unsigned(8, 4));
        when BIG    => frame    <= std_logic_vector(to_unsigned(9, 4));
        when SMALL  => frame  <= std_logic_vector(to_unsigned(10, 4));
        when SLOW   => frame   <= std_logic_vector(to_unsigned(11, 4));
        when FAST   => frame   <= std_logic_vector(to_unsigned(12, 4));
        when BOMB   => frame   <= std_logic_vector(to_unsigned(13, 4));
        when others => frame <= std_logic_vector(to_unsigned(14, 4));
      end case;
      x_pos <= x_pos - to_integer(unsigned(speed));

      if (x_pos <= - (64)) then
        x_pos     <= std_logic_vector(to_unsigned(639, 11));
        v_y_pos := to_integer(random_num) + half_height;

        -- LIMIT HEIGHT
        if (v_y_pos > half_height + 100) then
          v_y_pos := half_height + 100;
        elsif (v_y_pos < half_height - 100) then
          v_y_pos := half_height - 100;
        end if;

        -- Random Ability
        if (difficulty /= "100") then
          abs_random := abs(random_num);
          if (abs_random < 25 and abs_random >= 20) then
            ability_type <= LIFE;
          elsif (abs_random < 20 and abs_random >= 15 and cur_speed_state = NORMAL) then
            ability_type <= SLOW;
          elsif (abs_random < 15 and abs_random >= 10 and cur_speed_state = NORMAL) then
            ability_type <= FAST;
          elsif (abs_random < 10 and abs_random >= 5 and cur_bird_state = NORMAL) then
            ability_type <= BIG;
          elsif (abs_random < 5 and abs_random >= 0 and cur_bird_state = NORMAL) then
            ability_type <= SMALL;
          else
            ability_type <= MONEY;
          end if;
        else
          abs_random := abs(random_num);
          if (abs_random < 80 and abs_random >= 25) then
            ability_type <= BOMB;
          elsif (abs_random < 25 and abs_random >= 20) then
            ability_type <= LIFE;
          elsif (abs_random < 20 and abs_random >= 15 and cur_speed_state = NORMAL) then
            ability_type <= SLOW;
          elsif (abs_random < 15 and abs_random >= 10 and cur_speed_state = NORMAL) then
            ability_type <= FAST;
          elsif (abs_random < 10 and abs_random >= 5 and cur_bird_state = NORMAL) then
            ability_type <= BIG;
          elsif (abs_random < 5 and abs_random >= 0 and cur_bird_state = NORMAL) then
            ability_type <= SMALL;
          else
            ability_type <= MONEY;
          end if;
        end if;
      end if;

      prev_ability := ability_type;
    end if;
    y_pos <= v_y_pos;

  end process;
  -- Get the pixel coordinates in terms of the row and column address
  sprite_row <= '0' & pixel_row - y_pos;
  sprite_col <= '0' & pixel_column - x_pos;

  RNG : random_gen
  port map
  (
    clk    => clock,
    reset  => '0',
    enable => '1',
    Q      => random_num
  );

  SPRITE_ROM : abilities_rom
  port
  map(
  clock        => clock,
  frame        => frame,
  row          => sprite_row(4 downto 1),
  col          => sprite_col(4 downto 1),
  pixel_output => argb
  );
end architecture;