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
           r : out  std_logic_vector(7 downto 0);
           g : out  std_logic_vector(7 downto 0);
           b : out  std_logic_vector(7 downto 0));
end pixel_gen;

architecture Behavioral of pixel_gen is

begin
process(row, column, blank)
begin
	if(blank = '0') then
	if(row < 400) then
		if(column < 210) then
			r <= "11111111";
			g <= (others => '0');
			b <= (others => '0');
		elsif(column >= 210 and column < 420) then
			r <= (others => '0');
			g <= "11111111";
			b <= (others => '0');
		else
			r <= (others => '0');
			g <= (others => '0');
			b <= "11111111";
		end if;
	else
		r <= (others => '0');
		g <= "11111111";
		b <= "11111111";
	end if;
	end if;
end process;
end Behavioral;

