library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity text is
	port(
		SIGNAL clk, vert_sync		    : IN std_logic;
		SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		SIGNAL mode_m					: IN std_logic;
		SIGNAL mode_h					: IN std_logic;
		SIGNAL mode_t					: IN std_logic;
		r, g, b 					    : OUT std_logic_vector(3 DOWNTO 0);
		SIGNAL text_on 	            : OUT std_logic
		);
end entity;

architecture beh of text is

COMPONENT char_rom is
	PORT (
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC
	);
end COMPONENT char_rom;

SIGNAL s_text_on : STD_LOGIC;
SIGNAL char_add  : STD_LOGIC_VECTOR(5 downto 0);
SIGNAL empty_space : STD_LOGIC;
SIGNAL text_start : integer := 270; -- welcom begins from pixel row 270
SIGNAL char_width : integer := 16; -- width and height of each pixel (16 x 16 because of font_row and font_col)

SIGNAL s_text_on2 : STD_LOGIC;
SIGNAL char_add2  : STD_LOGIC_VECTOR(5 downto 0);
SIGNAL empty_space2 : STD_LOGIC;
SIGNAL text_start2 : integer := 23; -- welcom begins from pixel row 20 -- MUST BE A MULTIPLE OF THE CHAR WIDTH
SIGNAL char_width2 : integer := 8; -- width and height of each pixel (8 x 8 because of font_row and font_col)
-- SIGNAL box_col_start:
-- SIGNAL char_on 	 : STD_LOGIC := '1';

begin


                        -- WORD STARTS AT COL 254 AND ENDS AT COL 380 AND HAS A HEIGHT OF 16 PIXELS BETWEEN ROW 208 AND 222     MAYBE 350 ??
empty_space <= '1' when (pixel_column <= CONV_STD_LOGIC_VECTOR((text_start - char_width),10) or pixel_column >= CONV_STD_LOGIC_VECTOR(382,10)) or ((pixel_row >= CONV_STD_LOGIC_VECTOR(64,10) or pixel_row <= CONV_STD_LOGIC_VECTOR(47,10))) else
			   '0';

empty_space2 <= '1' when (pixel_column <= CONV_STD_LOGIC_VECTOR((text_start2 - char_width),10) or pixel_column >= CONV_STD_LOGIC_VECTOR(84,10)) or ((pixel_row >= CONV_STD_LOGIC_VECTOR(55,10) or pixel_row <= CONV_STD_LOGIC_VECTOR(47,10))) else
			   '0';

char_add <= "100000" when empty_space = '1' else
 				CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start ,10) and empty_space = '0' else --"S"
				CONV_STD_LOGIC_VECTOR(3,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 16,10) and empty_space = '0' else --"C"
				CONV_STD_LOGIC_VECTOR(15,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 32,10) and empty_space = '0' else --"O"
				CONV_STD_LOGIC_VECTOR(18,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 48,10) and empty_space = '0' else --"R"
				CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 64,10) and empty_space = '0' else --"E"
				CONV_STD_LOGIC_VECTOR(58,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 80,10) and empty_space = '0' else --":"
				CONV_STD_LOGIC_VECTOR(48,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 96,10) and empty_space = '0' else --"0"
				CONV_STD_LOGIC_VECTOR(48,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 112,10) and empty_space = '0' else --"0"
				"100000"; --CONV_STD_LOGIC_VECTOR(29,6); --" ", IS A BLANK SPACE

char_add2 <= "100000" when empty_space2 = '1' else
 				CONV_STD_LOGIC_VECTOR(13,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 ,10) and empty_space2 = '0' else --"M"
				CONV_STD_LOGIC_VECTOR(15,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 8,10) and empty_space2 = '0' else --"O"
				CONV_STD_LOGIC_VECTOR(4,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 16,10) and empty_space2 = '0' else --"D"
				CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 24,10) and empty_space2 = '0' else --"E
				CONV_STD_LOGIC_VECTOR(45,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 32,10) and empty_space2 = '0' else --"-"
				CONV_STD_LOGIC_VECTOR(13,6) when ((pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 40,10) and empty_space2 = '0') and (mode_m = '0')) else --"M"
				CONV_STD_LOGIC_VECTOR(8,6) when ((pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 40,10) and empty_space2 = '0') and (mode_h = '0')) else --"H"
				CONV_STD_LOGIC_VECTOR(20,6) when ((pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 40,10) and empty_space2 = '0') and (mode_t = '0')) else --"T"
				CONV_STD_LOGIC_VECTOR(5,6) when ((pixel_column <= CONV_STD_LOGIC_VECTOR(text_start2 + 40,10) and empty_space2 = '0')) else --"E"
				"100000"; --CONV_STD_LOGIC_VECTOR(29,6); --" ", IS A BLANK SPACE

-- text_on <= s_text_on2;
-- r <= (((s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");
-- g <= (((s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");
-- b <= (((s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");

text_on <= s_text_on or s_text_on2;
r <= (((s_text_on & s_text_on & s_text_on & s_text_on) or (s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");
g <= (((s_text_on & s_text_on & s_text_on & s_text_on) or (s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");
b <= (((s_text_on & s_text_on & s_text_on & s_text_on) or (s_text_on2 & s_text_on2 & s_text_on2 & s_text_on2)) and "1111");


text_SCORE : char_rom 
port map
(
		character_address => char_add,
		font_row => pixel_row(3 DOWNTO 1), 
        font_col => pixel_column(3 DOWNTO 1),
		clock => clk,
		rom_mux_output => s_text_on
	);

text_MODE : char_rom 
port map
(
		character_address => char_add2,
		font_row => pixel_row(2 DOWNTO 0), 
        font_col => pixel_column(2 DOWNTO 0),
		clock => clk,
		rom_mux_output => s_text_on2
	);

end architecture beh;