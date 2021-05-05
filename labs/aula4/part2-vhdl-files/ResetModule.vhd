----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2021 01:12:50 PM
-- Design Name: 
-- Module Name: ResetModule - Behavioral
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

entity ResetModule is
    generic(N : positive := 4);
    Port ( sysClk : in STD_LOGIC;
           resetIn : in STD_LOGIC;
           resetOut : out STD_LOGIC);
end ResetModule;

architecture Behavioral of ResetModule is
    signal s_shiftReg : std_logic_vector((N-1) downto 0) :=(others =>'0');
begin
    assert(N>2);
    shift_proc: process(resetIn, sysClk)
    begin
        if(resetIn = '1') then
            s_shiftReg <= (others =>'0');
        elsif(rising_edge(sysClk)) then
            s_shiftReg((N-1) downto 1) <= s_shiftReg((N-2) downto 0);
            s_shiftReg(0) <= '1';
        end if;
    end process;
    
    resetOut <= not s_shiftReg(N-1);

end Behavioral;

