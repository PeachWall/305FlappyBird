library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use work.util.all;

entity abilities is
  port
  (
    clock                   : in std_logic;
    vsync                   : in std_logic;
    speed                   : in std_logic_vector(2 downto 0);
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    ability_type            : out std_logic_vector(1 downto 0);
    rgb_out                 : out std_logic_vector(11 downto 0);
    ability_on              : out std_logic
  );
end entity abilities;

architecture beh of abilities is
  constant size         : integer := 8;
  constant ability_size : integer := size * scale;
  -- SIGNAL x_pos : std_logic_vector(10 downto 0);

  signal x_pos         : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(832, 11));
  signal y_pos         : integer range 100 to 400      := 360;
  signal ability_reset : std_logic                     := '0';

  signal random_num : signed(7 downto 0);

  component random_gen is
    port
    (
      clk, reset, enable : in std_logic;
      Q                  : out signed(7 downto 0)
    );
  end component;

begin
  MOVEMENT : process (vsync)
    variable v_y_pos : integer range -480 to 480 := 360;
  begin
    if rising_edge(vsync) then
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
      end if;
    end if;
    y_pos <= v_y_pos;
  end process;

  ability_on <= '1' when (pixel_row >= y_pos and pixel_row < y_pos + ability_size) and ('0' & pixel_column >= x_pos and '0' & pixel_column < x_pos + ability_size) else
    '0';

  rgb_out <= (others => '0');

  RNG : random_gen
  port map
  (
    clk    => clock,
    reset  => '0',
    enable => '1',
    Q      => random_num
  );
end architecture;