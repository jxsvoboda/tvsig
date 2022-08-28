--
-- Testbench
-- TV signal generator
--
-- (c) Jiri Svoboda 2010
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Testbench entity
entity gia_core_tb is
end gia_core_tb;

architecture gia_core_tb_arch of gia_core_tb is

	-- GIA core
	component gia_core is
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
	end component;

	signal gclk : std_logic := '0';
	signal ale : std_logic;

	signal cvsyn : std_logic;
	signal cvlum : std_logic;

	signal gale : std_logic;
	signal n_grd : std_logic;
	signal ga15_8 : unsigned(7 downto 0);
	signal gad7_0 : unsigned(7 downto 0);

	signal cg0g : std_logic;

begin
	GIA_CORE_E: gia_core port map (
		GCLK => gclk,
		ALE => ale,

		CVSYN => cvsyn,
		CVLUM => cvlum,

		GALE => gale,
		nGRD => n_grd,
		GA15_8 => ga15_8,
		GAD7_0 => gad7_0,

		CG0G => cg0g
	);

	-- Pull nGRD up
	n_grd <= 'H';

	-- Pull GALE down
	gale <= 'L';

	-- Simulate ALE signal from CP
	ale <= '1';

	-- Simulate SRAM
	gad7_0 <= "10101010" when n_grd = '0' else "ZZZZZZZZ";

	process
	begin
		gclk <= '1';
		loop
			wait for 62.5 ns;
			gclk <= '0';
			wait for 62.5 ns;
			gclk <= '1';
		end loop;
	end process;

end gia_core_tb_arch;
