library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library altera_mf;
use altera_mf.all;

entity title_rom is
  port
  (
    clock        : in std_logic;
    row          : in std_logic_vector(5 downto 0);
    col          : in std_logic_vector(6 downto 0);
    pixel_output : out std_logic_vector(12 downto 0)
  );
end title_rom;

architecture SYN of title_rom is
  signal rom_data    : std_logic_vector (15 downto 0);
  signal rom_address : std_logic_vector (12 downto 0);
  signal rom_a1      : std_logic_vector(12 downto 0);
  component altsyncram
    generic
    (
      address_aclr_a         : string;
      clock_enable_input_a   : string;
      clock_enable_output_a  : string;
      init_file              : string;
      intended_device_family : string;
      lpm_hint               : string;
      lpm_type               : string;
      numwords_a             : natural;
      operation_mode         : string;
      outdata_aclr_a         : string;
      outdata_reg_a          : string;
      widthad_a              : natural;
      width_a                : natural;
      width_byteena_a        : natural
    );
    port
    (
      clock0    : in std_logic;
      address_a : in std_logic_vector (12 downto 0);
      q_a       : out std_logic_vector (15 downto 0)
    );
  end component;
begin

  altsyncram_component : altsyncram
  generic
  map (
  address_aclr_a         => "NONE",
  clock_enable_input_a   => "BYPASS",
  clock_enable_output_a  => "BYPASS",
  init_file              => "title_data.mif",
  intended_device_family => "Cyclone III",
  lpm_hint               => "ENABLE_RUNTIME_MOD=NO",
  lpm_type               => "altsyncram",
  numwords_a             => 8192,
  operation_mode         => "ROM",
  outdata_aclr_a         => "NONE",
  outdata_reg_a          => "UNREGISTERED",
  widthad_a              => 16,
  width_a                => 16,
  width_byteena_a        => 1
  )
  port map
  (
    clock0    => clock,
    address_a => rom_address,
    q_a       => rom_data
  );

  rom_a1       <= (row & "0000000");
  rom_address  <= rom_a1 + col;
  pixel_output <= rom_data(12 downto 0);

end SYN;