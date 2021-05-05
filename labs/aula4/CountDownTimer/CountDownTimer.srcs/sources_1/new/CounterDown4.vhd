----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2021 10:48:08 AM
-- Design Name: 
-- Module Name: CounterDown4 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;


entity CounterDown4 is
    generic(MAX : natural);
    Port ( clk : in STD_LOGIC;
           clk_en : in std_logic;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           value_out : out std_logic_vector (3 downto 0);
           is_zero : out STD_LOGIC);
end CounterDown4;

architecture Behavioral of CounterDown4 is

    subtype type_count is natural range 0 to MAX;
    
    signal s_value : type_count;
        
begin

    process(clk)
    begin
        if rising_edge (clk) then
            if (reset = '1') then
                s_value <= MAX;
            elsif (enable = '1' and clk_en = '1') then
                if (s_value = 0) then
                    s_value <= MAX;
                else
                    s_value <= s_value - 1;
                end if;            
            end if;
        end if;
    end process;
    
    value_out <= std_logic_vector(to_unsigned(s_value, 4));
    
    is_zero <= '1' when (s_value = 0) else '0';
    
end Behavioral;
