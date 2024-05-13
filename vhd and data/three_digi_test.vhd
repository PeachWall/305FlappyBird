library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity seven_seg_test is
end entity seven_seg_test;

architecture test of seven_seg_test is
    signal t_number : std_logic_vector(9 downto 0) := (others => '0');
    signal t_ones : std_logic_vector(6 downto 0);
    signal t_tens : std_logic_vector(6 downto 0);
    signal t_hundreds : std_logic_vector(6 downto 0);

    component three_digi_seg is 
        port(input_num            : in std_logic_vector(9 downto 0);
             ones, tens, hundreds : out std_logic_vector(6 downto 0)); 
    end component;

begin
    dut: three_digi_seg 
        port map(t_number, t_ones, t_tens, t_hundreds);

    process
    begin
        t_number <= t_number + "0000000001";
        wait for 10 ns;
    end process;
end architecture test;