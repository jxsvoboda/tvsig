--
-- Horizontal signals
-- TV signal generator
--
-- (c) Jiri Svoboda 2008-2010
--
-- Calculates the horizontal signals. Horizontal signals are a function of the
-- position within the current line or half-line. They are not concerned
-- neither with vertical position nor the number of lines.
--
--	* horizontal sync
--	* horizontal blanking
--	* horizontal image enable
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity h_sigs is
	port (
		h_pos : in unsigned(8 downto 0); -- 0..511

		line_sync : out std_logic;
		field_sync : out std_logic;
		eq_pulse : out std_logic;

		line_blank_enable : out std_logic;
		h_image_enable : out std_logic
	);
end h_sigs;

architecture h_sigs_arch of h_sigs is

	-- Horizontal position within half-line. 0..255
	signal half_pos : unsigned(7 downto 0);

	-- Horizontal image enable (internal)
	signal hi_enable : std_logic;

begin
	-- Line sync starts at the beginning of the line and takes 4.7 +- 0.2 us,
	-- i.e. approx 38 T
	line_sync <= '1' when h_pos < 38 else '0';
	
	-- Position within half-line
	-- For computing field sync and eq. pulse
	half_pos <= h_pos(7 downto 0);

	-- Field sync starts at the beginning of the half-line and lasts 27.3+-0.1 us
	-- of the total 32 us, i.e. approx 218 T.
	field_sync <= '1' when half_pos < 218 else '0';

	-- Equalisation pulse starts at the beginning of the half-line
	-- and lasts 2.35+-0.1 us of the total 32 us, i.e. approx 19 T.
	eq_pulse <= '1' when half_pos < 19 else '0';

	-- Image ideally starts at 10.35 us into the line, i.e. approx. 83 T
	-- it ends 1.65+-0,3 us before the end of line, i.e. approx. 13 T
	hi_enable <= '1' when (h_pos >= 83) and (h_pos < (512-13)) else '0';
	h_image_enable <= hi_enable;

	-- Line blanking is the inverse of image.
	line_blank_enable <= not hi_enable;
end h_sigs_arch;
