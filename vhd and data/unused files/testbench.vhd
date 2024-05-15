library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity testbench is
end entity testbench;

architecture rtl of testbench is

  component bird_top_entity_12 is
    port
    (
      CLOCK_50               : in std_logic;
      VGA_R, VGA_G, VGA_B    : out std_logic_vector(3 downto 0);
      h_sync_out, v_sync_out : out std_logic;
      LEDR                   : out std_logic_vector(9 downto 0);
      SW                     : in std_logic_vector(9 downto 0)
    );
  end component;

  signal CLOCK_50, h_sync_out, v_sync_out : std_logic;
  signal VGA_R, VGA_G, VGA_B              : std_logic_vector(3 downto 0);
  signal LEDR, SW                         : std_logic_vector(9 downto 0);
begin

  clk : process
  begin
    CLOCK_50 <= '0';
    wait for 10 ns;
    CLOCK_50 <= '1';
    wait for 10 ns;
  end process;

  DUT : bird_top_entity_12
  port map
  (
    CLOCK_50   => CLOCK_50,
    VGA_R      => VGA_R,
    VGA_G      => VGA_G,
    VGA_B      => VGA_B,
    h_sync_out => h_sync_out,
    v_sync_out => v_sync_out,
    LEDR       => LEDR,
    SW         => SW
  );

end architecture;