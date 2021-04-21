----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/07/2021 02:29:02 PM
-- Design Name: 
-- Module Name: part2_wrapper - Behavioral
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


entity part2_wrapper is
    Port(  clk : in STD_LOGIC;
           btnC : in std_logic;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           seg: out std_logic_vector(6 downto 0);
           dp : out std_logic);
end part2_wrapper;

architecture Behavioral of part2_wrapper is
    signal s_clk_en : std_logic;
    signal s_reset : std_logic;

begin

    process(clk)
    begin
        if rising_edge (clk) then
            s_reset <= btnC;
        end if;
    end process;
    
    pulse_gen : entity work.pulse_gen_1Hz(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     pulse => s_clk_en);
    
    display_driver : entity work.Nexys4DispDriver2(Behavioral)
        port map(clk      => clk,
                 clk_en  => s_clk_en,
                 digit_en => sw(7 downto 0),
                 point_en => sw(15 downto 8), 
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
