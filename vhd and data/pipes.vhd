library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_SIGNED.all;
use work.util.all;

entity pipes is
  port
  (
    clk, reset              : in std_logic;
    v_sync                  : in std_logic;
    point_collided          : in std_logic;
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    bird_x_pos              : in std_logic_vector(9 downto 0);
    speed                   : in std_logic_vector(2 downto 0);
    game_state              : in std_logic_vector(2 downto 0);
    pipe_rgb_out            : out std_logic_vector(11 downto 0);
    pipe_on                 : out std_logic;
    point_box_on            : out std_logic;
    point_increment         : out std_logic := '0'
  );
end entity pipes;

architecture rtl of pipes is
  component random_gen is
    port
    (
      clk, reset, enable : in std_logic;
      Q                  : out ieee.numeric_std.signed(7 downto 0)
    );
  end component;

  component pipe_sprite_rom is
    port
    (
      clock        : in std_logic;
      row, col     : in std_logic_vector(4 downto 0);
      pixel_output : out std_logic_vector(12 downto 0)
    );
  end component;

  constant size           : integer              := 32;
  constant pipe_size      : unsigned(7 downto 0) := to_unsigned(size * scale, 8);
  constant half_pipe_size : unsigned(7 downto 0) := shift_right(pipe_size, 1);

  -- constant gap_size : integer := 64; -------------------------------------------------------------------------------------------------------- FSM CHANGES GAP SIZE
  constant gap_size : integer := 64;
  constant x_speed  : integer := 2;
  constant distance : integer := 319 + to_integer(pipe_size - half_pipe_size);

  -- Top and Bottom pipes
  signal pipe1_top_on, pipe1_bottom_on : std_logic;
  signal pipe2_top_on, pipe2_bottom_on : std_logic;

  -- x and y position for pipes
  signal pipe1_y_pos, pipe2_y_pos : integer range 120 to 360      := 360;
  signal pipe1_x_pos              : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(screen_width, 11));
  signal pipe2_x_pos              : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(screen_width + distance, 11));

  signal pipe1_on, pipe2_on : std_logic;
  signal s_pipe_on          : std_logic;

  signal point_box_draw : std_logic;

  signal random_num   : ieee.numeric_std.signed(7 downto 0);
  signal pipe_on_mask : std_logic_vector(3 downto 0);

  signal pipe_sprite_row, pipe_sprite_col : std_logic_vector(4 downto 0);
  signal argb                             : std_logic_vector(12 downto 0);

  signal cur_game_state : game_states;

