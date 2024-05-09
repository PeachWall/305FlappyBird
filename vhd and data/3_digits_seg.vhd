library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity threedigit_seg is 
  port(input_num            : in std_logic_vector(9 downto 0);
       ones, tens, hundreds : out std_logic_vector(6 downto 0)); 
end threedigit_seg;

architecture Behavioral of threedigit_seg is
signal temp_input : integer range 0 to 999;
signal t_ones, t_tens, t_hundreds : std_logic_vector(3 downto 0);

component BCD_to_SevenSeg is 
  port (input : in std_logic_vector(3 downto 0);
        SevenSeg_out : out std_logic_vector(6 downto 0));
end component;

begin
  temp_input <= to_integer(unsigned(input_num));
  
  t_ones <= std_logic_vector(to_unsigned(temp_input mod 10, 4));
  t_tens <= std_logic_vector(to_unsigned((temp_input/10) mod 10, 4));
  t_hundreds <= std_logic_vector(to_unsigned((temp_input/100) mod 10, 4));
  
  seg1: BCD_to_SevenSeg port map (input => t_ones, SevenSeg_out => ones);
  seg2: BCD_to_SevenSeg port map (input => t_tens, SevenSeg_out => tens);
  seg3: BCD_to_SevenSeg port map (input => t_hundreds, SevenSeg_out => hundreds);

end Behavioral;
       
    
         