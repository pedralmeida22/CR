----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2021 10:35:12 AM
-- Design Name: 
-- Module Name: ControlUnit - Behavioral
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


entity ControlUnit is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_pause : in std_logic;
           is_finished : in STD_LOGIC;
           running : out STD_LOGIC);
end ControlUnit;

architecture Behavioral of ControlUnit is
    type TState is (RUN, PAUSE);
    signal pState, nState: TState;
    
begin

sync_process : process(clk)
    begin
        if (rising_edge (clk)) then
            if (reset = '1') then
                pState <= PAUSE;        
            else
                pState <= nState;
            end if;
         end if;
     end process;    

comb_process : process(pState, clk, reset, start_pause, is_finished)
    begin
        case pState is
            when PAUSE =>
                if (start_pause = '1') then
                    nState <= RUN;
                else
                    nState <= PAUSE;
                end if;              
                running <= '0';
            
            when RUN =>
                running <= '0';
                if (start_pause = '1') then
                    nState <= PAUSE;
                elsif (is_finished = '1') then
                    nState <= PAUSE;
                else 
                    nState <= RUN;
                    running <= '1';                
                end if;     
                  
            when others =>
            running <= '0';
                nState <= PAUSE;
            end case;
        end process;
end Behavioral;
