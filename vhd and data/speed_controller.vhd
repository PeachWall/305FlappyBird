library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all;

entity speed_controller is
  port
  (
	 switches  : in std_logic_vector(9 downto 0);
    speed_out : out std_logic_vector(1 downto 0)
  );
end entity speed_controller;

architecture rtl of speed_controller is
begin

  speed_out <= "10" when switches = CONV_STD_LOGIC_VECTOR(0,10) else
					"01" when switches = CONV_STD_LOGIC_VECTOR(1,10) else -- slow down
					"11" when switches = CONV_STD_LOGIC_VECTOR(2,10) else -- speed up
					"10";
end architecture;