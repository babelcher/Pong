----------------------------------------------------------------------------------
-- Author: C2C Brandon Belcher
-- Date: 19 February 2014
-- Function: Contains the logic to get the pong game to work correctly. Outputs the 
-- positions of the paddle and ball so that they can be drawn via pixel_gen.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pong_control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           v_completed : in  STD_LOGIC;
			  speed : in STD_LOGIC;
           ball_x : out  unsigned (10 downto 0);
           ball_y : out  unsigned (10 downto 0);
           paddle_y : out  unsigned (10 downto 0));
end pong_control;

architecture Behavioral of pong_control is

	type paddle_state_type is
		(stationary, paddle_up, paddle_down);
	type ball_state_type is
		(moving, hit_top_wall, hit_bottom_wall, hit_right_wall, hit_paddle_top, hit_paddle_bottom, hit_left_wall);
	signal paddle_state_reg, paddle_state_next: paddle_state_type;
	signal ball_state_reg, ball_state_next: ball_state_type;
	signal ball_x_next, ball_y_next, paddle_y_next: unsigned(10 downto 0);
	signal ball_x_reg: unsigned(10 downto 0):= to_unsigned(320, 11);
	signal ball_y_reg: unsigned(10 downto 0):= to_unsigned(240, 11);	
	signal count_reg: unsigned(10 downto 0):= "00000000000";
	signal count_next, velocity: unsigned(10 downto 0);
	signal x_direction_reg, y_direction_reg, x_direction_next, y_direction_next, stop_reg, stop_next: STD_LOGIC;
	signal x_velocity, y_velocity: integer:= 1;
	
	
	signal paddle_y_reg: unsigned(10 downto 0):= to_unsigned(240, 11);
	
	constant SLOW, TOP_OF_COUNT : integer := 600;
	constant FAST : integer := 200;
	

