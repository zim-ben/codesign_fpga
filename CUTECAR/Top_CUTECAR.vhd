LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Top_CUTECAR IS
PORT (
    CLOCK_50 : IN STD_LOGIC;
    KEY : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
    SW : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    LED : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
END Top_CUTECAR;

ARCHITECTURE rtl OF Top_CUTECAR IS
       component qysys_test is
        port (
            clk_clk         : in  std_logic                    := 'X';             -- clk
            switches_export : in  std_logic_vector(7 downto 0) := (others => 'X'); -- export
            leds_export     : out std_logic_vector(7 downto 0);                    -- export
            reset_reset_n   : in  std_logic                    := 'X'              -- reset_n
        );
    end component qysys_test;
BEGIN
    NiosII : qysys_test
  PORT MAP(
  clk_clk => CLOCK_50,
  reset_reset_n => KEY(0),
  switches_export => SW(7 DOWNTO 0),
  leds_export => LED(7 DOWNTO 0)
);
END rtl;