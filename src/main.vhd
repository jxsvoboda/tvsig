--
-- Main module
-- TV signal generator
--
-- (c) Jiri Svoboda 2008-2010
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Top-level entity
entity gia_core is
	port (
		GCLK : in std_logic;
		ALE : in std_logic;

		CVSYN : out std_logic;
		CVLUM : out std_logic;

		GALE : out std_logic;
		nGRD : out std_logic;
		GA15_8 : out unsigned(7 downto 0);
		GAD7_0 : inout unsigned(7 downto 0);

		CG0G : out std_logic
	);

	attribute pin_assign : string;

	attribute pin_assign of GCLK : signal is "5";
	attribute pin_assign of ALE : signal is "12";

	attribute pin_assign of CVSYN : signal is "42";
	attribute pin_assign of CVLUM : signal is "40";

	attribute pin_assign of GALE : signal is "18";
	attribute pin_assign of nGRD : signal is "13";
	attribute pin_assign of GA15_8 : signal is "19,20,22,24,25,26,27,28";
	attribute pin_assign of GAD7_0 : signal is "29,33,34,35,36,37,38,39";

	attribute pin_assign of CG0G : signal is "7";
end gia_core;

architecture gia_core_arch of gia_core is

	-- Signal generator
	component sig_gen
		port (
			h_pos : in unsigned(8 downto 0);
			v_pos : in unsigned(9 downto 0);

			field: out std_logic;
			sync : out std_logic;
			image_enable : out std_logic
		);
	end component;

	-- Master counter
	component counter
		port (
			CLK : in std_logic;
			RESET : in std_logic;

			h_pos : out unsigned(8 downto 0); -- 0..511
			v_pos : out unsigned(9 downto 0) -- 0..624
		);
	end component;

	-- Image generator
	component img_gen
		port (
			clock : in std_logic;

			h_pos : in unsigned(8 downto 0); -- 0..511
			v_pos : in unsigned(9 downto 0); -- 0..624
		
			ale : out std_logic;
			not_rd : out std_logic;
			addr_high : out unsigned(7 downto 0);
			addr_data_low_in : in unsigned(7 downto 0);
			addr_data_low_out : out unsigned(7 downto 0);
			addr_data_low_out_en : out std_logic;

			image : out std_logic
		);
	end component;

	signal h_pos : unsigned(8 downto 0);
	signal v_pos : unsigned(9 downto 0);
	signal field : std_logic;
	signal sync : std_logic;

	signal img_enable : std_logic;
	signal img_value : std_logic;
	signal img_ale : std_logic;

	signal addr_data_low_in : unsigned(7 downto 0);
	signal addr_data_low_out : unsigned(7 downto 0);
	signal addr_data_low_out_en : std_logic;

begin
	CNTR: counter port map (
		CLK => GCLK,
		RESET => '1',

		h_pos => h_pos,
		v_pos => v_pos
	);

	SIGGEN: sig_gen port map (
		h_pos => h_pos,
		v_pos => v_pos,

		field => field,
		sync => sync,
		image_enable => img_enable
	);

	IMGGEN: img_gen port map (
		clock => GCLK,

		h_pos => h_pos,
		v_pos => v_pos,

		ale => img_ale,
		not_rd => nGRD,
		addr_high => GA15_8,
		addr_data_low_in => addr_data_low_in,
		addr_data_low_out => addr_data_low_out,
		addr_data_low_out_en => addr_data_low_out_en,

		image => img_value
	);

	CVSYN <= not sync;
	CVLUM <= img_enable and img_value;

	GALE <= img_ale when img_enable = '1' else ALE;

	CG0G <= img_enable;

	addr_data_low_in <= GAD7_0;
	GAD7_0 <= addr_data_low_out when addr_data_low_out_en = '1'
		else "ZZZZZZZZ";

end gia_core_arch;
