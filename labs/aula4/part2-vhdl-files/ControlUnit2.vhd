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


entity ControlUnit2 is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           setValue : in STD_LOGIC;
           start_pause : in std_logic;
           is_finished : in STD_LOGIC;
           running : out STD_LOGIC;
           setupFlag : out std_logic_vector(3 downto 0));
end ControlUnit2;

architecture Behavioral of ControlUnit2 is
    type TState is (RUN, PAUSE, S1, S2, S3, S4);
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

comb_process : process(pState, clk, reset, start_pause, is_finished, setValue)
    begin
        case pState is
            when PAUSE =>
                setupFlag <= "0000";
                if (start_pause = '1') then
                    nState <= RUN;
                elsif (setValue = '1') then
                    nState <= S1;
                else
                    nState <= PAUSE;
                end if;              
            
            when S1 =>
                running <= '0';
                setupFlag <= "1000";
                if (setValue = '1') then
                    nState <= S2;
                else
                    nState <= S1;
                end if;
                
            when S2 =>
                running <= '0';
                setupFlag <= "0100";
                if (setValue = '1') then
                    nState <= S3;
                else
                    nState <= S2;
                end if;
                
            when S3 =>
                running <= '0';
                setupFlag <= "0010";
                if (setValue = '1') then
                    nState <= S4;
                else
                    nState <= S3;
                end if;
                
            when S4 =>
                running <= '0';
                setupFlag <= "0001";
                if (setValue = '1') then
                    nState <= RUN;
                else
                    nState <= S4;    
                end if;
                        
            when RUN =>
                running <= '0';
                setupFlag <= "0000";
                if (start_pause = '1') then
                    nState <= PAUSE;
                elsif (is_finished = '1') then
                    nState <= PAUSE;
                elsif (setValue = '1') then
                    nState <= S1;
                else 
                    nState <= RUN;
                    running <= '1';                
                end if;     
                  
            when others =>
                setupFlag <= "0000";
                running <= '0';
                nState <= PAUSE;
            end case;
        end process;
end Behavioral;