begin

	--state register for paddle
	process(reset, clk)
	begin			
		if(reset='1') then
			paddle_state_reg <= stationary;
		elsif(rising_edge(clk)) then
			paddle_state_reg <= paddle_state_next;
		end if;
	end process;

	--output buffer for paddle
	process(clk)
	begin
		if(rising_edge(clk)) then
			paddle_y_reg <= paddle_y_next;
		end if;
	end process;
						  
	--logic for the counter
	count_next <= 	(others => '0') when count_reg = velocity else
						count_reg + 1 when v_completed = '1' else
						count_reg;
						
	--velocity logic
	velocity <= to_unsigned(FAST, 11) when speed = '1' else
					to_unsigned(SLOW, 11);
					
	--count register
	process(clk, reset)
	begin
		if reset = '1' then
			count_reg <= (others => '0');
		elsif rising_edge(clk) then
			count_reg <= count_next;
		end if;
	end process;
	
	--next state logic for paddle
	process(paddle_state_reg, up, down)
	begin
	paddle_state_next <= paddle_state_reg;
	if(count_reg = 0) then
		case paddle_state_reg is
			when stationary =>
				if(up = '1') then
					paddle_state_next <= paddle_up;
				elsif(down = '1') then
					paddle_state_next <= paddle_down;
				end if;
			when paddle_up =>
				if(up = '0') then
					paddle_state_next <= stationary;
				elsif(down = '1') then
					paddle_state_next <= paddle_down;
				end if;
			when paddle_down =>
				if(down = '0') then
					paddle_state_next <= stationary;
				elsif(up = '1') then
					paddle_state_next <= paddle_up;
				end if;
			end case;
	end if;
	end process;
	
	--look ahead output logic
	process(paddle_state_next, paddle_y_reg, count_reg, v_completed)
	begin
		paddle_y_next <= paddle_y_reg;
		if(count_reg = 0 and v_completed = '1') then
		case paddle_state_next is
			when stationary =>
			when paddle_up =>
				if(paddle_y_reg > 30) then
					paddle_y_next <= paddle_y_reg - to_unsigned(1,11);
				end if;
			when paddle_down =>
				if(paddle_y_reg <= 450) then
					paddle_y_next <= paddle_y_reg + to_unsigned(1,11);
				end if;
		end case;
		end if;
	end process;
	---------------------------------------------------------------------------------------------------------------------------
	
	--state register for the ball
	process(reset, clk)
	begin			
		if(reset='1') then
			ball_state_reg <= moving;
		elsif(rising_edge(clk)) then
			ball_state_reg <= ball_state_next;
		end if;
	end process;
	
	--ball direction register
	process(clk, reset)
	begin
		if(reset = '1') then
			x_direction_reg <= '1';
			y_direction_reg <= '1';
			stop_reg <= '0';
		elsif(rising_edge(clk)) then
			x_direction_reg <= x_direction_next;
			y_direction_reg <= y_direction_next;
			stop_reg <= stop_next;
		end if;
	end process;
	
	--ball position register
	process(clk, reset)
	begin
		if(reset = '1') then
			ball_x_reg <= to_unsigned(320, 11);
			ball_y_reg <= to_unsigned(240, 11);
		elsif(rising_edge(clk)) then
			ball_x_reg <= ball_x_next;
			ball_y_reg <= ball_y_next;
		end if;
	end process;
	
	--
	
	--next state logic for ball
	process(ball_state_reg, ball_state_next, ball_x_reg, ball_y_reg, paddle_y_reg, count_reg)
	begin
	ball_state_next <= ball_state_reg;
	if(count_reg = 0) then
		case ball_state_reg is
			when moving =>
				if(ball_y_reg = to_unsigned(10, 11)) then
					ball_state_next <= hit_top_wall;
				elsif(ball_y_reg = to_unsigned(470, 11)) then
					ball_state_next <= hit_bottom_wall;
				elsif(ball_x_reg = to_unsigned(10, 11)) then
					ball_state_next <= hit_left_wall;
				elsif(ball_x_reg = to_unsigned(630, 11)) then
					ball_state_next <= hit_right_wall;
				end if;
				if(ball_x_reg = to_unsigned(13, 11)) then
					if((ball_y_reg >= paddle_y_reg - to_unsigned(30, 11)) and (ball_y_reg <= paddle_y_reg)) then
						ball_state_next <= hit_paddle_top;
					elsif((ball_y_reg <= paddle_y_reg + to_unsigned(30, 11)) and (ball_y_reg >= paddle_y_reg)) then
						ball_state_next <= hit_paddle_bottom;
					end if;
				end if;
			when hit_top_wall =>
				ball_state_next <= moving;
			when hit_right_wall =>
				ball_state_next <= moving;
			when hit_bottom_wall =>
				ball_state_next <= moving;
			when hit_paddle_top =>
				ball_state_next <= moving;
			when hit_paddle_bottom =>
				ball_state_next <= moving;
			when hit_left_wall =>
				ball_state_next <= moving;
			end case;
	end if;
	end process;
	
	--ball direction output logic
	process(ball_state_next, x_direction_reg, y_direction_reg, count_reg, stop_reg)
	begin
		y_direction_next <= y_direction_reg;
		x_direction_next <= x_direction_reg;
		stop_next <= stop_reg;
		if(count_reg = 0) then
			case ball_state_next is
				when hit_left_wall =>
					x_direction_next <= '1';
					stop_next <= '1';
				when moving =>
					y_direction_next <= y_direction_reg;
					x_direction_next <= x_direction_reg;
				when hit_top_wall =>
					y_direction_next <= '0';					
				when hit_right_wall =>
					x_direction_next <= '0';					
				when hit_bottom_wall => 
					y_direction_next <= '1';					
				when hit_paddle_top =>
					x_direction_next <= '1';
					y_direction_next <= '1';
				when hit_paddle_bottom =>
					x_direction_next <= '1';
					y_direction_next <= '0';
			end case;
		end if;
	end process;
	
	process(count_reg, ball_x_reg, ball_y_reg, v_completed, stop_reg)
	begin
	ball_x_next <= ball_x_reg;
	ball_y_next <= ball_y_reg;
		if(count_reg = 0 and v_completed = '1' and stop_reg = '0') then
			if(x_direction_reg = '1') then
				ball_x_next <= ball_x_reg + 1;
			else
				ball_x_next <= ball_x_reg - 1;
			end if;
			if(y_direction_reg = '1') then
				ball_y_next <= ball_y_reg - 1;
			else
				ball_y_next <= ball_y_reg + 1;
			end if;
		end if;
	end process;
	
	--outputs
	paddle_y <= paddle_y_reg;
	ball_x <= ball_x_reg;
	ball_y <= ball_y_reg;

end Behavioral;

