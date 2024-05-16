library IEEE;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity moveBird is
  port
  (
    clk, vert_sync     : in std_logic;
    mouse              : in std_logic;
    collided           : in std_logic;
    move_x, move_y     : out std_logic_vector(9 downto 0);
  );
end moveBird;

architecture behavior of moveBird is
  signal ball_on    : std_logic;
  signal ball_y_pos : std_logic_vector(9 downto 0);
  signal ball_x_pos : std_logic_vector(9 downto 0);

  constant gravity : integer := 2;

begin
  move_x <= ball_x_pos;
  move_y <= ball_y_pos;

  Move_Ball : process (vert_sync)
    variable y_velocity : std_logic_vector (9 downto 0);
    variable hold       : std_logic:= '0';
  begin
    -- Move ball once every vertical sync
    if (rising_edge(vert_sync)) then
      -- if mouse clicked
      if (mouse = '1' and hold = '0') then
        hold       := '1';
        y_velocity := std_logic_vector(to_signed(32, 10));
      else
        if (y_velocity >= std_logic_vector(to_signed(16 * gravity, 10))) then
          y_velocity := std_logic_vector(to_signed(16 * gravity, 10));
        else
          y_velocity := std_logic_vector(signed(y_velocity) + gravity);
        end if;
      end if;
      ball_y_pos <= ball_y_pos + y_velocity(9 downto 2);

      -- check if ball is at the floor or at ceiling
      if( ball_y_pos >= std_logic_vector(to_unsigned(440, 10))) then
        ball_y_pos <= std_logic_vector(to_unsigned(472, 10));
        y_velocity := std_logic_vector(to_unsigned(0,10));
      elsif (ball_y_pos <= std_logic_vector(to_unsigned(0, 10))) then
        ball_y_pos <= std_logic_vector(to_unsigned(0, 10));
        y_velocity := std_logic_vector(to_unsigned(0,10));
      end if;

      if (mouse = '0') then
        hold := '0';
      end if;

    end if;
  end process Move_Ball;

end behavior;