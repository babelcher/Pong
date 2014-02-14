----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:01:17 02/12/2014 
-- Design Name: 
-- Module Name:    pong_control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
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
           ball_x : out  unsigned (10 downto 0);
           ball_y : out  unsigned (10 downto 0);
           paddle_y : out  unsigned (10 downto 0));
end pong_control;

architecture Behavioral of pong_control is

	type paddle_state_type is
		(stationary, paddle_up, paddle_down);
	type ball_state_type is
		(moving, hit_top_wall, hit_bottom_wall, hit_right_wall, hit_paddle, hit_left_wall);
	signal paddle_state_reg, paddle_state_next: paddle_state_type;
	signal ball_state_reg, ball_state_next: ball_state_type;
	signal ball_x_next, ball_y_next, paddle_y_next: unsigned(10 downto 0);
	signal ball_x_reg: unsigned(10 downto 0):= to_unsigned(320, 11);
	signal ball_y_reg: unsigned(10 downto 0):= to_unsigned(240, 11);	
	signal count_reg: unsigned(10 downto 0):= "00000000000";
	signal count_next: unsigned(10 downto 0);
	
	signal paddle_y_reg: unsigned(10 downto 0):= to_unsigned(240, 11);
	
	constant TOP_OF_COUNT : integer := 600;
	shared variable x_direction, y_direction : STD_LOGIC := '1'; 
	shared variable x_velocity, y_velocity : integer := 1;

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
	count_next <= 	(others => '0') when count_reg = TOP_OF_COUNT else
						count_reg + 1 when v_completed = '1' else
						count_reg;
					
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
	if(count_reg = TOP_OF_COUNT) then
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
	process(paddle_state_next, paddle_y_reg, count_reg)
	begin
		paddle_y_next <= paddle_y_reg;
		if(count_reg = TOP_OF_COUNT) then
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
	
	--state register for the ball
	process(reset, clk)
	begin			
		if(reset='1') then
			ball_state_reg <= moving;
		elsif(rising_edge(clk)) then
			ball_state_reg <= ball_state_next;
		end if;
	end process;
	
	--output buffer for ball
	process(clk)
	begin
		if(rising_edge(clk)) then
			ball_y_reg <= ball_y_next;
			ball_x_reg <= ball_x_next;
		end if;
	end process;
	
	--next state logic for ball
	process(ball_state_reg, ball_x_reg, ball_y_reg)
	begin
	ball_state_next <= ball_state_reg;
	if(count_reg = TOP_OF_COUNT) then
		case ball_state_reg is
			when moving =>
				if(ball_y_reg = 10) then
					ball_state_next <= hit_top_wall;
				elsif(ball_y_reg = 470) then
					ball_state_next <= hit_bottom_wall;
				elsif(ball_x_reg = 0) then
					ball_state_next <= hit_left_wall;
				elsif(ball_x_reg = 670) then
					ball_state_next <= hit_right_wall;
				elsif(ball_x_reg = 13 and ball_y_reg = paddle_y_reg) then
					ball_state_next <= hit_paddle;
				end if;
			when hit_top_wall =>
				ball_state_next <= moving;
			when hit_right_wall =>
				ball_state_next <= moving;
			when hit_bottom_wall =>
				ball_state_next <= moving;
			when hit_paddle =>
				ball_state_next <= moving;
			when hit_left_wall =>
			end case;
	end if;
	end process;
	
	--look ahead output logic
	process(ball_state_next, ball_y_reg, ball_x_reg, count_reg)
	begin
		ball_y_next <= ball_y_reg;
		ball_x_next <= ball_x_reg;
		if(count_reg = TOP_OF_COUNT) then
			case ball_state_next is
				when hit_left_wall =>
				when moving =>
					if(x_direction = '1' and y_direction = '0') then
						ball_y_next <= ball_y_reg + to_unsigned(y_velocity, 11);
						ball_x_next <= ball_x_reg + to_unsigned(x_velocity, 11);
					elsif(x_direction = '0' and y_direction = '0') then
						ball_y_next <= ball_y_reg + to_unsigned(y_velocity, 11);
						ball_x_next <= ball_x_reg - to_unsigned(x_velocity, 11);
					elsif(x_direction = '0' and y_direction = '1') then
						ball_y_next <= ball_y_reg - to_unsigned(y_velocity, 11);
						ball_x_next <= ball_x_reg - to_unsigned(x_velocity, 11);
					elsif(x_direction = '1' and y_direction = '1') then
						ball_y_next <= ball_y_reg - to_unsigned(y_velocity, 11);
						ball_x_next <= ball_x_reg + to_unsigned(x_velocity, 11);
					end if;
				when hit_top_wall =>
					y_direction := '0';
					ball_y_next <= ball_y_reg - to_unsigned(y_velocity, 11);
				when hit_right_wall =>
					x_direction := '0';
					ball_x_next <= ball_x_reg - to_unsigned(x_velocity, 11);
				when hit_bottom_wall => 
					y_direction := '1';
					ball_y_next <= ball_y_reg + to_unsigned(y_velocity, 11);
				when hit_paddle =>
					x_direction := '1';
					ball_x_next <= ball_x_reg + to_unsigned(x_velocity, 11);
			end case;
		end if;
	end process;
	
	--outputs
	paddle_y <= paddle_y_reg;
	ball_x <= ball_x_reg;
	ball_y <= ball_y_reg;

end Behavioral;

