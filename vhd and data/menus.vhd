library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.util.all;

entity menus is
  port
  (
    signal money_in                : in std_logic_vector(7 downto 0);
    signal score                   : in std_logic_vector(9 downto 0);
    signal lives                   : in std_logic_vector(2 downto 0);
    signal clk, vert_sync          : in std_logic;
    signal pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    signal game_state              : in std_logic_vector(3 downto 0);
    signal difficulty              : in std_logic_vector(2 downto 0);
    signal menu_rgb_out            : out std_logic_vector(11 downto 0);
    signal menu_on                 : out std_logic
  );
end entity;

architecture beh of menus is

  component timer_25 is
  port
  (
    clk, reset, enable : in std_logic;
    init_val           : in std_logic_vector(4 downto 0);
    seconds            : out std_logic_vector(4 downto 0);
    timeout            : out std_logic
  );
end component;

  component char_rom is
    port
    (
      character_address  : in std_logic_vector (5 downto 0);
      font_row, font_col : in std_logic_vector (2 downto 0);
      clock              : in std_logic;
      rom_mux_output     : out std_logic
    );
  end component char_rom;

  component title_rom is
    port
    (
      clock        : in std_logic;
      row          : in std_logic_vector(5 downto 0);
      col          : in std_logic_vector(6 downto 0);
      pixel_output : out std_logic_vector(12 downto 0)
    );
  end component;

  signal s_big_text_on                                                             : std_logic;
  signal char_add                                                                  : std_logic_vector(5 downto 0);
  signal empty_space                                                               : std_logic;
  signal r, g, b, r_collided, g_collided, b_collided, r_finish, g_finish, b_finish : std_logic_vector(3 downto 0);
  constant text_start                                                              : integer := 191; -- welcom begins from pixel row 119
  constant char_width_big                                                          : integer := 16; -- width and height of each pixel (24 x 24 because of font_row and font_col)

  signal char_add2       : std_logic_vector(5 downto 0);
  signal s_small_text_on : std_logic;
  signal empty_space2    : std_logic;

  signal black_line         : std_logic;
  constant text_start2      : integer := 271; -- MUST BE A MULTIPLE OF THE CHAR WIDTH -1
  constant char_width_small : integer := 8; -- width and height of each pixel (8 x 8 because of font_row and font_col)

  signal char_add3     : std_logic_vector(5 downto 0);
  signal empty_space3  : std_logic;
  constant text_start3 : integer := 303;

  signal char_add4     : std_logic_vector(5 downto 0);
  signal empty_space4  : std_logic;
  constant text_start4 : integer := 303;

  signal char_add5     : std_logic_vector(5 downto 0);
  signal empty_space5  : std_logic;
  constant text_start5 : integer := 303;

  signal s_try_again_on         : std_logic;
  signal char_add_try_again     : std_logic_vector(5 downto 0);
  signal empty_space_try_again  : std_logic;
  constant text_start_try_again : integer := 255;

  signal s_lives_on         : std_logic;
  signal char_add_lives     : std_logic_vector(5 downto 0);
  signal empty_space_lives  : std_logic;
  constant text_start_lives : integer := 175;

  signal s_finish_on            : std_logic;
  signal char_add_game_over     : std_logic_vector(5 downto 0);
  signal empty_space_game_over  : std_logic;
  constant text_start_game_over : integer := 255;

  signal s_final_score_on         : std_logic_vector(3 downto 0);
  signal char_add_final_score     : std_logic_vector(5 downto 0);
  signal empty_space_final_score  : std_logic;
  constant text_start_final_score : integer := 255;

