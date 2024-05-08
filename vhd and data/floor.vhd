LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;


ENTITY floor IS
	PORT
		(clk, vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic_vector(3 downto 0));		
END floor;

architecture behavior of floor is

SIGNAL floor_on					: std_logic;
SIGNAL size_x 					: std_logic_vector(9 DOWNTO 0);
SIGNAL size_y 					: std_logic_vector(9 DOWNTO 0);    
SIGNAL floor_y_pos				: std_logic_vector(9 DOWNTO 0);
SiGNAL floor_x_pos				: std_logic_vector(10 DOWNTO 0);

BEGIN           

size_x <= CONV_STD_LOGIC_VECTOR(639,10);
size_y <= CONV_STD_LOGIC_VECTOR(420,10);
-- floor_x_pos and floor_y_pos show the (x,y) for top left corner of the floor
--floor_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
--floor_y_pos <= CONV_STD_LOGIC_VECTOR(30,10);

floor_on <= '1' when ( ('0' & pixel_row >= '0' & size_y) and ('0' & pixel_column <= '0' & size_x))
				else
			'0';

-- determine if floor is on or off
-- floor_on <= '1' when ( ('0' & floor_x_pos <= '0' & pixel_column + size) and ('0' & pixel_column <= '0' & floor_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
-- 					and ('0' & floor_y_pos <= pixel_row + size) and ('0' & pixel_row <= floor_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
-- 			'0';

-- Colours for pixel data on video signal
-- Changing the background and ball colour by pushbuttons

-- should be brown colour
red <=  "0110" when floor_on = '1' else "0000";
green <= "0011" when floor_on = '1' else "0000";
blue <=  "0000" when floor_on = '1' else "0000";

END behavior;