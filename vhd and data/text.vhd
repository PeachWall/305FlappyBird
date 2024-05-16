library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity text is
  port
  (
    signal clk, vert_sync          : in std_logic;
    signal pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    signal score                   : in std_logic_vector(9 downto 0);
    signal mode_m                  : in std_logic;
    signal mode_h                  : in std_logic;
    signal mode_t                  : in std_logic;
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

  signal s_text_on        : std_logic;
  signal char_add         : std_logic_vector(5 downto 0);
  signal empty_space      : std_logic;
  signal r, g, b          : std_logic_vector(3 downto 0);
  constant text_start     : integer := 270; -- welcom begins from pixel row 270
  constant char_width_big : integer := 16; -- width and height of each pixel (16 x 16 because of font_row and font_col)

  signal s_text_on2   : std_logic;
  signal char_add2    : std_logic_vector(5 downto 0);
  signal empty_space2 : std_logic;

  signal black_line         : std_logic;
  constant text_start2      : integer := 23; -- welcom begins from pixel row 20 -- MUST BE A MULTIPLE OF THE CHAR WIDTH
  constant char_width_small : integer := 8; -- width and height of each pixel (8 x 8 because of font_row and font_col)
  -- SIGNAL box_col_start:
  -- SIGNAL char_on 	 : STD_LOGIC := '1';

  signal score_ones, score_tens, score_hundreds : integer range 0 to 9;

begin

  score_ones     <= to_integer(ieee.numeric_std.unsigned(score)) mod 10, 4;
  score_tens     <= to_integer(ieee.numeric_std.unsigned(score)) / 10 mod 10, 4;
  score_hundreds <= to_integer(ieee.numeric_std.unsigned(score)) / 100 mod 10, 4;
  -- WORD STARTS AT COL 254 AND ENDS AT COL 380 AND HAS A HEIGHT OF 16 PIXELS BETWEEN ROW 208 AND 222     MAYBE 350 ??
  empty_space <= '1' when (pixel_column <= CONV_STD_LOGIC_VECTOR((text_start - char_width_big), 10) or pixel_column >= CONV_STD_LOGIC_VECTOR(400, 10)) or ((pixel_row >= CONV_STD_LOGIC_VECTOR(64, 10) or pixel_row <= CONV_STD_LOGIC_VECTOR(47, 10))) else
    '0';

  empty_space2 <= '1' when (pixel_column <= CONV_STD_LOGIC_VECTOR((text_start2 - char_width_small), 10) or pixel_column >= CONV_STD_LOGIC_VECTOR(84, 10)) or ((pixel_row >= CONV_STD_LOGIC_VECTOR(55, 10) or pixel_row <= CONV_STD_LOGIC_VECTOR(47, 10))) else
    '0';

  char_add                                                        <= "100000" when empty_space = '1' else
    CONV_STD_LOGIC_VECTOR(19, 6) when pixel_column                  <= CONV_STD_LOGIC_VECTOR(text_start, 10) and empty_space = '0' else --"S"
    CONV_STD_LOGIC_VECTOR(3, 6) when pixel_column                   <= CONV_STD_LOGIC_VECTOR(text_start + 16, 10) and empty_space = '0' else --"C"
    CONV_STD_LOGIC_VECTOR(15, 6) when pixel_column                  <= CONV_STD_LOGIC_VECTOR(text_start + 32, 10) and empty_space = '0' else --"O"
    CONV_STD_LOGIC_VECTOR(18, 6) when pixel_column                  <= CONV_STD_LOGIC_VECTOR(text_start + 48, 10) and empty_space = '0' else --"R"
    CONV_STD_LOGIC_VECTOR(5, 6) when pixel_column                   <= CONV_STD_LOGIC_VECTOR(text_start + 64, 10) and empty_space = '0' else --"E"
    CONV_STD_LOGIC_VECTOR(58, 6) when pixel_column                  <= CONV_STD_LOGIC_VECTOR(text_start + 80, 10) and empty_space = '0' else --":"
    CONV_STD_LOGIC_VECTOR(score_hundreds + 48, 6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 96, 10) and empty_space = '0' else --"HUNDREDS"
    CONV_STD_LOGIC_VECTOR(score_tens + 48, 6) when pixel_column     <= CONV_STD_LOGIC_VECTOR(text_start + 112, 10) and empty_space = '0' else --"TENS"
    CONV_STD_LOGIC_VECTOR(score_ones + 48, 6) when pixel_column     <= CONV_STD_LOGIC_VECTOR(text_start + 128, 10) and empty_space = '0' else --"ONES"
    "100000"; --CONV_STD_LOGIC_VECTOR(29,6); --" ", IS A BLANK SPACE

  char_add2                                        <= "100000" when empty_space2 = '1' else
    CONV_STD_LOGIC_VECTOR(13, 6) when pixel_column   <= CONV_STD_LOGIC_VECTOR(text_start2, 10) and empty_space2 = '0' else --"M"
    CONV_STD_LOGIC_VECTOR(15, 6) when pixel_column   <= CONV_STD_LOGIC_VECTOR(text_start2 + 8, 10) and empty_space2 = '0' else --"O"
    CONV_STD_LOGIC_VECTOR(4, 6) when pixel_column    <= CONV_STD_LOGIC_VECTOR(text_start2 + 16, 10) and empty_space2 = '0' else --"D"
    CONV_STD_LOGIC_VECTOR(5, 6) when pixel_column    <= CONV_STD_LOGIC_VECTOR(text_start2 + 24, 10) and empty_space2 = '0' else --"E
    CONV_STD_LOGIC_VECTOR(45, 6) when pixel_column   <= CONV_STD_LOGIC_VECTOR(text_start2 + 32, 10) and empty_space2 = '0' else --"-"
    CONV_STD_LOGIC_VECTOR(13, 6) when ((pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 40, 10) and empty_space2 = '0') and (mode_m = '0')) else --"M"
    CONV_STD_LOGIC_VECTOR(8, 6) when ((pixel_column  <= CONV_STD_LOGIC_VECTOR(text_start2 + 40, 10) and empty_space2 = '0') and (mode_h = '0')) else --"H"
    CONV_STD_LOGIC_VECTOR(20, 6) when ((pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 40, 10) and empty_space2 = '0') and (mode_t = '0')) else --"T"
    CONV_STD_LOGIC_VECTOR(5, 6) when ((pixel_column  <= CONV_STD_LOGIC_VECTOR(text_start2 + 40, 10) and empty_space2 = '0')) else --"E"
    "100000"; --CONV_STD_LOGIC_VECTOR(29,6); --" ", IS A BLANK SPACE

  black_line <= '1' when pixel_column = 0 else
    '0';
  -- text_on <= s_text_on2;
  -- r <= (((s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");
  -- g <= (((s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");
  -- b <= (((s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");

  text_on      <= s_text_on or s_text_on2 or black_line;
  text_rgb_out <= r & g & b;
  r            <= (((s_text_on & s_text_on & s_text_on & s_text_on) or (s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111") or (not black_line & not black_line & not black_line & not black_line);
  g            <= (((s_text_on & s_text_on & s_text_on & s_text_on) or (s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111") or (not black_line & not black_line & not black_line & not black_line);
  b            <= (((s_text_on & s_text_on & s_text_on & s_text_on) or (s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111") or (not black_line & not black_line & not black_line & not black_line);
  text_SCORE : char_rom
  port map
  (
    character_address => char_add,
    font_row          => pixel_row(3 downto 1),
    font_col          => pixel_column(3 downto 1),
    clock             => clk,
    rom_mux_output    => s_text_on
  );

  text_MODE : char_rom
  port
  map
  (
  character_address => char_add2,
  font_row          => pixel_row(2 downto 0),
  font_col          => pixel_column(2 downto 0),
  clock             => clk,
  rom_mux_output    => s_text_on2
  );

end architecture beh;