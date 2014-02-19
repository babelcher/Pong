----------------------------------------------------------------------------------
-- Author: C2C Brandon Belcher
-- Date: 19 February 2014
-- Function: Uses clock cycles and whether or not the h_sync_gen has completed every
-- column in that specific row and then moves on to the next row.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity v_sync_gen is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           h_completed : in  STD_LOGIC;
           v_sync : out  STD_LOGIC;
           blank : out  STD_LOGIC;
           completed : out  STD_LOGIC;
           row : out  unsigned(10 downto 0));
end v_sync_gen;

architecture v_lookahead_buffer of v_sync_gen is

	type vsync_state_type is
		(active_video, front_porch, sync, back_porch, completed_state);
	signal state_reg, state_next: vsync_state_type;
	signal v_sync_buf, v_sync_next, blank_buf, blank_next, completed_buf, completed_next: STD_LOGIC;
	signal row_buf, row_next: unsigned(10 downto 0);

	signal count_reg: unsigned(10 downto 0):= "00000000000";
	signal count_next: unsigned(10 downto 0);

begin

	--state register
	process(reset, clk)
	begin			
		if(reset='1') then
			state_reg <= active_video;
		elsif(rising_edge(clk)) then
			state_reg <= state_next;
		end if;
	end process;
	
	--output buffer
	process(clk)
	begin
		if (rising_edge(clk)) then
			v_sync_buf <= v_sync_next;
			blank_buf <= blank_next;
			completed_buf <= completed_next;
			row_buf <= row_next;
		end if;
	end process;
	
	count_next <= (others => '0') when state_reg /= state_next else 
						count_reg + 1 when h_completed = '1' else 
						count_reg;
	
	--count register
	process(clk, reset)
	begin
		if (reset = '1') then
			count_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			count_reg <= count_next;
		end if;
	end process;
	
	--next state logic
	process(state_reg, count_reg, h_completed)
	begin
	state_next <= state_reg;
		if(h_completed = '1') then
			case state_reg is 
				when active_video =>
					if( count_reg = 480) then
						state_next <= front_porch;
					end if;
				when front_porch =>
					if (count_reg = 10) then
						state_next <= sync;
					end if;
				when sync =>
					if (count_reg = 2) then
						state_next <= back_porch;					
					end if;
				when back_porch =>
					if (count_reg = 32) then
						state_next <= completed_state;
					end if;
				when completed_state =>
					state_next <= active_video;
			end case;	
		end if;
	end process;
	
	--look ahead output logic
	process(state_next, count_next)
	begin
		v_sync_next <= '1';
		blank_next <= '1';
		completed_next <= '0';
		row_next <= (others => '0');
		case state_next is
			when active_video =>
				blank_next <= '0';
				row_next <= count_reg;
			when front_porch =>
			when sync =>
				v_sync_next <= '0';
			when back_porch =>
			when completed_state =>
				completed_next <= '1';
		end case;
	end process;
	
	--outputs
	v_sync <= v_sync_buf;
	blank <= blank_buf;
	completed <= completed_buf;
	row <= row_buf;

	
end v_lookahead_buffer;

