LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;


ENTITY grav IS
	PORT
		( pb1, pb2, clk, vert_sync	: IN std_logic;
          mouse                     : IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic);		
END grav;

architecture behavior of grav is

SIGNAL ball_on					: std_logic;
SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0);
SiGNAL ball_x_pos				: std_logic_vector(10 DOWNTO 0);
SIGNAL ball_y_motion			: std_logic_vector(9 DOWNTO 0);

BEGIN           

size <= CONV_STD_LOGIC_VECTOR(10,10);
-- ball_x_pos and ball_y_pos show the (x,y) for the centre of ball
ball_x_pos <= CONV_STD_LOGIC_VECTOR(120,11);

-- determin if ball is on or off
ball_on <= '1' when ( ('0' & ball_x_pos <= '0' & pixel_column + size) and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and ('0' & ball_y_pos <= pixel_row + size) and ('0' & pixel_row <= ball_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			'0';

-- Colours for pixel data on video signal
-- Changing the background and ball colour by pushbuttons
Red <=  pb1;
Green <= (not pb2) and (not ball_on);
Blue <=  not ball_on;


Move_Ball: process (vert_sync)  
variable y_velocity : std_logic_vector (9 downto 0);
variable hold : std_logic;
begin
   -- Move ball once every vertical sync
	if (rising_edge(vert_sync)) then
      -- if mouse clicked
      if (mouse = '1' and hold = '0') then
			hold := '1';
			y_velocity := -CONV_STD_LOGIC_VECTOR(10,10);
      else
			if (y_velocity = "0000001010") then
			    y_velocity := CONV_STD_LOGIC_VECTOR(10,10);
			else 
			    y_velocity := signed(y_velocity) + 1;
			end if;
      end if;
      ball_y_motion <= y_velocity;
      ball_y_pos <= ball_y_pos + ball_y_motion;
		  
		if (mouse = '0') then
			hold := '0';
		end if;
	end if;
end process Move_Ball;

END behavior;