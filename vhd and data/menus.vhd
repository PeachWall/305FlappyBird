library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.util.all;

entity menus is
  port
  (
    signal clk, vert_sync          : in std_logic;
    signal pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    signal game_state              : in std_logic_vector(3 downto 0);
    signal menu_rgb_out            : out std_logic_vector(11 downto 0);
    signal menu_on                 : out std_logic
  );
end entity;

architecture beh of menus is

  component char_rom is
    port
    (
      character_address  : in std_logic_vector (5 downto 0);
      font_row, font_col : in std_logic_vector (2 downto 0);
      clock              : in std_logic;
      rom_mux_output     : out std_logic
    );
  end component char_rom;

  signal s_text_on        : std_logic;
  signal char_add         : std_logic_vector(5 downto 0);
  signal empty_space      : std_logic;
  signal r, g, b          : std_logic_vector(3 downto 0);
  constant text_start     : integer := 191; -- welcom begins from pixel row 119
  constant char_width_big : integer := 16; -- width and height of each pixel (24 x 24 because of font_row and font_col)

  signal s_text_on2   : std_logic;
  signal char_add2    : std_logic_vector(5 downto 0);
  signal empty_space2 : std_logic;

  signal black_line         : std_logic;
  constant text_start2      : integer := 31; -- MUST BE A MULTIPLE OF THE CHAR WIDTH -1
  constant char_width_small : integer := 8; -- width and height of each pixel (8 x 8 because of font_row and font_col)

  signal s_text_on3    : std_logic;
  signal char_add3     : std_logic_vector(5 downto 0);
  signal empty_space3  : std_logic;
  constant text_start3 : integer := 279;

  signal s_text_on_rgb  : std_logic_vector(3 downto 0);
  signal cur_game_state : game_states;
  signal collided_state : std_logic;

