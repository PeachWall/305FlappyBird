library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clock_Divider is
  port
  (
    Clk_in  : in std_logic;
    divider : in integer;
    clk_out : out std_logic := '0'
  );
end Clock_Divider;

architecture arch of Clock_Divider is

  signal s_clk_out : std_logic := '0';
begin

  clk_divider : process
    variable count : integer := 0;
    variable v_clock_out : std_logic := '0';

  begin
    wait until (rising_edge(Clk_in));
    count := count + 1;

    if count >= divider then
      v_clock_out := not v_clock_out;
      count := 0;
    end if;

    clk_out <= v_clock_out;
  end process;
end architecture;