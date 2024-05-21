library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use work.util.all;

entity fsm is
  port
  (
    clk              : in std_logic;
    reset            : in std_logic;
    start_button     : in std_logic;
    obst_collided    : in std_logic;
    ability_collided : in std_logic;
    ability_type     : in std_logic_vector(2 downto 0);
    mouse            : in std_logic;
    bird_state       : out std_logic_vector(2 downto 0);
    pipe_state       : out std_logic_vector(2 downto 0);
    game_state       : out std_logic_vector(2 downto 0);
    timer_on         : out std_logic;
    timer_time       : out std_logic_vector(4 downto 0);
    reset_out        : out std_logic;
    lives_out        : out std_logic_vector(2 downto 0)
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
  signal timer_enable   : std_logic     := '0';
  signal timer_reset    : std_logic;
  signal timer_seconds  : std_logic_vector(4 downto 0);
  signal s_button1      : std_logic;
  signal timer_init_val : std_logic_vector(4 downto 0) := "00000";
  signal timer_timout   : std_logic;
  signal cur_ability    : ability_types;

  signal bird_reset : std_logic;
begin

  timer_on    <= timer_enable;
  timer_time  <= timer_seconds;
  cur_ability <= ability_types'val(to_integer(unsigned(ability_type)));

  BIRD_FSM : process (clk, timer_timout)
  begin
    if (timer_timout = '1') then
      timer_enable <= '0';
      if (cur_bird_state = BIG or cur_bird_state = SMALL) then
        cur_bird_state <= NORMAL;
        timer_reset    <= '1';
      end if;
    elsif (rising_edge(clk)) then
      if (bird_reset = '1') then
        cur_bird_state <= NORMAL;
        timer_reset    <= '1';
        timer_enable   <= '0';
      elsif (ability_collided = '1' and cur_ability = MONEY) then
        cur_bird_state <= BIG;
        timer_init_val <= "00101";
        timer_reset    <= '1';
        timer_enable   <= '1';
      elsif (ability_collided = '1' and cur_ability = SMALL) then
        cur_bird_state <= SMALL;
        timer_init_val <= "00101";
        timer_reset    <= '1';
        timer_enable   <= '1';
        timer_reset    <= '0';
      else
        timer_reset <= '0';
      end if;
    end if;

    bird_state <= std_logic_vector(to_unsigned(player_states'pos(cur_bird_state), 3));
  end process;

  GAME_FSM : process (clk, obst_collided, mouse, start_button)
    variable hold  : std_logic                    := '0';
    variable lives : std_logic_vector(2 downto 0) := "011";
  begin
    if (rising_edge(clk)) then
      if (cur_game_state = MENU) then
        if (start_button = '0') then
          cur_game_state <= PLAY;
          reset_out      <= '1';
        end if;
      elsif (obst_collided = '1' and cur_game_state = PLAY) then
        cur_game_state <= COLLIDE;
      elsif (mouse = '0' and hold = '0' and cur_game_state = COLLIDE) then
        cur_game_state <= PLAY;
        bird_reset     <= '1';
        lives := lives - 1;
        hold  := '1';
        reset_out <= '1';
      else
        reset_out  <= '0';
        bird_reset <= '0';
      end if;

      if (mouse = '0') then
        hold := '0';
      end if;
    end if;
    game_state <= std_logic_vector(to_unsigned(game_states'pos(cur_game_state), 3));
    lives_out  <= lives;
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