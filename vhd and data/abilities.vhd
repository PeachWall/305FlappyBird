library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity abilities is
  port
  (
    vsync                        : in std_logic;
    speed                        : in std_logic_vector(2 downto 0);
    pipe_reset                  : in std_logic;
    pixel_row, pixel_column : in std_logic_vector(9 downto 0);
    pipe1_x_in                  : in std_logic_vector(10 downto 0);
    ability1_type                : out std_logic_vector(2 downto 0);
    r,g,b                       : out std_logic_vector(3 downto 0);
    ability1_on                  : out std_logic
  );
end entity abilities;

architecture beh of abilities is
SIGNAL ability_width : integer := 16;
-- SIGNAL ability1_x_pos : std_logic_vector(10 downto 0);

SIGNAL ability_relative_x_pos : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(to_integer(unsigned(pipe1_x_in)) + 200 ,11));
SIGNAL ability1_x_pos : std_logic_vector(10 downto 0):= std_logic_vector(to_unsigned(639, 11));
SIGNAL ability1_y_pos : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(200, 11));
SIGNAL ability_reset : std_logic := '0';
-- SIGNAL random_height  : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(200, 11));

component random_gen is
    port
    (
      clk, reset, enable : in std_logic;
      Q                  : out ieee.numeric_std.signed(7 downto 0)
    );
  end component;

begin

  ability_reset <= '1' when (ability) else '0';

process(vsync)
begin
  if rising_edge(vsync) then
    if (ability_reset = '1')then
      ability1_x_pos <= ability_relative_x_pos;
      end if;

    ability1_x_pos <= (ability1_x_pos - to_integer(unsigned(speed)));
    end if;

    -- if (ability1_x_pos < std_logic_vector(to_unsigned(60,11))) then
    --   ability1_x_pos <= (ability1_x_pos - to_integer(unsigned(speed)));
    --   else
    --   ability1_x_pos <= ability_relative_x_pos;
    -- end if;
  
    if(ability1_x_pos < 0) then
      ability1_x_pos <= std_logic_vector(to_unsigned(to_integer(unsigned(pipe1_x_in)), 11));
    end if;

      if (ability1_x_pos <= - ability_width) then
        ability1_x_pos <= std_logic_vector(to_unsigned(639, 11));
    end if;

  end process;







                                                                                -- -170
  -- ability1_x_pos <= std_logic_vector(to_unsigned(to_integer(unsigned(pipe1_x_in)) + 200, 11)); -- else
                    -- (ability1_x_pos - to_integer(unsigned(speed))) when (pipe_passed ='1' and rising_edge(vsync));-- when the pipe 'disappears' we lose our ability1_x_pos so need to account for that

                    -- height_randomiser : process(pipe1_x_in)
                    -- variable random_height : integer range -480 to 480 := 200;
                    -- begin
                    --   if (pipe1_x_in < std_logic_vector(to_unsigned(1, 11))) then
                    --     ability1_y_pos <= std_logic_vector(to_unsigned(random_height, 11));
                    --     end if;
                    -- end process;

                    -- height_gen: random_gen port map(clk => pipe_reset, reset  => '0', enable => '1', Q => random_height);
process(vsync)
begin
  if rising_edge(vsync) then

    if ()
    ability1_x_pos <= (ability1_x_pos - to_integer(unsigned(speed)));
    end if;

    -- if (ability1_x_pos < std_logic_vector(to_unsigned(60,11))) then
    --   ability1_x_pos <= (ability1_x_pos - to_integer(unsigned(speed)));
    --   else
    --   ability1_x_pos <= ability_relative_x_pos;
    -- end if;
  
    if(ability1_x_pos < 0) then
      ability1_x_pos <= std_logic_vector(to_unsigned(to_integer(unsigned(pipe1_x_in)), 11));
    end if;

      if (ability1_x_pos <= - ability_width) then
        ability1_x_pos <= std_logic_vector(to_unsigned(639, 11));
    end if;

  end process;
                    
    

  ability1_on <= '1' when  ((pixel_row >= ability1_y_pos and pixel_row < ability1_y_pos + ability_width) and (pixel_column >= ability1_x_pos and pixel_column <= ability1_x_pos + ability_width)) else 
  '0';
  
  r <= "0000";
  g <= "0000";
  b <= "0000";
end architecture;