
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity CountDownTimer_part2 is
    Port ( clk : in STD_LOGIC;
           btnR : in STD_LOGIC; -- ajuste
           btnL : in STD_LOGIC; -- reset
           btnC : in STD_LOGIC; -- start/pause
           btnU : in std_logic; -- incrementa
           btnD : in std_logic; -- decrementa
           an : out STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           dp : out STD_LOGIC;
           led : out STD_LOGIC_VECTOR(0 downto 0));
end CountDownTimer_part2;

architecture Structural of CountDownTimer_part2 is

    signal s_reset, s_btnR, s_btnU, s_btnD, s_btnL : std_logic;
    signal s_clk_1Hz, s_clk_2Hz, s_clk_4Hz, s_clk_display : std_logic;
    signal s_start_pause : std_logic;
    signal s_finish : std_logic;
    signal s_running : std_logic;
    signal s_point, s_display : std_logic;
    signal s_secLSVal, s_secMSVal, s_minLSVal, s_minMSVal : std_logic_vector (3 downto 0);
    signal s_digit_en : std_logic_vector(7 downto 0) := "00001111";
    signal s_point_en : std_logic_vector(7 downto 0);
    signal s_setup_flag : std_logic_vector(3 downto 0);
    
begin
    pulse_generator : entity work.pulse_gen_1Hz(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     pulse => s_clk_1Hz);
                     
    pulse_generator_point : entity work.pulse_gen_2Hz(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     pulse => s_clk_2Hz);
    
    pulse_gen_blink_displays : entity work.pulse_gen_4Hz(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     pulse => s_clk_4Hz);
                     
    pulse_gen_displays : entity work.pulse_gen_800Hz(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     pulse => s_clk_display);

    reset_module : entity work.ResetModule(Behavioral)
            generic map(N => 4)
            port map(sysClk => clk,
                     resetIn => s_btnL,
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
                        dirtyIn => btnL,
                        pulsedOut => s_btnL);
    
    setup_button : entity work.DebounceUnit(Behavioral)
            generic map(kHzClkFreq      => 100_000,
                        mSecMinInWidth  => 100,
                        inPolarity      => '1',
                        outPolarity     => '1')
            port map(   refClk => clk,
                        dirtyIn => btnR,
                        pulsedOut => s_btnR);
                        
sync_btn: process(clk)
    begin
        if (rising_edge(clk)) then
            s_btnU <= btnU;
            s_btnD <= btnD;
        end if;
    end process;
                                        
    controlpath : entity work.ControlUnit2(Behavioral)
            port map(clk => clk,
                     reset => s_reset,
                     setValue => s_btnR,
                     start_pause => s_start_pause,
                     is_finished => s_finish,
                     running => s_running,
                     setupFlag => s_setup_flag);                     
                        
    datapath : entity work.ExecutionUnit2(Behavioral)
            port map(clk => clk,
                    clk_en => s_clk_1Hz,
                    clk_en_2hz => s_clk_2Hz,
                    reset => s_reset,
                    running => s_running,
                    setup => s_setup_flag, -- do control unit
                    up => s_btnU,
                    down => s_btnD,
                    secLSVal => s_secLSVal,
                    secMSVal => s_secMSVal,
                    minLSVal => s_minLSVal,
                    minMSVal => s_minMSVal,
                    finish => s_finish);
        
    blink_point: process(s_clk_2Hz)
    begin
        if(rising_edge(s_clk_2Hz)) then
            s_point <= not s_point;
        end if;
    end process;
    
    blink_displays: process(s_clk_4Hz)
    begin
        if(rising_edge(s_clk_4Hz)) then
            s_display <= not s_display;
        end if;
    end process;
    
    s_point_en <= "00000" & s_point & "00";
    
    blink_display_2hz: process(s_setup_flag, s_display)
            begin
                case s_setup_flag is
                    when "1000" => s_digit_en <= "0000" & s_display & "111";
                    when "0100" => s_digit_en <= "00001" & s_display & "11";
                    when "0010" => s_digit_en <= "000011" & s_display & "1";
                    when "0001" => s_digit_en <= "0000111" & s_display;
                    when others => s_digit_en <= "00001111";
                end case;
            end process;
    
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
