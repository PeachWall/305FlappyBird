library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use work.util.all;

entity text is
  port
  (
    signal clk, vert_sync          : in std_logic;
    signal pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    signal score                   : in std_logic_vector(9 downto 0);
    signal timer                   : in std_logic_vector(4 downto 0);
    signal timer_on                : in std_logic;
    signal game_state              : in std_logic_vector(3 downto 0);
    signal lives                   : in std_logic_vector(2 downto 0);
    signal money_in                : in std_logic_vector(7 downto 0);
    signal text_rgb_out            : out std_logic_vector(11 downto 0);
    signal text_on                 : out std_logic
  );
end entity;

architecture beh of text is

  component char_rom is
    port
    (
      character_address  : in std_logic_vector (5 downto 0);
      font_row, font_col : in std_logic_vector (2 downto 0);
      clock              : in std_logic;
      rom_mux_output     : out std_logic
    );
  end component char_rom;

  component abilities_rom is
    port
    (
      clock        : std_logic;
      frame        : in std_logic_vector(3 downto 0);
      row, col     : in std_logic_vector(3 downto 0);
      pixel_output : out std_logic_vector(12 downto 0)
    );
  end component;

  signal s_text_on        : std_logic;
  signal text_big_out     : std_logic;
  signal text_small_out   : std_logic;
  signal char_add         : std_logic_vector(5 downto 0);
  signal empty_space      : std_logic;
  signal r, g, b          : std_logic_vector(3 downto 0);
  constant text_start     : integer := 255; -- welcom begins from pixel row 270
  constant char_width_big : integer := 16; -- width and height of each pixel (16 x 16 because of font_row and font_col)

  signal s_text_on2   : std_logic; -- delete signal
  signal char_add2    : std_logic_vector(5 downto 0);
  signal empty_space2 : std_logic;

  signal black_line         : std_logic;
  constant text_start2      : integer := 319; -- welcom begins from pixel row 20 -- MUST BE A MULTIPLE OF THE CHAR WIDTH
  constant char_width_small : integer := 8; -- width and height of each pixel (8 x 8 because of font_row and font_col)

  signal s_text_on3 : std_logic; -- delete_signal

  constant text_start3 : integer := 47;

  signal score_ones, score_tens, score_hundreds : integer range 0 to 9;
  signal money_ones, money_tens, money_hundreds : integer range 0 to 9;

  signal s_text_on_rgb : std_logic_vector(3 downto 0);

  signal timer_tens, timer_ones : integer range 0 to 9;

  signal rom_address_big   : std_logic_vector(5 downto 0);
  signal rom_address_small : std_logic_vector(5 downto 0);

  -- USED TO DISPLAY SPRITES FOR LIVES AND COINS
  constant sprite_size : integer := 16;
  signal egg_on        : std_logic;
  signal coin_on       : std_logic;
  signal char_add3     : std_logic_vector(5 downto 0);
  signal char_add4     : std_logic_vector(5 downto 0);
  signal empty_space3  : std_logic;
  signal empty_space4  : std_logic;
  signal item_frame    : std_logic_vector(3 downto 0);

  constant sprite_x : integer := text_start3 - char_width_small - sprite_size + 2;
  constant sprite_y : integer := 40;
  signal argb       : std_logic_vector(12 downto 0);

  signal cur_game_state : game_states;