begin

  cur_game_state <= game_states'val(to_integer(unsigned(game_state)));
  -- multiple of 16                                 -16 from other number
  -- WORD STARTS AT COL 254 AND ENDS AT COL 380 AND HAS A HEIGHT OF 16 PIXELS BETWEEN ROW 208 AND 222     MAYBE 350 ??
  empty_space <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(479, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(304, 10)) or pixel_row < std_logic_vector(to_unsigned(288, 10))))) else
    '0';
  empty_space2 <= '1' when (pixel_column <= std_logic_vector(to_unsigned(text_start2 - char_width_small, 10)) or pixel_column >= std_logic_vector(to_unsigned(111, 10))) or (pixel_row >= std_logic_vector(to_unsigned(400, 10)) or pixel_row < std_logic_vector(to_unsigned(392, 10))) else
    '0';
  empty_space3 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start3 - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(376, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(400, 10)) or pixel_row < std_logic_vector(to_unsigned(392, 10)))) else
    '0';

  char_add                                               <= "100000" when empty_space = '1' else
    std_logic_vector(to_unsigned(2, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start, 10)) and empty_space = '0' else --"B"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 16, 10)) and empty_space = '0' else --"I"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 32, 10)) and empty_space = '0' else --"R"
    std_logic_vector(to_unsigned(4, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 48, 10)) and empty_space = '0' else --"D"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 64, 10)) and empty_space = '0' else --" "
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 80, 10)) and empty_space = '0' else --"I"
    std_logic_vector(to_unsigned(19, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 96, 10)) and empty_space = '0' else --"S"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 112, 10)) and empty_space = '0' else --" "
    std_logic_vector(to_unsigned(20, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 128, 10)) and empty_space = '0' else --"T"
    std_logic_vector(to_unsigned(8, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 144, 10)) and empty_space = '0' else --"H"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 160, 10)) and empty_space = '0' else --"E"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 176, 10)) and empty_space = '0' else --" "
    std_logic_vector(to_unsigned(23, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 192, 10)) and empty_space = '0' else --"W"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 208, 10)) and empty_space = '0' else --"O"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 224, 10)) and empty_space = '0' else --"R"
    std_logic_vector(to_unsigned(4, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 240, 10)) and empty_space = '0' else --"D"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE
  char_add2                                              <= "100000" when empty_space2 = '1' else
    std_logic_vector(to_unsigned(11, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2, 10)) and empty_space2 = '0' else --"K"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start2 + 8, 10)) and empty_space2 = '0' else --"E"
    std_logic_vector(to_unsigned(25, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 16, 10)) and empty_space2 = '0' else --"Y"
    std_logic_vector(to_unsigned(48, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 24, 10)) and empty_space2 = '0' else --"0"
    std_logic_vector(to_unsigned(45, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 32, 10)) and empty_space2 = '0' else --"-"
    std_logic_vector(to_unsigned(14, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 40, 10)) and empty_space2 = '0' else --"N"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 48, 10)) and empty_space2 = '0' else --"O"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 56, 10)) and empty_space2 = '0' else --"R"
    std_logic_vector(to_unsigned(13, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 64, 10)) and empty_space2 = '0' else --"M"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start2 + 72, 10)) and empty_space2 = '0' else --"A"
    std_logic_vector(to_unsigned(12, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 80, 10)) and empty_space2 = '0' else --"L"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  char_add3                                              <= "100000" when empty_space3 = '1' else
    std_logic_vector(to_unsigned(11, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3, 10)) and empty_space3 = '0' else --"K"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 8, 10)) and empty_space3 = '0' else --"E"
    std_logic_vector(to_unsigned(25, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 16, 10)) and empty_space3 = '0' else --"Y"
    std_logic_vector(to_unsigned(49, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 24, 10)) and empty_space3 = '0' else --"1"
    std_logic_vector(to_unsigned(45, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 32, 10)) and empty_space3 = '0' else --"-"
    std_logic_vector(to_unsigned(20, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 40, 10)) and empty_space3 = '0' else --"T"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 48, 10)) and empty_space3 = '0' else --"R"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 56, 10)) and empty_space3 = '0' else --"A"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 64, 10)) and empty_space3 = '0' else --"I"
    std_logic_vector(to_unsigned(14, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 72, 10)) and empty_space3 = '0' else --"N"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 80, 10)) and empty_space3 = '0' else --"I"
    std_logic_vector(to_unsigned(14, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 88, 10)) and empty_space3 = '0' else --"N"
    std_logic_vector(to_unsigned(7, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 96, 10)) and empty_space3 = '0' else --"G"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE
  black_line <= '1' when pixel_column = 0 else
    '0';

  s_text_on_rgb <= (s_text_on & s_text_on & s_text_on & s_text_on) or (s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2) or (s_text_on3 & s_text_on3 & s_text_on3 & s_text_on3);

  r <= not ((s_text_on_rgb or (black_line & black_line & black_line & black_line)) and "1111");
  g <= not ((s_text_on_rgb or (black_line & black_line & black_line & black_line)) and "1111");
  b <= not ((s_text_on_rgb or (black_line & black_line & black_line & black_line)) and "1111");

  collided_state <= '0' when (cur_game_state = PLAY) else
    '1';
  menu_on <= (s_text_on or s_text_on2 or s_text_on3) when cur_game_state = FINISH else
    '1' when cur_game_state = FINISH else
    (s_text_on) when cur_game_state = COLLIDE else
    '0' when cur_game_state = PAUSED;
  menu_rgb_out <= r & g & b when cur_game_state = MENU else
    "000000000000" when cur_game_state = FINISH;

  text_SCORE : char_rom
  port map
  (
    character_address => char_add,
    font_row          => pixel_row(3 downto 1),
    font_col          => pixel_column(3 downto 1),
    clock             => clk,
    rom_mux_output    => s_text_on
  );

  text_NORMALPLAY : char_rom
  port
  map
  (
  character_address => char_add2,
  font_row          => pixel_row(2 downto 0),
  font_col          => pixel_column(2 downto 0),
  clock             => clk,
  rom_mux_output    => s_text_on2
  );

  text_timer : char_rom
  port
  map
  (
  character_address => char_add3,
  font_row          => pixel_row(2 downto 0),
  font_col          => pixel_column(2 downto 0),
  clock             => clk,
  rom_mux_output    => s_text_on3
  );

end architecture beh;