begin
  cur_game_state <= game_states'val(to_integer(unsigned(game_state)));
  -- Output either top or bottom pipe is being drawn
  pipe1_on  <= pipe1_bottom_on or pipe1_top_on;
  pipe2_on  <= pipe2_bottom_on or pipe2_top_on;
  s_pipe_on <= pipe1_on or pipe2_on;

  pipe_on_mask <= (others => s_pipe_on);

  point_increment <= '1' when point_collided = '1' else
    '0' when pipe1_x_pos = std_logic_vector(to_unsigned(screen_width, 11)) or pipe2_x_pos = std_logic_vector(to_unsigned(screen_width, 11));

  -- Pipe1 : TOP AND BOTTOM
  pipe1_top_on <= '1' when ('0' & pixel_column >= pipe1_x_pos) and ('0' & pixel_column < pipe1_x_pos + to_integer(pipe_size))
    and (pixel_row >= 0) and (pixel_row < pipe1_y_pos - gap_size) else
    '0';

  pipe1_bottom_on <= '1' when ('0' & pixel_column >= pipe1_x_pos) and ('0' & pixel_column < pipe1_x_pos + to_integer(pipe_size))
    and (pixel_row  <= screen_height) and (pixel_row > pipe1_y_pos + gap_size) else
    '0';

  -- Pipe2 : TOP AND BOTTOM
  pipe2_top_on <= '1' when ('0' & pixel_column >= pipe2_x_pos) and ('0' & pixel_column < pipe2_x_pos + to_integer(pipe_size))
    and (pixel_row >= 0) and (pixel_row < pipe2_y_pos - gap_size) else
    '0';

  pipe2_bottom_on <= '1' when ('0' & pixel_column >= pipe2_x_pos) and ('0' & pixel_column < pipe2_x_pos + to_integer(pipe_size))
    and (pixel_row  <= screen_height) and (pixel_row > pipe2_y_pos + gap_size) else
    '0';

  point_box_on <= '1' when ('0' & pixel_column >= pipe1_x_pos + to_integer(pipe_size) - 8 and '0' & pixel_column < pipe1_x_pos + to_integer(pipe_size)) or
    ('0' & pixel_column >= pipe2_x_pos + to_integer(pipe_size) - 8 and '0' & pixel_column < pipe2_x_pos + to_integer(pipe_size)) else
    '0';

  -- Set argb values of sprite
  pipe_rgb_out <= argb(11 downto 0);
  pipe_on      <= argb(12);

  MOVEMENT : process (v_sync, reset)
    variable y_pos1, y_pos2 : integer range -480 to 480 := 360;
  begin
    if (reset = '1') then
      pipe1_x_pos <= std_logic_vector(to_unsigned(screen_width, 11));
      pipe2_x_pos <= std_logic_vector(to_unsigned(screen_width + distance, 11));
    elsif (rising_edge(v_sync)) then
      pipe1_x_pos <= pipe1_x_pos - to_integer(unsigned(speed));
      pipe2_x_pos <= pipe2_x_pos - to_integer(unsigned(speed));

      -- PIPE 1
      if (pipe1_x_pos <= - to_integer(pipe_size)) then
        y_pos1 := to_integer(random_num) + half_height;
        pipe1_x_pos <= std_logic_vector(to_unsigned(screen_width, 11));
        -- LIMIT HEIGHT
        if (y_pos1 > half_height + 100) then
          y_pos1 := half_height + 100;
        elsif (y_pos1 < half_height - 100) then
          y_pos1 := half_height - 100;
        end if;
      end if;

      -- PIPE 2
      if (pipe2_x_pos <= - to_integer(pipe_size)) then
        y_pos2 := to_integer(random_num) + half_height;
        pipe2_x_pos <= std_logic_vector(to_unsigned(screen_width, 11));
        -- LIMIT HEIGHT
        if (y_pos2 > half_height + 100) then
          y_pos2 := half_height + 100;
        elsif (y_pos2 < half_height - 100) then
          y_pos2 := half_height - 100;
        end if;
      end if;
    end if;

    -- GET NEW POSITION
    pipe1_y_pos <= y_pos1;
    pipe2_y_pos <= y_pos2;
  end process;

  -- USED TO GET SPRITE ADDRESS
  SPRITE : process (pixel_row, pixel_column)
    variable temp_c : unsigned(10 downto 0) := (others => '0');
    variable temp_r : unsigned(9 downto 0)  := (others => '0');

    variable invert : std_logic;

  begin

    -- BOTTOM PIPES

    -- THIS IS DONE HORRIBLY AND WOULD LIKE TO FIX BUT NO TIME
    -- Pipe 1 bottom
    if (pipe1_bottom_on = '1') then
      invert := '0';
      temp_c := unsigned(pixel_column - pipe1_x_pos);
      temp_r := unsigned(pixel_row - pipe1_y_pos - gap_size); -- This gave me pain

      if (temp_r(9 downto 5) /= "00000") then
        temp_r := temp_r mod size + size;
      end if;

      -- Pipe 2 bottom
    elsif (pipe2_bottom_on = '1') then
      invert := '0';
      temp_c := unsigned(pixel_column - pipe2_x_pos);
      temp_r := unsigned(pixel_row - pipe2_y_pos - gap_size); -- This gave me pain

      if (temp_r(9 downto 5) /= "00000") then
        temp_r := temp_r mod size + size;
      end if;

      -- TOP PIPES
      -- Pipe 1
    elsif (pipe1_top_on = '1') then
      temp_c := unsigned(pixel_column - pipe1_x_pos);
      temp_r := unsigned(pixel_row - pipe1_y_pos - gap_size); -- This gave me pain

      if (pixel_row > pipe1_y_pos - to_integer(pipe_size) - gap_size and pixel_row <= pipe1_y_pos - gap_size) then
        invert := '1';
      else
        invert := '0';
        temp_r := temp_r mod size + size;
      end if;

    elsif (pipe2_top_on = '1') then
      temp_c := unsigned(pixel_column - pipe2_x_pos);
      temp_r := unsigned(pixel_row - pipe2_y_pos - gap_size); -- This gave me pain

      if (pixel_row > pipe2_y_pos - to_integer(pipe_size) - gap_size and pixel_row <= pipe2_y_pos - gap_size) then
        invert := '1';
      else
        invert := '0';
        temp_r := temp_r mod size + size;
      end if;
    else
      temp_c := (others => '0');
      temp_r := (others => '0');
    end if;

    if (invert = '0') then
      pipe_sprite_row <= std_logic_vector(temp_r(5 downto 1));
    else
      pipe_sprite_row <= 31 - std_logic_vector(temp_r(5 downto 1));
    end if;
    pipe_sprite_col <= std_logic_vector(temp_c(5 downto 1));
  end process;

  RNG : random_gen
  port map
  (
    clk    => clk,
    reset  => '0',
    enable => '1',
    Q      => random_num
  );

  SPRITE_ROM : pipe_sprite_rom
  port
  map(
  clock        => clk,
  row          => pipe_sprite_row,
  col          => pipe_sprite_col,
  pixel_output => argb
  );
end architecture;