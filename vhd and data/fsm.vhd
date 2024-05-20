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
    button1    : in std_logic; -- test for fsm
    button2    : in std_logic; -- test for fsm
    bird_state : out std_logic_vector(2 downto 0);
    pipe_state : out std_logic_vector(2 downto 0);
    game_state : out std_logic_vector(2 downto 0);
    timer_on   : out std_logic;
    timer_time : out std_logic_vector(4 downto 0)
  );
end entity fsm;

architecture rtl of fsm is
  component timer_25 is
    port
    (
      clk, reset, enable : in std_logic;
      init_val           : in std_logic_vector(4 downto 0);
      seconds            : out std_logic_vector(4 downto 0);
      timeout            : out std_logic
    );
  end component;
  signal cur_bird_state : player_states := NORMAL;
  signal cur_game_state : game_states   := MENU;
  signal timer_enable   : std_logic;
  signal timer_reset    : std_logic;
  signal timer_seconds  : std_logic_vector(4 downto 0);
  signal s_button1      : std_logic;
  signal timer_init_val : std_logic_vector(4 downto 0) := "00000";
  signal timer_timout   : std_logic;
begin

  timer_on   <= timer_enable;
  timer_time <= timer_seconds;

  BIRD_FSM : process (button1, button2, timer_seconds)
  begin
    if (button1 = '0') then
      cur_bird_state <= BIG;
      timer_init_val <= "00101";
      timer_reset    <= '1';
      timer_enable   <= '1';
    else
      timer_reset <= '0';
    end if;

    if (button2 = '0') then
      cur_bird_state <= SMALL;
      timer_init_val <= "00101";
      timer_reset    <= '1';
      timer_enable   <= '1';
    else
      timer_reset <= '0';
    end if;

    if (timer_enable = '1' and timer_timout = '1' and (cur_bird_state = BIG or cur_bird_state = SMALL)) then
      cur_bird_state <= NORMAL;
      timer_enable   <= '0';
      timer_reset    <= '1';
    else
      timer_reset <= '0';
    end if;

    bird_state <= std_logic_vector(to_unsigned(player_states'pos(cur_bird_state), 3));
  end process;

  GAME_FSM : process (cur_game_state)
  begin
  end process;
  TIMER : timer_25
  port map
  (
    clk      => clk,
    reset    => timer_reset,
    enable   => timer_enable,
    init_val => timer_init_val,
    seconds  => timer_seconds,
    timeout  => timer_timout
  );
end architecture;