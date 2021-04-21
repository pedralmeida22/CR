----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/07/2021 12:53:56 PM
-- Design Name: 
-- Module Name: part1_wrapper - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;


entity part1_wrapper is
    Port ( clk : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           seg: out std_logic_vector(6 downto 0);
           dp : out std_logic);
end part1_wrapper;

architecture Behavioral of part1_wrapper is
    signal s_clk : std_logic;

begin
    clk_divider: entity work.ClkDividerN(Behavioral) 
        generic map(k           => 125000)
        port map ( clkIn        => clk,
                   clkOut       => s_clk);
               
    display_driver : entity work.Nexys4DispDriver(Behavioral)
        port map(clk       => s_clk,
                 digit_en   => sw(7 downto 0),
                 point_en   => sw(15 downto 8), 
                 digit0   => "0000",
                 digit1   => "0001", 
                 digit2   => "0010",
                 digit3   => "0011",
                 digit4   => "0100",
                 digit5   => "0101",
                 digit6   => "0110",
                 digit7   => "0111",
                 an  => an,
                 seg => seg,
                 dp  => dp);


end Behavioral;
