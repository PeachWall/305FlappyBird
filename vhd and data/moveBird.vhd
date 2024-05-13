library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
entity moveBird is
  port
  (
    clk, vert_sync : in std_logic;
    mouse          : in std_logic;
    collided       : in std_logic;
    move_x         : out std_logic_vector(9 downto 0);
    move_y         : out std_logic_vector(9 downto 0)
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
    variable hold       : std_logic;
  begin
    -- Move ball once every vertical sync
    if (rising_edge(vert_sync)) then
      -- if mouse clicked
      if (mouse = '1' and hold = '0') then
        hold       := '1';
        y_velocity := - CONV_STD_LOGIC_VECTOR(32, 10);
      else
        if (y_velocity >= CONV_STD_LOGIC_VECTOR(16 * gravity, 10)) then
          y_velocity := CONV_STD_LOGIC_VECTOR(16 * gravity, 10);
        else
          y_velocity := signed(y_velocity) + gravity;
        end if;
      end if;
      ball_y_pos <= ball_y_pos + y_velocity(9 downto 2);

      -- check if ball is at the floor or at ceiling
      if( ball_y_pos >= CONV_STD_LOGIC_VECTOR(440, 10)) then
        ball_y_pos := CONV_STD_LOGIC_VECTOR(472, 10);
      elsei if (ball_y_pos <= CONV_STD_LOGIC_VECTOR(0, 10)) then
        ball_y_pos := CONV_STD_LOGIC_VECTOR(0, 10);
        y_velocity := 0;
      end if;

      if (mouse = '0') then
        hold := '0';
      end if;
    end if;
  end process Move_Ball;
end behavior;