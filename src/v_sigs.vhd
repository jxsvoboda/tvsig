--
-- Vertical signals
-- TV signal generator
--
-- (c) Jiri Svoboda 2008-2010
--
-- Calculates the vertical signals. Vertical signals are a function of the
-- current half-line (h_pos). Their implementation depends on the number of
-- lines in the field/frame.
--
--	* field number (0/1)
--	* field sync enable
--	* equalisation pulse enable
--	* vertical image enable
--	* line sync enable
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity v_sigs is
	port (
	   line_half : in std_logic; -- 0 = left, 1 = right
		v_pos : in unsigned(9 downto 0); -- 0..575

		field : out std_logic; -- 0 = even, 1 = odd
		field_sync_enable : out std_logic;
		eq_pulse_enable : out std_logic;
		v_image_enable : out std_logic;
		line_sync_enable : out std_logic
	);
end v_sigs;

architecture v_sigs_arch of v_sigs is

	signal frame_half_line : unsigned(10 downto 0);
	signal half_line : unsigned(9 downto 0);
	signal fs_enable : std_logic;
	signal eq_enable : std_logic;

begin
	-- Concatenate to form half-line number
	frame_half_line <= v_pos & line_half;
	
	-- Calculate half-line within field
	-- Also determine field
	process (frame_half_line)
		variable xhalf_line : unsigned(10 downto 0);
	begin
		if (frame_half_line < 625) then
			xhalf_line := frame_half_line;
			field <= '0';
		else
			xhalf_line := frame_half_line - 625;
			field <= '1';
		end if;

		half_line <= xhalf_line(9 downto 0);
	end process;

	-- Field sync enable
	-- Active the first five half-lines of each field
	fs_enable <= '1' when half_line < 5 else '0';
	field_sync_enable <= fs_enable;

	-- Equalisation pulse enable
	-- Active the second five and the last five half-lines of each field
	process (half_line)
	begin
		if (half_line >= 5) and (half_line < 10) then
			-- post-equalisation
			eq_enable <= '1';
		elsif (half_line >= 620) then
			-- pre-equalisation
			eq_enable <= '1';
		else
			eq_enable <= '0';
		end if;
	end process;
	
	eq_pulse_enable <= eq_enable;
	
	-- Line sync enable
	-- All half-lines except those containing field sync and eq. pulses
	line_sync_enable <= not (fs_enable or eq_enable);

	-- Vertical image enable
	-- Inverse of field_blank_enable
	--
	-- Field blanking period lasts 25 whole lines / 50 half-lines.
	-- Starts 5 half-lines before end of field, ends 45 half-lines
	-- into the next field
	v_image_enable <= '1' when (half_line >= 45) and (half_line < 625 - 5) else '0';

end v_sigs_arch;

