library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity CTL_SL is
  generic(
    BIAS : natural := 250  -- correction strength (duty units per error step)
  );
  port (
    clk       : in  std_logic;
    reset_n   : in  std_logic;

    start_SL  : in  std_logic;
    posi      : in  std_logic_vector(6 downto 0);

    base_duty : in  std_logic_vector(13 downto 0);

    cmdL_SL   : out std_logic_vector(13 downto 0);
    cmdR_SL   : out std_logic_vector(13 downto 0);

    fin_SL    : out std_logic;
    fin_rot   : in  std_logic
  );
end entity;

architecture rtl of CTL_SL is

  -- clamp helper for 12-bit duty
  function clamp12(x : integer) return unsigned is
    variable y : integer := x;
  begin
    if y < 0 then y := 0; end if;
    if y > 4095 then y := 4095; end if;
    return to_unsigned(y, 12);
  end function;

  -- pack command: [13]=GO, [12]=DIR, [11:0]=DUTY
  function pack_cmd(go_i : std_logic; dir_i : std_logic; duty12 : unsigned(11 downto 0))
    return std_logic_vector is
    variable v : std_logic_vector(13 downto 0) := (others => '0');
  begin
    v(13) := go_i;
    v(12) := dir_i;  -- 0 forward
    v(11 downto 0) := std_logic_vector(duty12);
    return v;
  end function;

  -- Compute barycenter error from vect_capt.
  -- Weights (left->right):  -3, -2, -1, 0, +1, +2, +3
  -- Handles cases where 2 or 3 bits are 1.
  function compute_err(v : std_logic_vector(6 downto 0)) return integer is
    variable sum_w : integer := 0;
    variable cnt   : integer := 0;
  begin
    -- v(6)=left ... v(0)=right
    if v(6)='1' then sum_w := sum_w + (-3); cnt := cnt + 1; end if;
    if v(5)='1' then sum_w := sum_w + (-2); cnt := cnt + 1; end if;
    if v(4)='1' then sum_w := sum_w + (-1); cnt := cnt + 1; end if;
    if v(3)='1' then sum_w := sum_w + ( 0); cnt := cnt + 1; end if;
    if v(2)='1' then sum_w := sum_w + ( 1); cnt := cnt + 1; end if;
    if v(1)='1' then sum_w := sum_w + ( 2); cnt := cnt + 1; end if;
    if v(0)='1' then sum_w := sum_w + ( 3); cnt := cnt + 1; end if;

    if cnt = 0 then
      return 0;
    else
      return sum_w / cnt; -- integer division (round toward 0)
    end if;
  end function;

begin

  process(clk, reset_n)
    variable base_i  : integer;
    variable err_i   : integer;
    variable dutyL_i : integer;
    variable dutyR_i : integer;
    variable line_ok : boolean;
  begin
    if reset_n = '0' then
      cmdL_SL <= pack_cmd('0','0', to_unsigned(0,12));
      cmdR_SL <= pack_cmd('0','0', to_unsigned(0,12));
      fin_SL  <= '0';

    elsif rising_edge(clk) then
      -- default
      base_i := to_integer(unsigned(base_duty(11 downto 0)));
      line_ok := (posi /= "0000000");

      if start_SL = '0' then
        -- idle / stop
        cmdL_SL <= pack_cmd('0','0', to_unsigned(0,12));
        cmdR_SL <= pack_cmd('0','0', to_unsigned(0,12));
        fin_SL  <= '0';

      else
        -- start_SL = 1
        if not line_ok then
          -- line lost -> stop + finish
          cmdL_SL <= pack_cmd('0','0', to_unsigned(0,12));
          cmdR_SL <= pack_cmd('0','0', to_unsigned(0,12));
          fin_SL  <= '1';
        else
          -- follow line
          err_i := compute_err(posi);

          dutyR_i := base_i - (integer(BIAS) * err_i);
          dutyL_i := base_i + (integer(BIAS) * err_i);

          cmdL_SL <= pack_cmd('1','0', clamp12(dutyL_i)); -- GO=1, DIR=0 (forward)
          cmdR_SL <= pack_cmd('1','0', clamp12(dutyR_i));
          fin_SL  <= '0';
        end if;
      end if;
    end if;
  end process;

end architecture;