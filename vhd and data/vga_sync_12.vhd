library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_MISC.all;

entity VGA_SYNC_12 is
  port
  (
    clock_25Mhz                   : in std_logic;
    red, green, blue              : in std_logic_vector (3 downto 0);
    horiz_sync_out, vert_sync_out : out std_logic;
    red_out, green_out, blue_out  : out std_logic_vector (3 downto 0);
    pixel_row, pixel_column       : out std_logic_vector(9 downto 0)
  );
end VGA_SYNC_12;

architecture a of VGA_SYNC_12 is
  signal horiz_sync, vert_sync            : std_logic;
  signal video_on, video_on_v, video_on_h : std_logic;
  signal h_count, v_count                 : std_logic_vector(9 downto 0);

begin

  -- video_on is high only when RGB data is displayed
  video_on <= video_on_H and video_on_V;

  process
  begin
    wait until(clock_25Mhz'EVENT) and (clock_25Mhz = '1');

    --Generate Horizontal and Vertical Timing Signals for Video Signal
    -- H_count counts pixels (640 + extra time for sync signals)
    -- 
    --  Horiz_sync  ------------------------------------__________--------
    --  H_count       0                640             659       755    799
    --
    if (h_count = 799) then
      h_count <= "0000000000";
    else
      h_count <= h_count + 1;
    end if;

    --Generate Horizontal Sync Signal using H_count
    if (h_count <= 755) and (h_count >= 659) then
      horiz_sync  <= '0';
    else
      horiz_sync <= '1';
    end if;

    --V_count counts rows of pixels (480 + extra time for sync signals)
    --  
    --  Vert_sync      -----------------------------------------------_______------------
    --  V_count         0                                      480    493-494          524
    --
    if (v_count >= 524) and (h_count >= 699) then
      v_count <= "0000000000";
    elsif (h_count = 699) then
      v_count <= v_count + 1;
    end if;

    -- Generate Vertical Sync Signal using V_count
    if (v_count <= 494) and (v_count >= 493) then
      vert_sync   <= '0';
    else
      vert_sync <= '1';
    end if;

    -- Generate Video on Screen Signals for Pixel Data
    if (h_count  <= 639) then
      video_on_h   <= '1';
      pixel_column <= h_count;
    else
      video_on_h <= '0';
    end if;

    if (v_count <= 479) then
      video_on_v  <= '1';
      pixel_row   <= v_count;
    else
      video_on_v <= '0';
    end if;

    -- Put all video signals through DFFs to elminate any delays that cause a blurry image

    if (or_reduce(red) = '1' and video_on = '1') then
      red_out <= red;
    else
      red_out <= "0000";
    end if;

    if (or_reduce(green) = '1' and video_on = '1') then
      green_out <= green;
    else
      green_out <= "0000";
    end if;

    if (or_reduce(blue) = '1' and video_on = '1') then
      blue_out <= blue;
    else
      blue_out <= "0000";
    end if;
    horiz_sync_out <= horiz_sync;
    vert_sync_out  <= vert_sync;

  end process;
end a;