begin

  cur_game_state <= game_states'val(to_integer(unsigned(game_state)));

  -- INTEGERS FOR SCORE
  score_ones     <= to_integer(unsigned(score)) mod 10;
  score_tens     <= to_integer(unsigned(score)) / 10 mod 10;
  score_hundreds <= to_integer(unsigned(score)) / 100 mod 10;

  -- INTEGERS FOR MONEY
  money_ones     <= to_integer(unsigned(money_in)) mod 10;
  money_tens     <= to_integer(unsigned(money_in)) / 10 mod 10;
  money_hundreds <= to_integer(unsigned(money_in)) / 100 mod 10;

  -- INTEGERS FOR TIME
  timer_ones <= to_integer(unsigned(timer)) mod 10;
  timer_tens <= to_integer(unsigned(timer)) / 10 mod 10;

  -- WORD STARTS AT COL 254 AND ENDS AT COL 380 AND HAS A HEIGHT OF 16 PIXELS BETWEEN ROW 208 AND 222     MAYBE 350 ??
  empty_space <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(385, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(64, 10)) or pixel_row <= std_logic_vector(to_unsigned(47, 10)))) else
    '0';

  empty_space2 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start2 - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(400, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(78, 10)) or pixel_row <= std_logic_vector(to_unsigned(61, 10)))) else
    '0';

  empty_space3 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start3 - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(400, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(56, 10)) or pixel_row <= std_logic_vector(to_unsigned(47, 10)))) else
    '0';
  empty_space4 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start3 - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(400, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(56 + 16, 10)) or pixel_row <= std_logic_vector(to_unsigned(47 + 16, 10)))) else
    '0';
  egg_on <= '1' when (pixel_column >= std_logic_vector(to_unsigned((sprite_x), 10))) and pixel_column < std_logic_vector(to_unsigned((sprite_x + sprite_size), 10)) and pixel_row < std_logic_vector(to_unsigned(sprite_y + sprite_size, 10)) and pixel_row >= std_logic_vector(to_unsigned(sprite_y, 10)) else
    '0';
  coin_on <= '1' when (pixel_column >= std_logic_vector(to_unsigned((sprite_x), 10))) and pixel_column < std_logic_vector(to_unsigned((sprite_x + sprite_size), 10)) and pixel_row < std_logic_vector(to_unsigned(sprite_y + (sprite_size * 2), 10)) and pixel_row >= std_logic_vector(to_unsigned(sprite_y + sprite_size, 10)) else
    '0';

  char_add <= std_logic_vector(to_unsigned(19, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start, 10)) else --"S"
    std_logic_vector(to_unsigned(3, 6)) when pixel_column                   <= std_logic_vector(to_unsigned(text_start + 16, 10)) else --"C"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column                  <= std_logic_vector(to_unsigned(text_start + 32, 10)) else --"O"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column                  <= std_logic_vector(to_unsigned(text_start + 48, 10)) else --"R"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column                   <= std_logic_vector(to_unsigned(text_start + 64, 10)) else --"E"
    std_logic_vector(to_unsigned(58, 6)) when pixel_column                  <= std_logic_vector(to_unsigned(text_start + 80, 10)) else --":"
    std_logic_vector(to_unsigned(score_hundreds + 48, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 96, 10)) else --"HUNDREDS"
    std_logic_vector(to_unsigned(score_tens + 48, 6)) when pixel_column     <= std_logic_vector(to_unsigned(text_start + 112, 10)) else --"TENS"
    std_logic_vector(to_unsigned(score_ones + 48, 6)) when pixel_column     <= std_logic_vector(to_unsigned(text_start + 128, 10)) else --"ONES"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  ---------------------------------------
  -- COMMENTED OUT TILL WE ADD THE FSM --
  ---------------------------------------
  -- char_add2                                        <= "100000" when empty_space2 = '1' else
  --   std_logic_vector(to_unsigned(13, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start2, 10)) and empty_space2 = '0' else --"M"
  --   std_logic_vector(to_unsigned(15, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start2 + 8, 10)) and empty_space2 = '0' else --"O"
  --   std_logic_vector(to_unsigned(4, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start2 + 16, 10)) and empty_space2 = '0' else --"D"
  --   std_logic_vector(to_unsigned(5, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start2 + 24, 10)) and empty_space2 = '0' else --"E
  --   std_logic_vector(to_unsigned(45, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start2 + 32, 10)) and empty_space2 = '0' else --"-"
  --   std_logic_vector(to_unsigned(13, 6)) when ((pixel_column <= std_logic_vector(to_unsigned(text_start2 + 40, 10)) and empty_space2 = '0') and (mode_m = '0')) else --"M"
  --   std_logic_vector(to_unsigned(8, 6)) when ((pixel_column  <= std_logic_vector(to_unsigned(text_start2 + 40, 10)) and empty_space2 = '0') and (mode_h = '0')) else --"H"
  --   std_logic_vector(to_unsigned(20, 6)) when ((pixel_column <= std_logic_vector(to_unsigned(text_start2 + 40, 10)) and empty_space2 = '0') and (mode_t = '0')) else --"T"
  --   std_logic_vector(to_unsigned(5, 6)) when ((pixel_column  <= std_logic_vector(to_unsigned(text_start2 + 40, 10)) and empty_space2 = '0')) else --"E"
  --   "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE
  ---------------------------------------------
  ---------------------------------------------
  -- HI LACHLAN JUST CLEANED UP SOME CODE :D 
  -- THIS SIGNAL NOW TAKES IN THE ADDRESSES SO WE DONT NEED MORE ROMS
  ---------------------------------------------
  rom_address_big <=
    char_add when empty_space = '0' else
    char_add2 when empty_space2 = '0' and timer_on = '1' and cur_game_state = PLAY else
    "100000";

  rom_address_small <=
    char_add3 when empty_space3 = '0' else
    char_add4 when empty_space4 = '0' else
    "100000";

  item_frame <= "1000" when egg_on = '1' else
    "0111" when coin_on = '1' else
    "1101";

  char_add2 <= std_logic_vector(to_unsigned(timer_tens + 48, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2, 10)) else --"0"
    std_logic_vector(to_unsigned(timer_ones + 48, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 16, 10)) else --"0"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  char_add3                                                                            <= "100000" when empty_space3 = '1'else
    std_logic_vector(to_unsigned(24, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start3, 10)) else --"X"
    std_logic_vector(to_unsigned(48 + to_integer(unsigned(lives)), 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 8, 10))else --"0"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  char_add4                                                               <= "100000" when empty_space4 = '1'else
    std_logic_vector(to_unsigned(24, 6)) when pixel_column                  <= std_logic_vector(to_unsigned(text_start3, 10)) else --"X"
    std_logic_vector(to_unsigned(48 + money_hundreds, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 8, 10))else --"0"
    std_logic_vector(to_unsigned(48 + money_tens, 6)) when pixel_column     <= std_logic_vector(to_unsigned(text_start3 + 16, 10))else --"0"
    std_logic_vector(to_unsigned(48 + money_ones, 6)) when pixel_column     <= std_logic_vector(to_unsigned(text_start3 + 24, 10))else --"0"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  black_line <= '1' when pixel_column = 0 else
    '0';

  -- text_on      <= s_text_on or (s_text_on2 and timer_on) or black_line or s_text_on3; -- or s_text_on2
  s_text_on <= text_big_out or text_small_out or ((egg_on or coin_on) and argb(12));
  text_on   <= s_text_on or black_line when cur_game_state = PLAY or cur_game_state = COLLIDE or cur_game_state = PAUSED else
    '0' or black_line;
  text_rgb_out <= argb(11 downto 0) when (egg_on = '1' or coin_on = '1') else
    r & g & b;

  -- s_text_on_rgb <= (s_text_on & s_text_on & s_text_on & s_text_on) or (s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2) or (s_text_on3 & s_text_on3 & s_text_on3 & s_text_on3);
  s_text_on_rgb <= (others => s_text_on);
  r             <= (s_text_on_rgb and "1111") or (not black_line & not black_line & not black_line & not black_line);
  g             <= (s_text_on_rgb and "1111") or (not black_line & not black_line & not black_line & not black_line);
  b             <= (s_text_on_rgb and "1111") or (not black_line & not black_line & not black_line & not black_line);

  TEXT_BIG : char_rom
  port map
  (
    character_address => rom_address_big,
    font_row          => pixel_row(3 downto 1),
    font_col          => pixel_column(3 downto 1),
    clock             => clk,
    rom_mux_output    => text_big_out
  );

  TEXT_SMALL : char_rom
  port
  map
  (
  character_address => rom_address_small,
  font_row          => pixel_row(2 downto 0),
  font_col          => pixel_column(2 downto 0),
  clock             => clk,
  rom_mux_output    => text_small_out
  );

  SPRITE : abilities_rom
  port
  map(
  clock        => clk,
  frame        => item_frame,
  row          => pixel_row(3 downto 0) - 8,
  col          => pixel_column(3 downto 0) - 8,
  pixel_output => argb
  );
end architecture beh;