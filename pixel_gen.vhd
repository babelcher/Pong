----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:13:52 01/29/2014 
-- Design Name: 
-- Module Name:    pixel_gen - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity pixel_gen is
    Port ( row : in  unsigned(10 downto 0);
           column : in  unsigned(10 downto 0);
           blank : in  STD_LOGIC;
			  ball_x   : in unsigned(10 downto 0);
			  ball_y   : in unsigned(10 downto 0);
			  paddle_y : in unsigned(10 downto 0);
           r : out  std_logic_vector(7 downto 0);
           g : out  std_logic_vector(7 downto 0);
           b : out  std_logic_vector(7 downto 0));
end pixel_gen;

architecture Behavioral of pixel_gen is

begin
process(row, column, blank, ball_x, ball_y, paddle_y)
begin
	--draw background
	if(blank = '0') then
		--draw the default black
		r <= (others => '0');
		g <= (others => '0');
		b <= (others => '0');
		--draw the ball
		if((row <= ball_y + 3 and row >= ball_y - 3) and (column <= ball_x + 3 and column >= ball_x - 3)) then
			r <= "11111111";
			g <= (others => '0');
			b <= (others => '0');
		--draw the paddle
		elsif((row <= paddle_y + 30 and row >= paddle_y - 30) and (column <= 13 and column >= 7)) then
			r <= (others => '0');
			g <= "11111111";
			b <= (others => '0');
		end if;
		--top of the A
		if((row <= 130 and row >= 120) and (column <= 315 and column >= 240)) then
			r <= (others => '0');
			g <= (others => '0');
			b <= "11111111";
		--middle of the A
		elsif((row <= 245 and row >= 235) and (column <= 315 and column >= 240)) then
				r <= (others => '0');
				g <= (others => '0');
				b <= "11111111";
		--left side of the A
		elsif((row <= 360 and row >= 130) and (column <= 250 and column >= 240)) then
				r <= (others => '0');
				g <= (others => '0');
				b <= "11111111";
		--right side of the A
		elsif((row <= 360 and row >= 130) and (column <= 315 and column >= 305)) then
				r <= (others => '0');
				g <= (others => '0');
				b <= "11111111";
		--left side of the F
		elsif((row <= 360 and row >= 130) and (column <= 345 and column >= 335)) then
				r <= (others => '0');
				g <= (others => '0');
				b <= "11111111";
		--top of the F
		elsif((row <= 130 and row >= 120) and (column <= 400 and column >= 335)) then
			r <= (others => '0');
			g <= (others => '0');
			b <= "11111111";
		--middle of the F
		elsif((row <= 245 and row >= 235) and (column <= 400 and column >= 335)) then
				r <= (others => '0');
				g <= (others => '0');
				b <= "11111111";		
		end if;
	end if;
end process;
end Behavioral;

