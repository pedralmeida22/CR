----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2021 01:10:20 PM
-- Design Name: 
-- Module Name: CountDownTimer_part1 - Behavioral
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

entity CountDownTimer_part1 is
    Port ( clk : in STD_LOGIC;
           btnR : in STD_LOGIC;
           btnC : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           dp : out STD_LOGIC;
           led : out STD_LOGIC_VECTOR(0 downto 0));
end CountDownTimer_part1;

architecture Structural of CountDownTimer_part1 is

    signal s_reset : std_logic;
    signal s_btnR : std_logic;
    signal s_clk_1Hz, s_clk_2Hz, s_clk_display : std_logic;
    signal s_start_pause : std_logic;
    signal s_finish : std_logic;
    signal s_running : std_logic;
    signal s_point : std_logic;
    signal s_secLSVal, s_secMSVal, s_minLSVal, s_minMSVal : std_logic_vector (3 downto 0);
    signal s_digit_en : std_logic_vector(7 downto 0) := "00001111";
    signal s_point_en : std_logic_vector(7 downto 0);
    
begin
    pulse_generator : entity work.pulse_gen_1Hz(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     pulse => s_clk_1Hz);
                     
    pulse_generator_point : entity work.pulse_gen_2Hz(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     pulse => s_clk_2Hz);
                     
    pulse_gen_displays : entity work.pulse_gen_800Hz(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     pulse => s_clk_display);

    reset_module : entity work.ResetModule(Behavioral)
            generic map(N => 4)
            port map(sysClk => clk,
                     resetIn => s_btnR,
                     resetOut => s_reset);  
                     
    start_pause_button : entity work.DebounceUnit(Behavioral)
            generic map(kHzClkFreq      => 100_000,
                        mSecMinInWidth  => 100,
                        inPolarity      => '1',
                        outPolarity     => '1')
            port map(   refClk => clk,
                        dirtyIn => btnC,
                        pulsedOut => s_start_pause);
                        
    reset_button : entity work.DebounceUnit(Behavioral)
            generic map(kHzClkFreq      => 100_000,
                        mSecMinInWidth  => 100,
                        inPolarity      => '1',
                        outPolarity     => '1')
            port map(   refClk => clk,
                        dirtyIn => btnR,
                        pulsedOut => s_btnR);
                        
    controlpath : entity work.ControlUnit(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     start_pause => s_start_pause,
                     is_finished => s_finish,
                     running => s_running);                     
                        
    datapath : entity work.ExecutionUnit(Behavioral)
            port map(clk => clk,
                    clk_en => s_clk_1Hz,
                    reset => s_reset,
                    running => s_running, -- sinal que vem do control unit
                    secLSVal => s_secLSVal,
                    secMSVal => s_secMSVal,
                    minLSVal => s_minLSVal,
                    minMSVal => s_minMSVal,
                    finish => s_finish);
        
    blinkPoint: process(s_clk_2Hz)
    begin
        if(rising_edge(s_clk_2Hz)) then
            s_point <= not s_point;
        end if;
    end process;
    s_point_en <= "00000" & s_point & "00";
    
    displays : entity work.Nexys4DispDriver2(Behavioral)
            port map(clk => clk,
                     clk_en => s_clk_display, 
                     digit_en => s_digit_en,
                     point_en => s_point_en,
                     digit0 => s_secLSVal,
                     digit1 => s_secMSVal,
                     digit2 => s_minLSVal,
                     digit3 => s_minMSVal,
                     digit4 => "0000",
                     digit5 => "0000",
                     digit6 => "0000",
                     digit7 => "0000",
                     an => an,
                     seg => seg,
                     dp => dp);
    
    led(0) <= s_finish;

end Structural;
