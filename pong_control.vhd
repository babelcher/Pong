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
	signal paddle_state_reg, paddle_state_next: paddle_state_type;
	signal ball_x_next, ball_y_next, paddle_y_next: unsigned(10 downto 0);
	signal ball_x_buf, ball_y_buf, paddle_y_buf: unsigned(10 downto 0);
	
	signal paddle_y_reg: unsigned(10 downto 0):= to_unsigned(240, 11);

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
	
	--logic for position of paddle
	paddle_y_next <= (paddle_y_reg - 1) when paddle_state_reg = paddle_up else
						  (paddle_y_reg + 1) when paddle_state_reg = paddle_down else
						  paddle_y_reg;
	
	--next state logic for paddle
	process(paddle_state_reg, up, down)
	begin
	paddle_state_next <= paddle_state_reg;
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
	end process;
	
	--look ahead output logic
	process(paddle_state_next, paddle_y_next)
	begin
		paddle_y_buf <= paddle_y_reg;		
	end process;
	
	paddle_y <= paddle_y_buf;

end Behavioral;

