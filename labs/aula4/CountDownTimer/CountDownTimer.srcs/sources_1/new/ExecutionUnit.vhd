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


entity ExecutionUnit is
    Port ( clk : in STD_LOGIC;
           clk_en : in std_logic;
           reset : in STD_LOGIC;
           running : in STD_LOGIC;
           secLSVal : out STD_LOGIC_VECTOR (3 downto 0);
           secMSVal : out STD_LOGIC_VECTOR (3 downto 0);
           minLSVal : out STD_LOGIC_VECTOR (3 downto 0);
           minMSVal : out STD_LOGIC_VECTOR (3 downto 0);
           finish : out STD_LOGIC);
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is
-- 4 counters em cadeia (M2 M1 S2 S1)
-- vai decrementando (1Hz), quando S1 chega a 0, liga o enable para decrementar o S2
-- assim sucessivamente 

    signal s_secLS_finished, s_secMS_finished, s_minLS_finished, s_minMS_finished : std_logic;
    
    -- enables para counters
    signal s_secMS_enable, s_minLS_enable, s_minMS_enable : std_logic;
    

begin
    
    -- s1
    sec_ls_counter : entity work.CounterDown4(Behavioral)
            generic map(MAX => 9)
            port map(clk => clk,
                     clk_en => clk_en,
                     reset => reset,
                     enable => running,
                     value_out => secLSVal,
                     is_zero => s_secLS_finished);
                     
     s_secMS_enable <= s_secLS_finished and running;
                     
    -- s2                 
    sec_ms_counter : entity work.CounterDown4(Behavioral)
            generic map(MAX => 5)
            port map(clk => clk,
                     clk_en => clk_en,
                     reset => reset,
                     enable => s_secMS_enable,
                     value_out => secMSVal,
                     is_zero => s_secMS_finished);
    
    s_minLS_enable <= s_secMS_enable and s_secMS_finished;
    
    -- m1
    min_ls_counter : entity work.CounterDown4(Behavioral)
            generic map(MAX => 9)
            port map(clk => clk,
                     clk_en => clk_en,
                     reset => reset,
                     enable => s_minLS_enable,
                     value_out => minLSVal,
                     is_zero => s_minLS_finished);
       
    s_minMS_enable <= s_minLS_enable and s_minLS_finished;

    --m2
    min_ms_counter : entity work.CounterDown4(Behavioral)
            generic map(MAX => 5)
            port map(clk => clk,
                     clk_en => clk_en,
                     reset => reset,
                     enable => s_minMS_enable,
                     value_out => minMSVal,
                     is_zero => s_minMS_finished);

    finish <= s_secLS_finished and s_secMS_finished and s_minLS_finished and s_minMS_finished;
    
end Behavioral;
