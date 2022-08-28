--
-- Signal Generator/Mixer
-- TV signal generator
--
-- (c) Jiri Svoboda 2008-2010
--
-- Combines horizontal and vertical signals into the resulting (mixed) signals.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sig_gen is
	port (
	   -- Position in frame, comes from counter
		h_pos : in unsigned(8 downto 0);
		v_pos : in unsigned(9 downto 0);

		field : out std_logic;	
		sync : out std_logic;
		image_enable : out std_logic
	);
end sig_gen;

architecture sig_gen_arch of sig_gen is

	-- Horizontal signal generator
	component h_sigs
		port (
			h_pos : in unsigned(8 downto 0); -- 0..511

			line_sync : out std_logic;
			field_sync : out std_logic;
			eq_pulse : out std_logic;

			line_blank_enable : out std_logic;
			h_image_enable : out std_logic
		);
	end component;

	-- Vertical signal generator
	component v_sigs
		port (
			line_half : in std_logic; -- 0 = left, 1 = right
			v_pos : in unsigned(9 downto 0); -- 0..624

			field : out std_logic; -- 0 = even, 1 = odd
			field_sync_enable : out std_logic;
			eq_pulse_enable : out std_logic;
			v_image_enable : out std_logic;
			line_sync_enable : out std_logic
		);
	end component;

	-- Horizontal signals
	signal line_sync : std_logic;
	signal field_sync : std_logic;
	signal lb_enable : std_logic;
	signal h_image_enable : std_logic;
	signal eq_pulse : std_logic;

	-- Vertical signals
	signal field_sync_enable : std_logic;
	signal eq_pulse_enable : std_logic;
	signal v_image_enable : std_logic;
	signal line_sync_enable : std_logic;

begin
	-- Generate horizontal signals
	HSIGS: h_sigs port map (
		h_pos => h_pos,
		line_sync => line_sync,
		field_sync => field_sync,
		eq_pulse => eq_pulse,
		line_blank_enable => lb_enable,
		h_image_enable => h_image_enable
	);

	-- Generate vertical signals
	VSIGS: v_sigs port map (
		line_half => h_pos(8),
		v_pos => v_pos,
		field=> field,
		field_sync_enable => field_sync_enable,
		eq_pulse_enable => eq_pulse_enable,
		v_image_enable => v_image_enable,
		line_sync_enable => line_sync_enable
	);

	-- Mix all synchronization signals
	sync <=
		   (line_sync_enable  and line_sync)
		or (field_sync_enable and field_sync)
		or (eq_pulse_enable   and eq_pulse);

	-- Image enable signal
	image_enable <= h_image_enable and v_image_enable;
end sig_gen_arch;
