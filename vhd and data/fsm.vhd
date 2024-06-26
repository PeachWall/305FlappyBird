library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_misc.all;
use work.util.all;

entity fsm is
  port
  (
    clk              : in std_logic;
    reset            : in std_logic;
    key              : in std_logic_vector(3 downto 0);
    obst_collided    : in std_logic;
    ability_collided : in std_logic;
    ability_type     : in std_logic_vector(2 downto 0);
    mouse            : in std_logic;
    points           : in std_logic_vector(9 downto 0);
    bird_state       : out std_logic_vector(2 downto 0);
    speed_state      : out std_logic_vector(2 downto 0);
    game_state       : out std_logic_vector(2 downto 0);
    timer_on         : out std_logic;
    timer_time       : out std_logic_vector(4 downto 0);
    reset_out        : out std_logic;
    lives_out        : out std_logic_vector(2 downto 0);
    money_out        : out std_logic_vector(7 downto 0); -- HOPING THEY DONT GO OVER 255 c:
    difficulty       : out std_logic_vector(2 downto 0)
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

  -- Define a protected type

  signal cur_bird_state  : player_states := NORMAL;
  signal cur_game_state  : game_states   := MENU;
  signal cur_speed_state : speed_states  := NORMAL;
  signal timer_enable    : std_logic     := '0';
  signal timer_reset     : std_logic;
  signal timer_seconds   : std_logic_vector(4 downto 0);
  signal s_button1       : std_logic;
  signal timer_init_val  : std_logic_vector(4 downto 0) := "01010";
  signal timer_timout    : std_logic;
  signal cur_ability     : ability_types;

  signal bird_reset : std_logic;
begin

  timer_on    <= timer_enable;
  timer_time  <= timer_seconds;
  cur_ability <= ability_types'val(to_integer(unsigned(ability_type)));

  FSM : process (clk, reset, obst_collided, mouse, key, timer_timout, points)
    variable key_hold, hold : std_logic                    := '0';
    variable lives          : std_logic_vector(2 downto 0) := "011";
    variable v_money        : std_logic_vector(7 downto 0) := (others => '0');
    variable v_difficulty   : std_logic_vector(2 downto 0) := "001";
  begin
    --------------------
    -- BIRD FSM START --
    --------------------

    if (timer_timout = '1') then
      timer_enable    <= '0';
      cur_speed_state <= NORMAL;
      timer_reset     <= '1';
      if ((cur_bird_state = BIG or cur_bird_state = SMALL)) then
        cur_bird_state <= NORMAL;
      end if;
    elsif (rising_edge(clk)) then
      if (bird_reset = '1') then
        cur_bird_state  <= NORMAL;
        cur_speed_state <= NORMAL;
        timer_reset     <= '1';
        timer_enable    <= '0';
      elsif (ability_collided = '1' and cur_ability = BIG) then
        cur_bird_state <= BIG;
        timer_init_val <= "01010";
        timer_reset    <= '1';
        timer_enable   <= '1';
      elsif (ability_collided = '1' and cur_ability = SMALL) then
        cur_bird_state <= SMALL;
        timer_init_val <= "01010";
        timer_reset    <= '1';
        timer_enable   <= '1';
        --timer_reset    <= '0'; -- DUNNO IF I NEED THIS.. PROBABLY NOT
      elsif (ability_collided = '1' and cur_ability = LIFE) then
        if (lives /= 7) then
          lives := lives + 1;
        end if;
      elsif (ability_collided = '1' and cur_ability = MONEY) then
        if (v_money /= "11111111") then
          v_money := v_money + 1;
        end if;
      elsif (cur_game_state = MENU) then
        v_money := (others => '0');
      elsif (ability_collided = '1' and cur_ability = FAST) then
        cur_speed_state <= FAST;
        timer_init_val  <= "10100";
        timer_reset     <= '1';
        timer_enable    <= '1';
      elsif (ability_collided = '1' and cur_ability = SLOW) then
        cur_speed_state <= SLOW;
        timer_init_val  <= "10100";
        timer_reset     <= '1';
        timer_enable    <= '1';
      elsif (ability_collided = '1' and cur_ability = BOMB) then
        if (lives = 0) then
          cur_game_state <= FINISH;
        else
          if (v_difficulty /= "01") then
            lives := lives - 1;
          end if;
          cur_game_state <= COLLIDE;
        end if;
      else
        timer_reset <= '0';
      end if;
    end if;

    bird_state  <= std_logic_vector(to_unsigned(player_states'pos(cur_bird_state), 3));
    speed_state <= std_logic_vector(to_unsigned(speed_states'pos(cur_speed_state), 3));
    money_out   <= v_money;
    ------------------
    -- BIRD FSM END --
    ------------------

    --------------------
    -- GAME FSM START --
    --------------------
    if (rising_edge(clk)) then
      if (cur_game_state = MENU) then
        if (and_reduce(key(1 downto 0)) = '0' and key_hold = '0') then
          if (key(0) = '0') then
            cur_game_state <= PAUSED;
            lives := "011";
            reset_out  <= '1';
            bird_reset <= '1';
            --v_difficulty := "00";
          elsif (key(1) = '0') then
            --v_difficulty := "01";
            v_difficulty := v_difficulty(1 downto 0) & v_difficulty(2);
          end if;
          key_hold := '1';
        end if;
      elsif (cur_game_state = PAUSED and key(0) = '0' and key_hold = '0') then
        cur_game_state <= MENU;
        key_hold := '1';
      elsif (cur_game_state = PAUSED and mouse = '1' and hold = '0') then
        cur_game_state <= PLAY;
        hold := '1';
      elsif (obst_collided = '1' and cur_game_state = PLAY) then
        if (lives = 0) then
          cur_game_state <= FINISH;
        else
          if (v_difficulty /= "01") then
            lives := lives - 1;
          end if;
          cur_game_state <= COLLIDE;
        end if;
      elsif (cur_game_state = PLAY and key(0) = '0' and key_hold = '0') then
        cur_game_state <= PAUSED;
        key_hold := '1';
      elsif (mouse = '1' and hold = '0' and cur_game_state = COLLIDE) then
        cur_game_state <= PLAY;
        bird_reset     <= '1';
        hold := '1';
        reset_out <= '1';
      elsif (cur_game_state = COLLIDE and key(0) = '0' and key_hold = '0') then
        cur_game_state <= MENU;
        key_hold := '1';
      elsif (mouse = '1' and hold = '0' and cur_game_state = FINISH) then
        cur_game_state <= MENU;
      elsif (cur_game_state = PLAY and points >= 20) then
        v_difficulty := "100";
        reset_out  <= '0';
        bird_reset <= '0';
      else
        reset_out  <= '0';
        bird_reset <= '0';
      end if;

      if (mouse = '0') then
        hold := '0';
      end if;

      if (and_reduce(key) = '1') then
        key_hold := '0';
      end if;
    end if;
    game_state <= std_logic_vector(to_unsigned(game_states'pos(cur_game_state), 3));
    difficulty <= v_difficulty;

    ------------------
    -- GAME FSM END --
    ------------------

    lives_out <= lives;
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