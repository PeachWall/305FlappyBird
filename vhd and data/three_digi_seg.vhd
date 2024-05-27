library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity three_digi_seg is 
  port(input_num            : in std_logic_vector(9 downto 0);
       ones, tens, hundreds : out std_logic_vector(6 downto 0); 
       L                    : out std_logic_vector(6 downto 0));
end three_digi_seg;

architecture Behavioral of three_digi_seg is
signal temp_input : integer range 0 to 999;
signal t_ones, t_tens, t_hundreds : std_logic_vector(3 downto 0);

component seven_seg is 
  port (BCD_digit : in std_logic_vector(3 downto 0);
        SevenSeg_out : out std_logic_vector(6 downto 0));
end component;

begin
  temp_input <= to_integer(unsigned(input_num));
  
  t_ones <= std_logic_vector(to_unsigned(temp_input mod 10, 4));
  t_tens <= std_logic_vector(to_unsigned((temp_input/10) mod 10, 4));
  t_hundreds <= std_logic_vector(to_unsigned((temp_input/100) mod 10, 4));
  
  seg1: seven_seg port map (BCD_digit => t_ones, SevenSeg_out => ones);
  seg2: seven_seg port map (BCD_digit => t_tens, SevenSeg_out => tens);
  seg3: seven_seg port map (BCD_digit => t_hundreds, SevenSeg_out => hundreds);
  seg4: seven_seg port map (BCD_digit => "1111", SevenSeg_out => L);

end Behavioral;
       
    
         