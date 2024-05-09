LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;


ENTITY moveBird IS
	PORT
		(
		  clk, vert_sync	: IN std_logic;
        mouse                     : IN std_logic;
		  move_x   : OUT std_logic_vector(9 DOWNTO 0);
		  move_y			: OUT std_logic_vector(9 DOWNTO 0)
		);
END moveBird;

architecture behavior of moveBird is

SIGNAL ball_on					: std_logic;
SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0);
SiGNAL ball_x_pos				: std_logic_vector(9 DOWNTO 0);
SIGNAL ball_y_motion			: std_logic_vector(9 DOWNTO 0);

BEGIN           

size <= CONV_STD_LOGIC_VECTOR(10,10);
-- ball_x_pos and ball_y_pos show the (x,y) for the centre of ball
ball_x_pos <= CONV_STD_LOGIC_VECTOR(120,10);

move_x <= ball_x_pos;
move_y <= ball_y_pos;

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
			if (y_velocity = CONV_STD_LOGIC_VECTOR(8,10)) then
			    y_velocity := CONV_STD_LOGIC_VECTOR(8,10);
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