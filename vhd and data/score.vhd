library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity score is
	port(
		SIGNAL clk, vert_sync		    : IN std_logic;
		SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		r, g, b 					    : OUT std_logic_vector(3 DOWNTO 0);
		SIGNAL text_on 	            : OUT std_logic	
		);
end entity;

architecture beh of score is

COMPONENT char_rom is
	PORT (
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC
	);
end COMPONENT char_rom;

SIGNAL char_row  : STD_LOGIC_VECTOR(5 downto 0);
SIGNAL char_col  : STD_LOGIC_VECTOR(5 downto 0);
SIGNAL char_add  : STD_LOGIC_VECTOR(5 downto 0);
SIGNAL s_text_on : STD_LOGIC;
SIGNAL empty_space : STD_LOGIC;
SIGNAL text_start : integer := 255; -- welcom begins from pixel row 270
SIGNAL char_width : integer := 16; -- width and height of each pixel (16 x 16 because of font_row and font_col)
-- SIGNAL box_col_start:
-- SIGNAL char_on 	 : STD_LOGIC := '1';

begin


                        -- WORD STARTS AT COL 254 AND ENDS AT COL 380 AND HAS A HEIGHT OF 16 PIXELS BETWEEN ROW 208 AND 222     MAYBE 350 ??
empty_space <= '1' when (pixel_column <= CONV_STD_LOGIC_VECTOR((text_start - char_width),10) or pixel_column >= CONV_STD_LOGIC_VECTOR(318,10)) or ((pixel_row >= CONV_STD_LOGIC_VECTOR(64,10) or pixel_row <= CONV_STD_LOGIC_VECTOR(47,10))) else
			   '0';

char_add <= "100000" when empty_space = '1' else
 				CONV_STD_LOGIC_VECTOR(19,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start ,10) and empty_space = '0' else --"S"
				CONV_STD_LOGIC_VECTOR(3,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 16,10) and empty_space = '0' else --"C"
				CONV_STD_LOGIC_VECTOR(15,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 32,10) and empty_space = '0' else --"O"
				CONV_STD_LOGIC_VECTOR(18,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 48,10) and empty_space = '0' else --"R"
				CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(text_start + 64,10) and empty_space = '0' else --"E"
				"100000"; --CONV_STD_LOGIC_VECTOR(29,6); --" ", IS A BLANK SPACE

text_on <= s_text_on;
r <= ((s_text_on & s_text_on & s_text_on & s_text_on) and "1111");
g <= ((s_text_on & s_text_on & s_text_on & s_text_on) and "1001");
b <= ((s_text_on & s_text_on & s_text_on & s_text_on) and "0000");


text_welcome : char_rom 
port map
(
		character_address => char_add,
		font_row => pixel_row(3 DOWNTO 1), 
        font_col => pixel_column(3 DOWNTO 1),
		clock => clk,
		rom_mux_output => s_text_on
	);

end architecture beh;