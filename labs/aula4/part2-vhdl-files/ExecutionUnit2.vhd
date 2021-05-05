----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2021 01:59:19 PM
-- Design Name: 
-- Module Name: ExecutionUnit - Behavioral
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


entity ExecutionUnit2 is
    Port ( clk : in STD_LOGIC;
           clk_en : in std_logic;
           clk_en_2hz : in std_logic;
           reset : in STD_LOGIC;
           running : in STD_LOGIC;
           up : in std_logic;
           down : in std_logic;
           setup : in std_logic_vector(3 downto 0);
           secLSVal : out STD_LOGIC_VECTOR (3 downto 0);
           secMSVal : out STD_LOGIC_VECTOR (3 downto 0);
           minLSVal : out STD_LOGIC_VECTOR (3 downto 0);
           minMSVal : out STD_LOGIC_VECTOR (3 downto 0);
           finish : out STD_LOGIC);
end ExecutionUnit2;

architecture Behavioral of ExecutionUnit2 is

    signal s_secLS_finished, s_secMS_finished, s_minLS_finished, s_minMS_finished : std_logic;
    
    -- enables para counters
    signal s_secMS_enable, s_minLS_enable, s_minMS_enable : std_logic;
    
    signal s_up, s_down : std_logic;    

begin
    
    -- setup 2Hz not working
    s_up <= up and clk_en_2hz and (setup(0) or setup(1) or setup(2) or setup(3));
    s_down <= down and clk_en_2hz and (setup(0) or setup(1) or setup(2) or setup(3));
    
    -- s1
    sec_ls_counter : entity work.CounterDown4_part2(Behavioral)
            generic map(MAX => 9)
            port map(clk => clk,
                     clk_en => clk_en,
                     reset => reset,
                     setup => setup(0),
                     up => s_up,
                     down => s_down,
                     enable => running,
                     value_out => secLSVal,
                     is_zero => s_secLS_finished);
                     
     s_secMS_enable <= s_secLS_finished and running;
                     
    -- s2                 
    sec_ms_counter : entity work.CounterDown4_part2(Behavioral)
            generic map(MAX => 5)
            port map(clk => clk,
                     clk_en => clk_en,
                     reset => reset,
                     setup => setup(1),
                     up => s_up,
                     down => s_down,
                     enable => s_secMS_enable,
                     value_out => secMSVal,
                     is_zero => s_secMS_finished);
    
    s_minLS_enable <= s_secMS_enable and s_secMS_finished;
    
    -- m1
    min_ls_counter : entity work.CounterDown4_part2(Behavioral)
            generic map(MAX => 9)
            port map(clk => clk,
                     clk_en => clk_en,
                     reset => reset,
                     setup => setup(2),
                     up => s_up,
                     down => s_down,
                     enable => s_minLS_enable,
                     value_out => minLSVal,
                     is_zero => s_minLS_finished);
       
    s_minMS_enable <= s_minLS_enable and s_minLS_finished;

    --m2
    min_ms_counter : entity work.CounterDown4_part2(Behavioral)
            generic map(MAX => 5)
            port map(clk => clk,
                     clk_en => clk_en,
                     reset => reset,
                     setup => setup(3),
                     up => s_up,
                     down => s_down,
                     enable => s_minMS_enable,
                     value_out => minMSVal,
                     is_zero => s_minMS_finished);

    finish <= s_secLS_finished and s_secMS_finished and s_minLS_finished and s_minMS_finished;
    
end Behavioral;
