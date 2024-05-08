library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity random_gen is
  port
  (
    clk, reset, enable : in std_logic;
    Q                  : out signed(7 downto 0)
  );
end entity random_gen;

architecture rtl of random_gen is
  signal s_Q : signed(7 downto 0) := "00000001";
begin
  process (clk)
    variable temp : std_logic;
  begin

    if (rising_edge(clk)) then
      if (reset = '1') then
        s_Q <= "00000001";
      else
        temp := s_Q(4) xor s_Q(3) xor s_Q(2) xor s_Q(0);
        s_Q <= temp & s_Q(7 downto 1);
      end if;
    end if;
  end process;

  Q <= s_Q;
end architecture;