signal char_add_score     : std_logic_vector(5 downto 0);
signal char_add_coins     : std_logic_vector(5 downto 0);
signal empty_space_score  : std_logic; 
signal empty_space_coins  : std_logic;


  signal s_text_on_rgb               : std_logic_vector(3 downto 0);
  signal s_text_on_rgb_collide_state : std_logic_vector(3 downto 0);

  signal cur_game_state : game_states;
  signal collide_state  : std_logic;
  signal finish_state   : std_logic;

  signal empty_space_pause : std_logic;
  signal char_add_pause    : std_logic_vector(5 downto 0);

  signal score_pop, coin_pop, total_pop : std_logic;
  

  signal score_ones, score_tens, score_hundreds : integer range 0 to 9;
  signal money_ones, money_tens, money_hundreds : integer range 0 to 9;
  signal final_score_ones, final_score_tens, final_score_hundreds : integer range 0 to 9;

  signal empty_space_key0 : std_logic;
  signal empty_space_key1 : std_logic; 

  signal text_start_key0 : integer := 23;
  signal text_start_key1 : integer := 23;

  signal char_add_key0 : std_logic_vector(5 downto 0);
  signal char_add_key1 : std_logic_vector(5 downto 0);


  signal rom_address_big, rom_address_small, rom_address_collide_state, rom_address_finish_state : std_logic_vector(5 downto 0);

  signal title_row, title_col : std_logic_vector(9 downto 0);
  signal title_on             : std_logic;
  signal title_argb           : std_logic_vector(12 downto 0);
  constant title_x_pos        : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(176, 10));
  constant title_y_pos        : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(55, 10));
