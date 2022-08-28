--
-- TV signal generator
--
-- Master counter
-- TV signal generator
--
-- (c) Jiri Svoboda 2008-2010
--
-- Counts rising clock edges and generates horizontal and vertical position vectors
-- from which all other signals are derived.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
	port (
		CLK : in std_logic;
		RESET : in std_logic;

		h_pos : out unsigned(8 downto 0); -- 0..511
		v_pos : out unsigned(9 downto 0)  -- 0..624
	);
end counter;

architecture counter_arch of counter is

	-- Initial value for counter (all zeroes)
	constant count_zero : unsigned(18 downto 0) := "0000000000000000000";

	-- Master counter
	signal count : unsigned(18 downto 0) := count_zero;
	-- range: 0..512*625-1
	-- 0 = start of frame

	-- The frame starts with the beginning of CCIR line 1, i. e. the field sync pulses
	-- of the even field

begin
	process (CLK, RESET, count)
		variable next_count : unsigned(18 downto 0);
	begin
		if RESET = '0' then
			count <= count_zero;
		elsif rising_edge(CLK) then
			next_count := count + 1;

			-- Check counter limit
			if next_count /= 512 * 625 then
				count <= next_count;
			else
				count <= count_zero;
			end if;
		end if;
	end process;

	h_pos <= count(8 downto 0);
	v_pos <= count(18 downto 9);

end counter_arch;
