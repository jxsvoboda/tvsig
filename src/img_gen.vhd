--
-- Test image generator
-- TV signal generator
--
-- (c) Jiri Svoboda 2008-2010
--
-- Generate a test image.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity img_gen is
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
end img_gen;

architecture img_gen_arch of img_gen is

	signal y : unsigned(10 downto 0);

	signal imgx : unsigned(8 downto 0);
	signal imgy : unsigned(10 downto 0);

	signal memio_enable : std_logic;

	signal mem_phase : unsigned(2 downto 0);
	signal read_addr : unsigned(15 downto 0);
	signal vdbuf : unsigned(7 downto 0);

	signal ale_int : std_logic;
	signal not_rd_int : std_logic;
	signal addr_high_int : unsigned(7 downto 0);
	signal addr_data_low_int : unsigned(7 downto 0);
	signal addr_data_low_enable : std_logic;

begin
	-- Compute y coordinate for drawing
	--
	-- Even field: v_pos [22.5, 310)
	-- Odd field: v_pos [335, 622.5)
	--
	-- Difference is 312.5. So, from v_pos*2 and (v_pos-313)*2
	-- we get y coordinate in image where visible image area
	-- is for y in [44, 620)
	--

	process (v_pos)
		variable fv_pos : unsigned(10 downto 0);
	begin
		fv_pos := ('0' & v_pos) - 313;

		if fv_pos(10) = '1' then
			y <= v_pos(9 downto 0) & '0';
		else
			y <= fv_pos(9 downto 0) & '1';
		end if;
	end process;

	--
	-- Active image area measurement
	--

	imgx <= h_pos - 128;
	imgy <= '0' & (y(10 downto 1) - 32); -- is the padding necessary?

	read_addr(4 downto 0) <= imgx(7 downto 3);
	read_addr(12 downto 5) <= imgy(8 downto 1);
	read_addr(15 downto 13) <= "100";
	mem_phase <= imgx(2 downto 0);

	-- Horizontal memio enable is exact (for imgx < 256)
	-- Vertical is simplified (for imgy < 512, should be for imgy < 192*2)
	memio_enable <= '1' when imgx(8) = '0' and imgy(10 downto 8) = 0 else '0';

	--
	-- Memory read cycle
	--

	ale_int <= '1' when mem_phase = 3 else '0';
	addr_high_int <= read_addr(15 downto 8);
	addr_data_low_int <= read_addr(7 downto 0);
	addr_data_low_enable <= '1' when (mem_phase >= 2 and mem_phase < 5) else '0';
	not_rd_int <= '0' when mem_phase >= 6 or mem_phase = 0 else '1';

	ale <= ale_int when memio_enable = '1' else 'Z';
	addr_high <= addr_high_int when memio_enable = '1' else "ZZZZZZZZ";
	addr_data_low_out <= addr_data_low_int;
	addr_data_low_out_en <= addr_data_low_enable;
	not_rd <= not_rd_int when memio_enable = '1' else 'Z';

	-- Video data buffer. An eight-bit register.
	-- At the edge to mem_phase 0 sample data from the memory.
	-- At other clock edges shift left by one.
	process (clock)
	begin
		if rising_edge(clock) then
			if mem_phase = 7 then
				if memio_enable = '1' then
					vdbuf <= addr_data_low_in;
				else
					vdbuf <= "00000000";
				end if;
			else
				vdbuf(7 downto 1) <= vdbuf(6 downto 0);
				vdbuf(0) <= '0';
			end if;
		end if;
	end process;

	-- Uncomment for a checkerboard test pattern
	-- image <= h_pos(4) xor y(4);

	-- Output vfrom vdbuf
	image <= vdbuf(7);
	
end img_gen_arch;
