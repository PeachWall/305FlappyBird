library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity score_counter is
    port(
        add_point, collision        : in std_logic;
        ones_out, tens_out, hundreds_out : out std_logic_vector(6 downto 0)
    );
end entity score_counter;

architecture arch of score_counter is
    signal score : integer:= 0;

    component three_digi_seg is 
        port(
            input_num            : in std_logic_vector(9 downto 0);
            ones, tens, hundreds : out std_logic_vector(6 downto 0)
        ); 
    end component;

begin

    process(add_point, score)
    begin
        if rising_edge(add_point) then
            score <= score + 1;
        end if;

        if score < 0 then
            score <= 0;
				
        end if;
    end process;

    three_digi_seg_inst : three_digi_seg
        port map(CONV_STD_LOGIC_VECTOR(score,10), ones_out, tens_out, hundreds_out);

end architecture;
