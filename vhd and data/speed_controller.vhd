library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all;

entity speed_controller is
  port
  (
    switches  : in std_logic_vector(9 downto 0);
    speed_out : out std_logic_vector(2 downto 0)
  );
end entity speed_controller;

architecture rtl of speed_controller is
begin

  speed_out <= "010" when switches = "0000000000" else
  switches(2 downto 0);
end architecture;