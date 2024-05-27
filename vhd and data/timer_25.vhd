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
    seconds            : out std_logic_vector(4 downto 0);
    timeout            : out std_logic
  );
end entity;

architecture beh of timer_25 is
begin
  process (clk, reset)
    variable v_Q       : std_logic_vector(4 downto 0) := "00000";
    variable counter   : integer range 0 to 25000000;
    variable v_timeout : std_logic := '0';
  begin
    if (reset = '1') then
      counter := 0;
      v_Q     := init_val;
      seconds <= init_val;
      v_timeout := '0';
    elsif (rising_edge(clk)) then
      if (enable = '1') then
        if (v_timeout = '0') then
          counter := counter + 1;

          if (counter = 25000000) then
            v_Q := v_Q - 1;
            if (v_Q = "00000") then
              v_timeout := '1';
            else
              v_timeout := '0';
            end if;
            counter := 0;
          end if;
        end if;
      end if;
    end if;

    seconds <= v_Q;
    timeout <= v_timeout;
  end process;
end beh; -- beh