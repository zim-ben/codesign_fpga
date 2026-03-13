library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity CTL_Rot is
  generic(
    Rotspeed : natural := 30  -- correction strength (duty units per error step)
  );
  port (
    clk       	: in  std_logic;
    reset_n   	: in  std_logic;

    start_Rot  : in  std_logic;
    dir_Rot	   : in  std_logic;
	 
    fin_rot   	: out  std_logic
  );
end entity;

architecture rtl of CTL_Rot is




begin

  process(clk, reset_n)
  begin
    if reset_n = '0' then
      
    elsif rising_edge(clk) then
		
    end if;
  end process;

end architecture;