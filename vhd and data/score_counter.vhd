library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.util.all;


entity score_counter is
  port
  (
    count                            : in std_logic;
    game_state              : in std_logic_vector(3 downto 0);
    ones_out, tens_out, hundreds_out : out std_logic_vector(6 downto 0);
    points                           : out std_logic_vector(9 downto 0)
  );
end entity score_counter;

architecture arch of score_counter is
  signal score : integer := 0;
  signal cur_game_state : game_states;

  component three_digi_seg is
    port
    (
      input_num            : in std_logic_vector(9 downto 0);
      ones, tens, hundreds : out std_logic_vector(6 downto 0)
    );
  end component;

begin

  cur_game_state <= game_states'val(to_integer(unsigned(game_state)));

  process (count, cur_game_state)
    variable counter : integer range 0 to 999;
  begin
    if cur_game_state = MENU then
      counter := 0; -- when we go to menu, want to reset the counter to zero for when we begin the game
      elsif rising_edge(count) then
      if (counter /= 999) then
        counter := counter + 1;
      else
        counter := 0;
      end if;
    end if;
    score  <= counter;
    points <= std_logic_vector(to_unsigned(counter, points'length));
  end process;

  three_digi_seg_inst : three_digi_seg
  port map
    (std_logic_vector(to_unsigned(score, 10)), ones_out, tens_out, hundreds_out);

end architecture;