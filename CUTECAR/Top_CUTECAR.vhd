library ieee;
use ieee.std_logic_1164.all;

entity Top_CUTECAR is
  port (
    CLOCK_50 : in  std_logic;
    KEY      : in  std_logic_vector(0 downto 0);
    SW       : in  std_logic_vector(7 downto 0);
    LED      : out std_logic_vector(7 downto 0);

    DRAM_CLK, DRAM_CKE : out std_logic;
    DRAM_ADDR          : out std_logic_vector(12 downto 0);
    DRAM_BA            : out std_logic_vector(1 downto 0);
    DRAM_CS_N          : out std_logic;
    DRAM_CAS_N         : out std_logic;
    DRAM_RAS_N         : out std_logic;
    DRAM_WE_N          : out std_logic;
    DRAM_DQ            : inout std_logic_vector(15 downto 0);
    DRAM_DQM           : out std_logic_vector(1 downto 0);

    LTC_ADC_CONVST : out std_logic;
    LTC_ADC_SCK    : out std_logic;
    LTC_ADC_SDI    : out std_logic;
    LTC_ADC_SDO    : in  std_logic;

    VCC3P3_PWRON_n : out std_logic
  );
end entity;

architecture Structure of Top_CUTECAR is

  component Nios_CUTECAR is
    port (
      clk_clk                                       : in    std_logic                     := 'X';
      switches_export                               : in    std_logic_vector(7 downto 0)  := (others => 'X');
      leds_export                                   : out   std_logic_vector(7 downto 0);
      sdram_wire_addr                               : out   std_logic_vector(12 downto 0);
      sdram_wire_ba                                 : out   std_logic_vector(1 downto 0);
      sdram_wire_cas_n                              : out   std_logic;
      sdram_wire_cke                                : out   std_logic;
      sdram_wire_cs_n                               : out   std_logic;
      sdram_wire_dq                                 : inout std_logic_vector(15 downto 0) := (others => 'X');
      sdram_wire_dqm                                : out   std_logic_vector(1 downto 0);
      sdram_wire_ras_n                              : out   std_logic;
      sdram_wire_we_n                               : out   std_logic;
      reset_reset_n                                 : in    std_logic                     := 'X';
      clocks_sdram_clk_clk                          : out   std_logic;
      pos_data0r_external_connection_export         : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data1r_external_connection_export         : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data2r_external_connection_export         : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data4r_external_connection_export         : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data5r_external_connection_export         : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data6r_external_connection_export         : in    std_logic_vector(7 downto 0)  := (others => 'X');
      pos_data3r_external_connection_export         : in    std_logic_vector(7 downto 0)  := (others => 'X');
      sel_i_external_connection_export              : out   std_logic_vector(2 downto 0);
      sel_j_external_connection_export              : out   std_logic_vector(2 downto 0);
      op_sel_external_connection_export             : out   std_logic_vector(1 downto 0);
      result_r_external_connection_export           : in    std_logic_vector(8 downto 0)  := (others => 'X');
      valid_and_overflow_external_connection_export : in    std_logic_vector(1 downto 0)  := (others => 'X')
    );
  end component;

  component capteurs_sol is
    port (
      clk          : in  std_logic;
      reset_n      : in  std_logic;
      data_capture : in  std_logic;
      data_readyr  : out std_logic;
      data0r       : out std_logic_vector(7 downto 0);
      data1r       : out std_logic_vector(7 downto 0);
      data2r       : out std_logic_vector(7 downto 0);
      data3r       : out std_logic_vector(7 downto 0);
      data4r       : out std_logic_vector(7 downto 0);
      data5r       : out std_logic_vector(7 downto 0);
      data6r       : out std_logic_vector(7 downto 0);
      ADC_CONVSTr  : out std_logic;
      ADC_SCK      : out std_logic;
      ADC_SDIr     : out std_logic;
      ADC_SDO      : in  std_logic
    );
  end component;

  component pll_2freqs is
    port (
      areset : in  std_logic := '0';
      inclk0 : in  std_logic := '0';
      c0     : out std_logic;
      c1     : out std_logic
    );
  end component;

  component calculateur_cable is
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
  end component;

  signal rst_n   : std_logic;
  signal clk40   : std_logic;
  signal clk2k   : std_logic;

  signal led_nios : std_logic_vector(7 downto 0);

  signal data_ready_s : std_logic;

  signal pos_data0r_s : std_logic_vector(7 downto 0);
  signal pos_data1r_s : std_logic_vector(7 downto 0);
  signal pos_data2r_s : std_logic_vector(7 downto 0);
  signal pos_data3r_s : std_logic_vector(7 downto 0);
  signal pos_data4r_s : std_logic_vector(7 downto 0);
  signal pos_data5r_s : std_logic_vector(7 downto 0);
  signal pos_data6r_s : std_logic_vector(7 downto 0);

  signal sel_i_s  : std_logic_vector(2 downto 0);
  signal sel_j_s  : std_logic_vector(2 downto 0);
  signal op_sel_s : std_logic_vector(1 downto 0);

  signal result_r_s : std_logic_vector(8 downto 0);
  signal valid_s    : std_logic;
  signal overflow_s : std_logic;

  signal valid_and_overflow_s : std_logic_vector(1 downto 0);

