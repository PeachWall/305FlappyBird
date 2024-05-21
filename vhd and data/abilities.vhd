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

  component random_gen is
    port
    (
      clk, reset, enable : in std_logic;
      Q                  : out signed(7 downto 0)
    );
  end component;

begin
  item_type <= std_logic_vector(to_unsigned(ability_types'pos(ability_type), 3));
  MOVEMENT : process (vsync, reset)
    variable v_y_pos    : integer range -480 to 480 := 360;
    variable abs_random : signed(7 downto 0);

  begin
    if (reset = '1') then
      x_pos <= std_logic_vector(to_unsigned(832, 11));
    elsif rising_edge(vsync) then
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
        abs_random := abs(random_num);
        if (abs_random < 39 and abs_random >= 26) then
          ability_type <= LIFE;
        elsif (abs_random < 26 and abs_random >= 13) then
          ability_type <= BIG;
        elsif (abs_random < 13 and abs_random >= 0) then
          ability_type <= SMALL;
        else
          ability_type <= MONEY;
        end if;
      end if;
    end if;
    y_pos <= v_y_pos;
  end process;

  ability_draw <= '0' when collided = '1' else
    '1' when x_pos = std_logic_vector(to_unsigned(639, 11));

  ability_on <= '1' when (pixel_row >= y_pos and pixel_row < y_pos + ability_size) and ('0' & pixel_column >= x_pos and '0' & pixel_column < x_pos + ability_size) and ability_draw = '1' else
    '0';
  rgb_out <=
    "111100000000" when ability_type = LIFE else
    "000011110000" when ability_type = BIG else
    "000000001111" when ability_type = SMALL else
    "111111110000"; -- MONEY

  RNG : random_gen
  port map
  (
    clk    => clock,
    reset  => '0',
    enable => '1',
    Q      => random_num
  );
end architecture;