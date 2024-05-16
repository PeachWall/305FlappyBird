library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.util.all;

entity fsm is
  port
  (
    clk        : in std_logic;
    reset      : in std_logic;
    button     : in std_logic; -- test for fsm
    bird_state : out std_logic_vector(2 downto 0)
  );
end entity fsm;

architecture rtl of fsm is
  component timer_25 is
    port
    (
      clk, reset, enable : in std_logic;
      seconds            : out std_logic_vector(4 downto 0)
    );
  end component;
  signal cur_bird_state : player_state := NORMAL;
  signal timer_enable   : std_logic;
  signal timer_reset    : std_logic;
  signal timer_seconds  : std_logic_vector(4 downto 0);
  signal s_button       : std_logic;
begin

  process (button, timer_seconds)
  begin
    if (button = '0') then
      cur_bird_state <= BIG;
      timer_enable   <= '1';
      timer_reset    <= '1';
    else
      timer_reset <= '0';
    end if;

    if (timer_seconds = "00011" and timer_enable = '1' and cur_bird_state = BIG) then
      cur_bird_state <= NORMAL;
      timer_enable   <= '0';
    end if;

    bird_state <= player_state_to_std_logic_vector(cur_bird_state);
  end process;

  TIMER : timer_25
  port map
  (
    clk     => clk,
    reset   => timer_reset,
    enable  => timer_enable,
    seconds => timer_seconds
  );
end architecture;