begin

  rst_n <= KEY(0);

  VCC3P3_PWRON_n <= '0';

  LED <= led_nios;


  u_pll : pll_2freqs
    port map (
      areset => not rst_n,
      inclk0 => CLOCK_50,
      c0     => clk40,
      c1     => clk2k
    );

  u_caps : capteurs_sol
    port map (
      clk          => clk40,
      reset_n      => rst_n,
      data_capture => clk2k,
      data_readyr  => data_ready_s,

      data0r => pos_data0r_s,
      data1r => pos_data1r_s,
      data2r => pos_data2r_s,
      data3r => pos_data3r_s,
      data4r => pos_data4r_s,
      data5r => pos_data5r_s,
      data6r => pos_data6r_s,

      ADC_CONVSTr => LTC_ADC_CONVST,
      ADC_SCK     => LTC_ADC_SCK,
      ADC_SDIr    => LTC_ADC_SDI,
      ADC_SDO     => LTC_ADC_SDO
    );

  u_calc : calculateur_cable
    port map (
      clk        => clk40,
      reset_n    => rst_n,
      en         => data_ready_s,
      data0r     => pos_data0r_s,
      data1r     => pos_data1r_s,
      data2r     => pos_data2r_s,
      data3r     => pos_data3r_s,
      data4r     => pos_data4r_s,
      data5r     => pos_data5r_s,
      data6r     => pos_data6r_s,
      sel_i      => sel_i_s,
      sel_j      => sel_j_s,
      op_sel     => op_sel_s,
      result_r   => result_r_s,
      valid_r    => valid_s,
      overflow_r => overflow_s
    );

  valid_and_overflow_s <= overflow_s & valid_s;

  NiosII : Nios_CUTECAR
    port map (
      clk_clk      => CLOCK_50,
      reset_reset_n => rst_n,

      switches_export => SW,
      leds_export     => led_nios,

      sdram_wire_addr  => DRAM_ADDR,
      sdram_wire_ba    => DRAM_BA,
      sdram_wire_cas_n => DRAM_CAS_N,
      sdram_wire_cke   => DRAM_CKE,
      sdram_wire_cs_n  => DRAM_CS_N,
      sdram_wire_dq    => DRAM_DQ,
      sdram_wire_dqm   => DRAM_DQM,
      sdram_wire_ras_n => DRAM_RAS_N,
      sdram_wire_we_n  => DRAM_WE_N,

      clocks_sdram_clk_clk => DRAM_CLK,

      pos_data0r_external_connection_export => pos_data0r_s,
      pos_data1r_external_connection_export => pos_data1r_s,
      pos_data2r_external_connection_export => pos_data2r_s,
      pos_data3r_external_connection_export => pos_data3r_s,
      pos_data4r_external_connection_export => pos_data4r_s,
      pos_data5r_external_connection_export => pos_data5r_s,
      pos_data6r_external_connection_export => pos_data6r_s,

      sel_i_external_connection_export  => sel_i_s,
      sel_j_external_connection_export  => sel_j_s,
      op_sel_external_connection_export => op_sel_s,

      result_r_external_connection_export           => result_r_s,
      valid_and_overflow_external_connection_export => valid_and_overflow_s
    );

end architecture;