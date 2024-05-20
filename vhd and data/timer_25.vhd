library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.STD_LOGIC_SIGNED.all;

entity timer_25 is
  port
  (
    clk, reset, enable : in std_logic;
    init_val           : in std_logic_vector(4 downto 0);
    seconds            : out std_logic_vector(4 downto 0)
  );
end entity;

architecture beh of timer_25 is
begin
  process (clk, reset)
    variable v_Q     : std_logic_vector(4 downto 0) := init_val;
    variable counter : integer range 0 to 25000000;

  begin
    if (rising_edge(clk)) then
      if (reset = '1') then
        counter := 0;
        v_Q     := init_val;
      end if;
      if (enable = '1') then
        counter := counter + 1;
      end if;
    end if;

    if (counter = 25000000) then
      v_Q     := v_Q - 1;
      counter := 0;
    end if;

    seconds <= v_Q;
  end process;
end beh; -- beh