library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calculateur_cable is
  generic (
    GAIN : positive := 2
  );
  port (
    clk        : in  std_logic;
    reset_n    : in  std_logic;
    en         : in  std_logic;

    data0r     : in  std_logic_vector(7 downto 0);
    data1r     : in  std_logic_vector(7 downto 0);
    data2r     : in  std_logic_vector(7 downto 0);
    data3r     : in  std_logic_vector(7 downto 0);
    data4r     : in  std_logic_vector(7 downto 0);
    data5r     : in  std_logic_vector(7 downto 0);
    data6r     : in  std_logic_vector(7 downto 0);

    sel_i      : in  std_logic_vector(2 downto 0);
    sel_j      : in  std_logic_vector(2 downto 0);
    op_sel     : in  std_logic_vector(1 downto 0);

    result_r   : out std_logic_vector(8 downto 0);
    valid_r    : out std_logic;
    overflow_r : out std_logic
  );
end entity;

architecture rtl of calculateur_cable is

  function select_data(
    sel : std_logic_vector(2 downto 0);
    d0  : std_logic_vector(7 downto 0);
    d1  : std_logic_vector(7 downto 0);
    d2  : std_logic_vector(7 downto 0);
    d3  : std_logic_vector(7 downto 0);
    d4  : std_logic_vector(7 downto 0);
    d5  : std_logic_vector(7 downto 0);
    d6  : std_logic_vector(7 downto 0)
  ) return unsigned is
  begin
    case sel is
      when "000" => return unsigned(d0);
      when "001" => return unsigned(d1);
      when "010" => return unsigned(d2);
      when "011" => return unsigned(d3);
      when "100" => return unsigned(d4);
      when "101" => return unsigned(d5);
      when "110" => return unsigned(d6);
      when others => return (others => '0');
    end case;
  end function;

  signal result_s   : unsigned(8 downto 0);
  signal valid_s    : std_logic;
  signal overflow_s : std_logic;

begin

  process(clk, reset_n)
    variable a_v      : unsigned(7 downto 0);
    variable b_v      : unsigned(7 downto 0);
    variable calc_v   : integer;
  begin
    if reset_n = '0' then
      result_s   <= (others => '0');
      valid_s    <= '0';
      overflow_s <= '0';

    elsif rising_edge(clk) then
      valid_s    <= '0';
      overflow_s <= '0';

      if en = '1' then
        a_v := select_data(sel_i, data0r, data1r, data2r, data3r, data4r, data5r, data6r);
        b_v := select_data(sel_j, data0r, data1r, data2r, data3r, data4r, data5r, data6r);

        case op_sel is
          when "00" =>   -- addition
            calc_v := to_integer(a_v) + to_integer(b_v);

          when "01" =>   -- subtraction
            calc_v := to_integer(a_v) - to_integer(b_v);

          when others => 
            calc_v := to_integer(a_v) * GAIN;
        end case;

        if calc_v < 0 then
          result_s   <= (others => '0');
          overflow_s <= '1';

        elsif calc_v > 511 then
          result_s   <= to_unsigned(511, 9);
          overflow_s <= '1';

        else
          result_s <= to_unsigned(calc_v, 9);
        end if;

        valid_s <= '1';
      end if;
    end if;
  end process;

  result_r   <= std_logic_vector(result_s);
  valid_r    <= valid_s;
  overflow_r <= overflow_s;

end architecture;