begin

  -- TIMER FOR THE MENU
  process (vert_sync, cur_game_state)
    variable counter : integer range 0 to 127 := 0;
  begin
    if (cur_game_state = MENU) then
      counter := 0;
      score_pop <= '0';
      coin_pop  <= '0';
      total_pop <= '0';
    elsif (rising_edge(vert_sync)) then
      if (cur_game_state = FINISH) then
        if (counter >= 30) then
          score_pop <= '1';
        end if;

        if (counter >= 60) then
          coin_pop <= '1';
        end if;

        if (counter >= 90) then
          total_pop <= '1';
        end if;

        if (counter <= 127) then
          counter := counter + 1;
        else
          counter := 0;
        end if;
      end if;
    end if;
  end process;

  -- INTEGERS FOR SCORE
  score_ones     <= to_integer(unsigned(score)) mod 10;
  score_tens     <= to_integer(unsigned(score)) / 10 mod 10;
  score_hundreds <= to_integer(unsigned(score)) / 100 mod 10;
  -- INTEGERS FOR MONEY
  money_ones     <= to_integer(unsigned(money_in)) mod 10;
  money_tens     <= to_integer(unsigned(money_in)) / 10 mod 10;
  money_hundreds <= to_integer(unsigned(money_in)) / 100 mod 10;

  final_score_ones      <= to_integer(unsigned(score + money_in)) mod 10;
  final_score_tens     <= to_integer(unsigned(score + money_in)) / 10 mod 10;
  final_score_hundreds <= to_integer(unsigned(score + money_in)) / 100 mod 10;

  cur_game_state <= game_states'val(to_integer(unsigned(game_state)));
  -- multiple of 16                                 -16 from other number
  -- WORD STARTS AT COL 254 AND ENDS AT COL 380 AND HAS A HEIGHT OF 16 PIXELS BETWEEN ROW 208 AND 222     MAYBE 350 ??

  empty_space <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(479, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(272, 10)) or pixel_row < std_logic_vector(to_unsigned(256, 10))))) else
    '0';
  empty_space2 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start3 - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(368, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(296, 10)) or pixel_row < std_logic_vector(to_unsigned(288, 10)))) else
    '0';
  empty_space3 <= '1' when (pixel_column <= std_logic_vector(to_unsigned(text_start3 - char_width_small, 10)) or pixel_column >= std_logic_vector(to_unsigned(335, 10))) or   ((pixel_row >= std_logic_vector(to_unsigned(320, 10)) or pixel_row < std_logic_vector(to_unsigned(312, 10)))) else
    '0';
  empty_space4 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start4 - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(351, 10))) or (pixel_row >= std_logic_vector(to_unsigned(304, 10)) or pixel_row < std_logic_vector(to_unsigned(296, 10))) else
    '0';
  empty_space5 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start5 - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(335, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(312, 10)) or pixel_row < std_logic_vector(to_unsigned(304, 10)))) else
    '0';

  empty_space_try_again <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start_try_again - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(383, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(272, 10)) or pixel_row < std_logic_vector(to_unsigned(256, 10))))) else
    '0';
  empty_space_lives <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start_lives - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(447, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(256, 10)) or pixel_row < std_logic_vector(to_unsigned(240, 10))))) else
    '0';
  empty_space_game_over <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start_game_over - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(383, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(256, 10)) or pixel_row < std_logic_vector(to_unsigned(240, 10))))) else
    '0';
  empty_space_final_score <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start_final_score - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(383, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(304, 10)) or pixel_row < std_logic_vector(to_unsigned(288, 10))))) else
    '0';
  empty_space_score <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start_final_score - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(383, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(272, 10)) or pixel_row < std_logic_vector(to_unsigned(256, 10))))) else
    '0';
  empty_space_coins <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start_final_score - char_width_big), 10)) or pixel_column >= std_logic_vector(to_unsigned(383, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(288, 10)) or pixel_row < std_logic_vector(to_unsigned(272, 10))))) else
    '0';

  empty_space_pause <= '1' when ((pixel_column <= std_logic_vector(to_unsigned((text_start_final_score - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(text_start_final_score + 160, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(448, 10)) or pixel_row < std_logic_vector(to_unsigned(440, 10))))) else
    '0';

    empty_space_key0 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start_key0 - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(87, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(72, 10)) or pixel_row < std_logic_vector(to_unsigned(64, 10)))) else
    '0';
    empty_space_key1 <= '1' when (pixel_column <= std_logic_vector(to_unsigned((text_start_key1 - char_width_small), 10)) or pixel_column >= std_logic_vector(to_unsigned(87, 10))) or ((pixel_row >= std_logic_vector(to_unsigned(80, 10)) or pixel_row < std_logic_vector(to_unsigned(72, 10)))) else
    '0';


  -- MUX TO CHOOSE THE ADDRESS
  rom_address_big <= char_add when empty_space = '0' else
    "100000";

  rom_address_collide_state <=
    char_add_try_again when empty_space_try_again = '0' else
    char_add_lives when empty_space_lives = '0' else
    "100000";

  rom_address_finish_state <=
    char_add_game_over when empty_space_game_over = '0' else
    char_add_score when empty_space_score = '0' and score_pop = '1' else
    char_add_coins when empty_space_coins = '0' and coin_pop = '1'  else
    char_add_final_score when empty_space_final_score = '0' and total_pop = '1'  else
    "100000";

  rom_address_small <=
    char_add_key0 when empty_space_key0 = '0' and cur_game_state = MENU else
    char_add_key1 when empty_space_key1 = '0' and cur_game_state = MENU else
    char_add2 when empty_space2 = '0' and cur_game_state = MENU else
    char_add3 when empty_space3 = '0' and cur_game_state = MENU else
    char_add_pause when empty_space_pause = '0' and cur_game_state = PAUSED else
    char_add4 when empty_space4 = '0' and cur_game_state = MENU else
    char_add5 when empty_space5 = '0' and cur_game_state = MENU else
    "100000";

  title_on <= '1' when pixel_column >= title_x_pos and pixel_column < title_x_pos + 256 and pixel_row >= title_y_pos and pixel_row < title_y_pos + 128 else
    '0';

  -- MAIN MENU --
  -- TODO: REALGIN THE DIFFICULTIES ON CENTER AND ADD EASY MEDIUM HARD. MAP IT TO A KEY.--------- done!!!!!!!
  -- TODO: ADD MENU FOR COLLISION STATE. SHOW LIVES AND STUFF------------------------------- working on
  -- TODO: SHOW GAMEMOVER SCREEN on FINISH STATE. SHOW GAME OVER AND PRESS LEFT BUTTON TO GO BACK TO MENU

    char_add_key0 <= 
    std_logic_vector(to_unsigned(11, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key0, 10)) and empty_space_key0 = '0' else --"K"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key0 + 8, 10)) and empty_space_key0 = '0' else --"E"
    std_logic_vector(to_unsigned(25, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start_key0 + 16, 10)) and empty_space_key0 = '0' else --"Y"
    std_logic_vector(to_unsigned(48, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start_key0 + 24, 10)) and empty_space_key0 = '0' else --"0
    std_logic_vector(to_unsigned(45, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key0 + 32, 10)) and empty_space_key0 = '0' else --"-"
    std_logic_vector(to_unsigned(16, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key0 + 40, 10)) and empty_space_key0 = '0' else --"P"
    std_logic_vector(to_unsigned(12, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key0 + 48, 10)) and empty_space_key0 = '0' else --"L"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start_key0 + 56, 10)) and empty_space_key0 = '0' else --"A"
    std_logic_vector(to_unsigned(25, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start_key0 + 72, 10)) and empty_space_key0 = '0' else --"Y
    "100000";

    char_add_key1 <= 
    std_logic_vector(to_unsigned(11, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key1, 10)) and empty_space_key1 = '0' else --"K"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key1 + 8, 10)) and empty_space_key1 = '0' else --"E"
    std_logic_vector(to_unsigned(25, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start_key1 + 16, 10)) and empty_space_key1 = '0' else --"Y"
    std_logic_vector(to_unsigned(49, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start_key1 + 24, 10)) and empty_space_key1 = '0' else --"1
    std_logic_vector(to_unsigned(45, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key1 + 32, 10)) and empty_space_key1 = '0' else --"-"
    std_logic_vector(to_unsigned(13, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key1 + 40, 10)) and empty_space_key1 = '0' else --"M"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column   <= std_logic_vector(to_unsigned(text_start_key1 + 48, 10)) and empty_space_key1 = '0' else --"O"
    std_logic_vector(to_unsigned(4, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start_key1 + 56, 10)) and empty_space_key1 = '0' else --"D"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column    <= std_logic_vector(to_unsigned(text_start_key1 + 72, 10)) and empty_space_key1 = '0' else --"E
    "100000";

  char_add                                               <=
    std_logic_vector(to_unsigned(2, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start, 10)) else --"B"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 16, 10)) else --"I"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 32, 10)) else --"R"
    std_logic_vector(to_unsigned(4, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 48, 10)) else --"D"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 64, 10)) else --" "
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 80, 10)) else --"I"
    std_logic_vector(to_unsigned(19, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 96, 10)) else --"S"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 112, 10)) else --" "
    std_logic_vector(to_unsigned(20, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 128, 10)) else --"T"
    std_logic_vector(to_unsigned(8, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 144, 10)) else --"H"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 160, 10)) else --"E"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 176, 10)) else --" "
    std_logic_vector(to_unsigned(23, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 192, 10)) else --"W"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 208, 10)) else --"O"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start + 224, 10)) else --"R"
    std_logic_vector(to_unsigned(4, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start + 240, 10)) else --"D"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  char_add2                                              <=
    std_logic_vector(to_unsigned(20, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3, 10)) else --"T"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 8, 10)) else --"R"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 16, 10)) else --"A"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 24, 10)) else --"I"
    std_logic_vector(to_unsigned(14, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 32, 10)) else --"N"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 40, 10)) else --"I"
    std_logic_vector(to_unsigned(14, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 48, 10)) else --"N"
    std_logic_vector(to_unsigned(7, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 56, 10)) else --"G"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  -- char_add3                                              <=
  --   std_logic_vector(to_unsigned(11, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3, 10)) else --"K"
  --   std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start3 + 8, 10)) else --"E"
  --   std_logic_vector(to_unsigned(25, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 16, 10)) else --"Y"
  --   std_logic_vector(to_unsigned(48, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 24, 10)) else --"0"
  --   std_logic_vector(to_unsigned(45, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start3 + 32, 10)) else --"-"
  --   std_logic_vector(to_unsigned(16, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 40, 10)) else --"P"
  --   std_logic_vector(to_unsigned(12, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 48, 10)) else --"L"
  --   std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start2 + 56, 10)) else --"A"
  --   std_logic_vector(to_unsigned(25, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start2 + 64, 10)) else --"Y"
  --   "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  char_add4                                              <=
    std_logic_vector(to_unsigned(14, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start4, 10)) else --"N"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start4 + 8, 10)) else --"O"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start4 + 16, 10)) else --"R"
    std_logic_vector(to_unsigned(13, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start4 + 24, 10)) else --"M"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start4 + 32, 10)) else --"A"
    std_logic_vector(to_unsigned(12, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start4 + 40, 10)) else --"L"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  char_add5                                              <=
    std_logic_vector(to_unsigned(8, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start5, 10)) else --"H"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start5 + 8, 10)) else --"A"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start5 + 16, 10)) else --"R"
    std_logic_vector(to_unsigned(4, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start5 + 24, 10)) else --"D"
  "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  -- BLACK LINE
  black_line <= '1' when pixel_column = 0 else
    '0';

  -- COLLIDE STATE TEXT ------------------------------------------------------------------------------------------------------
  char_add_try_again                                     <=
    std_logic_vector(to_unsigned(20, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_try_again, 10)) else --"T"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_try_again + 16, 10)) else --"R"
    std_logic_vector(to_unsigned(25, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_try_again + 32, 10)) else --"Y"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_try_again + 48, 10)) else --" "
    std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_try_again + 64, 10)) else --"A"
    std_logic_vector(to_unsigned(7, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_try_again + 80, 10)) else --"G"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_try_again + 96, 10)) else --"A"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_try_again + 112, 10)) else --"I"
    std_logic_vector(to_unsigned(14, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_try_again + 128, 10)) else --"N"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  char_add_lives                                                                       <=
    std_logic_vector(to_unsigned(5, 6)) when pixel_column                                <= std_logic_vector(to_unsigned(text_start_lives, 10)) else --"E"
    std_logic_vector(to_unsigned(24, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 16, 10)) else --"X"
    std_logic_vector(to_unsigned(20, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 32, 10)) else --"T"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 48, 10)) else --"R"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column                                <= std_logic_vector(to_unsigned(text_start_lives + 64, 10)) else --"A"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 80, 10)) else --" "
    std_logic_vector(to_unsigned(12, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 96, 10)) else --"L"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column                                <= std_logic_vector(to_unsigned(text_start_lives + 112, 10)) else --"I"
    std_logic_vector(to_unsigned(22, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 128, 10)) else --"V"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column                                <= std_logic_vector(to_unsigned(text_start_lives + 144, 10)) else --"E"
    std_logic_vector(to_unsigned(19, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 160, 10)) else --"S"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 176, 10)) else --" "
    std_logic_vector(to_unsigned(12, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 192, 10)) else --"L"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column                                <= std_logic_vector(to_unsigned(text_start_lives + 208, 10)) else --"E"
    std_logic_vector(to_unsigned(6, 6)) when pixel_column                                <= std_logic_vector(to_unsigned(text_start_lives + 224, 10)) else --"F"
    std_logic_vector(to_unsigned(20, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 240, 10)) else --"T"
    std_logic_vector(to_unsigned(58, 6)) when pixel_column                               <= std_logic_vector(to_unsigned(text_start_lives + 256, 10)) else --":"
    std_logic_vector(to_unsigned(39, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_lives + 272, 10)) and difficulty = "001" else --"infinity"
    std_logic_vector(to_unsigned(48 + to_integer(unsigned(lives)), 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_lives + 272, 10)) else --"0"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  -- PASUED STATE TEXT ----------------------------------------------------------------------------------------------------

  char_add_pause                                         <=
    std_logic_vector(to_unsigned(12, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score, 10)) else --"L"
    std_logic_vector(to_unsigned(13, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 8, 10)) else --"M"
    std_logic_vector(to_unsigned(2, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_final_score + 16, 10)) else --"B"
    std_logic_vector(to_unsigned(45, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 24, 10)) else --"-"
    std_logic_vector(to_unsigned(16, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 32, 10)) else --"P"
    std_logic_vector(to_unsigned(12, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 40, 10)) else --"L"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_final_score + 48, 10)) else --"A"
    std_logic_vector(to_unsigned(25, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 56, 10)) else --"Y"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 64, 10)) else --" "
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 72, 10)) else --" "
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 80, 10)) else --" "
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 88, 10)) else --" "
    std_logic_vector(to_unsigned(11, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 96, 10)) else --"K"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_final_score + 104, 10)) else --"E"
    std_logic_vector(to_unsigned(25, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 112, 10)) else --"Y"
    std_logic_vector(to_unsigned(48, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 120, 10)) else --"0"
    std_logic_vector(to_unsigned(45, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 128, 10)) else --"-"
    std_logic_vector(to_unsigned(13, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 136, 10)) else --"M"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_final_score + 144, 10)) else --"E"
    std_logic_vector(to_unsigned(14, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 152, 10)) else --"N"
    std_logic_vector(to_unsigned(21, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 160, 10)) else --"U"
    "100000";

  -- FINSIH STATE TEXT ----------------------------------------------------------------------------------------------------
  char_add_game_over                                     <=
    std_logic_vector(to_unsigned(7, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_game_over, 10)) else --"G"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_game_over + 16, 10)) else --"A"
    std_logic_vector(to_unsigned(13, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_game_over + 32, 10)) else --"M"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_game_over + 48, 10)) else --"E"
    std_logic_vector(to_unsigned(32, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_game_over + 64, 10)) else --" "
    std_logic_vector(to_unsigned(15, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_game_over + 80, 10)) else --"O"
    std_logic_vector(to_unsigned(22, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_game_over + 96, 10)) else --"V"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column  <= std_logic_vector(to_unsigned(text_start_game_over + 112, 10)) else --"E"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_game_over + 128, 10)) else --"R"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE


  char_add_coins                                                                     <=
    std_logic_vector(to_unsigned(3, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score, 10)) else --"C"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column                                    <= std_logic_vector(to_unsigned(text_start_final_score + 16, 10)) else --"O"
    std_logic_vector(to_unsigned(9, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 32, 10)) else --"I"
    std_logic_vector(to_unsigned(14, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 48, 10)) else --"N"
    std_logic_vector(to_unsigned(19, 6)) when pixel_column                                    <= std_logic_vector(to_unsigned(text_start_final_score + 64, 10)) else --"S"
    std_logic_vector(to_unsigned(58, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 80, 10)) else --":"
    std_logic_vector(to_unsigned(48 + money_hundreds, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 96, 10)) else --"hundreds"
    std_logic_vector(to_unsigned(48 + money_tens, 6)) when pixel_column         <= std_logic_vector(to_unsigned(text_start_final_score + 112, 10)) else --"tens"
    std_logic_vector(to_unsigned(48 + money_ones, 6)) when pixel_column         <= std_logic_vector(to_unsigned(text_start_final_score + 128, 10)) else --"ones"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  char_add_score                                                                     <=
    std_logic_vector(to_unsigned(19, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score, 10)) else --"S"
    std_logic_vector(to_unsigned(3, 6)) when pixel_column                                    <= std_logic_vector(to_unsigned(text_start_final_score + 16, 10)) else --"C"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 32, 10)) else --"O"
    std_logic_vector(to_unsigned(18, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 48, 10)) else --"R"
    std_logic_vector(to_unsigned(5, 6)) when pixel_column                                    <= std_logic_vector(to_unsigned(text_start_final_score + 64, 10)) else --"E"
    std_logic_vector(to_unsigned(58, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 80, 10)) else --":"
    std_logic_vector(to_unsigned(48 + score_hundreds, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 96, 10)) else --"hundreds"
    std_logic_vector(to_unsigned(48 + score_tens, 6)) when pixel_column         <= std_logic_vector(to_unsigned(text_start_final_score + 112, 10)) else --"tens"
    std_logic_vector(to_unsigned(48 + score_ones, 6)) when pixel_column         <= std_logic_vector(to_unsigned(text_start_final_score + 128, 10)) else --"ones"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE


  -- char_add_final_score
  char_add_final_score                                                                     <=
    std_logic_vector(to_unsigned(20, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score, 10)) else --"T"
    std_logic_vector(to_unsigned(15, 6)) when pixel_column                                    <= std_logic_vector(to_unsigned(text_start_final_score + 16, 10)) else --"O"
    std_logic_vector(to_unsigned(20, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 32, 10)) else --"T"
    std_logic_vector(to_unsigned(1, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 48, 10)) else --"A"
    std_logic_vector(to_unsigned(12, 6)) when pixel_column                                    <= std_logic_vector(to_unsigned(text_start_final_score + 64, 10)) else --"L"
    std_logic_vector(to_unsigned(58, 6)) when pixel_column                                   <= std_logic_vector(to_unsigned(text_start_final_score + 80, 10)) else --":"
    std_logic_vector(to_unsigned(48 + final_score_hundreds, 6)) when pixel_column <= std_logic_vector(to_unsigned(text_start_final_score + 96, 10)) else --"hundreds"
    std_logic_vector(to_unsigned(48 + final_score_tens, 6)) when pixel_column         <= std_logic_vector(to_unsigned(text_start_final_score + 112, 10)) else --"tens"
    std_logic_vector(to_unsigned(48 + final_score_ones, 6)) when pixel_column         <= std_logic_vector(to_unsigned(text_start_final_score + 128, 10)) else --"ones"
    "100000"; --std_logic_vector(to_unsigned(29,6)); --" ", IS A BLANK SPACE

  s_text_on_rgb <= (s_big_text_on & s_big_text_on & s_big_text_on & s_big_text_on) or (s_small_text_on & s_small_text_on & s_small_text_on & s_small_text_on);
  r             <= ((s_text_on_rgb or (black_line & black_line & black_line & black_line)) and "1111") or title_argb(11 downto 8);
  g             <= ((s_text_on_rgb or (black_line & black_line & black_line & black_line)) and "1111") or title_argb(7 downto 4);
  b             <= ((s_text_on_rgb or (black_line & black_line & black_line & black_line)) and "1111") or title_argb(3 downto 0);
  

  s_text_on_rgb_collide_state <= (s_try_again_on & s_try_again_on & s_try_again_on & s_try_again_on) or (s_lives_on & s_lives_on & s_lives_on & s_lives_on);
  r_collided                  <= s_text_on_rgb_collide_state;
  g_collided                  <= s_text_on_rgb_collide_state;
  b_collided                  <= s_text_on_rgb_collide_state;

  menu_on <= (s_small_text_on or s_big_text_on or (title_on and title_argb(12))) when cur_game_state = MENU else
    -- '1' when cur_game_state = FINISH else
    s_finish_on when cur_game_state = FINISH else
    s_try_again_on when cur_game_state = COLLIDE else
    s_small_text_on when cur_game_state = PAUSED else
    '0';

  menu_rgb_out <=
  "111111010011" when cur_game_state = MENU and ((difficulty = "001") and empty_space2 = '0') else -- training
  "111111010011" when cur_game_state = MENU and ((difficulty = "010") and empty_space4 = '0') else -- normal
  "111111010011" when cur_game_state = MENU and ((difficulty = "100") and empty_space5 = '0') else -- hard
    r_collided & g_collided & b_collided when cur_game_state = COLLIDE else
    r & g & b when cur_game_state /= FINISH or cur_game_state = PAUSED else
    r_collided & g_collided & b_collided;
  -- "000000000000";

  title_row <= pixel_row - title_y_pos;
  title_col <= pixel_column - title_x_pos;

  TEXT_BIG : char_rom
  port map
  (
    character_address => rom_address_big,
    font_row          => pixel_row(3 downto 1),
    font_col          => pixel_column(3 downto 1),
    clock             => clk,
    rom_mux_output    => s_big_text_on
  );

  text_NORMALPLAY : char_rom
  port
  map
  (
  character_address => rom_address_small,
  font_row          => pixel_row(2 downto 0),
  font_col          => pixel_column(2 downto 0),
  clock             => clk,
  rom_mux_output    => s_small_text_on
  );

  MENU_TITLE : title_rom
  port
  map(
  clock        => clk,
  row          => title_row(6 downto 1),
  col          => title_col(7 downto 1),
  pixel_output => title_argb
  );
  TEXT_BIG_COLLIDE_STATE : char_rom
  port
  map
  (
  character_address => rom_address_collide_state,
  font_row          => pixel_row(3 downto 1),
  font_col          => pixel_column(3 downto 1),
  clock             => clk,
  rom_mux_output    => s_try_again_on
  );

  TEXT_BIG_FINISH_STATE : char_rom
  port
  map
  (
  character_address => rom_address_finish_state,
  font_row          => pixel_row(3 downto 1),
  font_col          => pixel_column(3 downto 1),
  clock             => clk,
  rom_mux_output    => s_finish_on
  );

end architecture beh;