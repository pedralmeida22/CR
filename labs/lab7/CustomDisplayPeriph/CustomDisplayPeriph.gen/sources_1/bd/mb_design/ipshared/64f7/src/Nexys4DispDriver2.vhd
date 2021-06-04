----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/07/2021 02:34:59 PM
-- Design Name: 
-- Module Name: Nexys4DispDriver2 - Behavioral
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

entity Nexys4DispDriver2 is
    Port ( clk : in STD_LOGIC;
           reset : in std_logic;
           digit_en : in STD_LOGIC_VECTOR (7 downto 0);
           point_en : in STD_LOGIC_VECTOR (7 downto 0);
           digit0 : in STD_LOGIC_VECTOR (3 downto 0);
           digit1 : in STD_LOGIC_VECTOR (3 downto 0);
           digit2 : in STD_LOGIC_VECTOR (3 downto 0);
           digit3 : in STD_LOGIC_VECTOR (3 downto 0);
           digit4 : in STD_LOGIC_VECTOR (3 downto 0);
           digit5 : in STD_LOGIC_VECTOR (3 downto 0);
           digit6 : in STD_LOGIC_VECTOR (3 downto 0);
           digit7 : in STD_LOGIC_VECTOR (3 downto 0);
           refrRate : in std_logic_vector(2 downto 0);
           brCtrl : in std_logic_vector(2 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           dp : out STD_LOGIC);           
end Nexys4DispDriver2;

architecture Behavioral of Nexys4DispDriver2 is
    signal s_counter : unsigned(2 downto 0) := "000";
    signal s_value : std_logic_vector(3 downto 0);
    signal s_digit_en : std_logic;
    signal s_seg : std_logic_vector(6 downto 0);
    signal s_an, s_brLimit : std_logic_vector(7 downto 0);
    signal s_clk_en : std_logic;
    signal s_clkEnCount : integer := 0;
    
    type LUTable is array (0 to 7, 0 to 7) of integer range 0 to 2_000_000;
    constant BRIGHTNESS_LUT : LUTable :=                                                -- % brightness
        (   (0, 0, 0, 0, 0, 0, 0, 0),                                                   -- 0
            (280_000, 140_000, 70_000, 35_000, 17_500, 8750, 4375, 2188),               -- 14
            (580_000, 290_000, 145_000, 72_500, 36_250, 18_125, 9_063, 4_531),          -- 29
            (860000, 430000, 215000, 107500, 53750, 26875, 13438, 6719),                -- 43
            (1140000, 570000, 285000, 142500, 71250, 35625, 17813, 8906),               -- 57
            (1420000, 710000, 355000, 177500, 88750, 44375, 22188, 11094),              -- 71
            (1720000, 860000, 430000, 215000, 107500, 53750, 26875, 13438),             -- 86
            (2_000_000, 1_000_000, 500_000, 250_000, 125_000, 62_500, 31_250, 15_625)   -- 100
        );
    
begin

    --s_brLimit <= BRIGHTNESS_LUT(TO_INTEGER(unsigned(brCtrl)), TO_INTEGER(unsigned (refrRate))); -- duty cycle
    --BRIGHTNESS_LUT(7, TO_INTEGER(unsigned (refrRate)) - 1) -- for generating enable
    
    clock_enable: process(clk)
                begin
                    if rising_edge(clk) then
                        if(reset = '0') then
                            s_clkEnCount <= 0;
                            s_clk_en <= '0';
                            s_brLimit <= (others => '0');
                        elsif(s_clkEnCount >= BRIGHTNESS_LUT(7, TO_INTEGER(unsigned (refrRate)) - 1)) then
                            s_clkEnCount <= 0;
                            s_clk_en <= '1';
                            s_brLimit <= (others => '1');
                        
                        else
                            s_clkEnCount <= s_clkEnCount + 1;
                            s_clk_en <= '0';
                            s_brLimit <= (others => '0');
                            
                            if(s_clkEnCount >= BRIGHTNESS_LUT(TO_INTEGER(unsigned(brCtrl)), TO_INTEGER(unsigned (refrRate)))) then
                                s_brLimit <= (others => '1');
                            end if;
                            
                        end if;
                    end if;
                end process;

    counter: process(clk)
            begin
                if (rising_edge(clk)) then
                    if (s_clk_en = '1') then
                        s_counter <= s_counter + 1;
                    end if;
                end if;
            end process;

    -- Decoder 3 to 8 for clock
    dec3t8:  process(s_counter)
            begin
                case s_counter is
                    when "000" => s_an <= "11111110";
                    when "001" => s_an <= "11111101";
                    when "010" => s_an <= "11111011";
                    when "011" => s_an <= "11110111";
                    when "100" => s_an <= "11101111";
                    when "101" => s_an <= "11011111";
                    when "110" => s_an <= "10111111";
                    when "111" => s_an <= "01111111";
                end case;
            end process;     
        
    mux8to1: process(s_counter, digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7)
            begin
                case s_counter is
                    when "000" => s_value <= digit0;
                    when "001" => s_value <= digit1;
                    when "010" => s_value <= digit2;
                    when "011" => s_value <= digit3;
                    when "100" => s_value <= digit4;
                    when "101" => s_value <= digit5;
                    when "110" => s_value <= digit6;
                    when "111" => s_value <= digit7;
                end case;
            end process;
            
    disEnMux:  process(s_counter, digit_en)
            begin
                case s_counter is
                    when "000" => s_digit_en <= digit_en(0);
                    when "001" => s_digit_en <= digit_en(1);
                    when "010" => s_digit_en <= digit_en(2);
                    when "011" => s_digit_en <= digit_en(3);
                    when "100" => s_digit_en <= digit_en(4);
                    when "101" => s_digit_en <= digit_en(5);
                    when "110" => s_digit_en <= digit_en(6);
                    when "111" => s_digit_en <= digit_en(7);
                end case;
            end process;
            
    dpMux:  process(point_en, s_counter)
            begin
                case s_counter is
                    when "000" => dp <= not point_en(0);
                    when "001" => dp <= not point_en(1);
                    when "010" => dp <= not point_en(2);
                    when "011" => dp <= not point_en(3);
                    when "100" => dp <= not point_en(4);
                    when "101" => dp <= not point_en(5);
                    when "110" => dp <= not point_en(6);
                    when "111" => dp <= not point_en(7);
                end case;
            end process;
            
    hexToSeg: process(s_value)
            begin
                case s_value is 
                    when "0000" => s_seg <= "1000000";     -- 0 
                    when "0001" => s_seg <= "1111001";     -- 1
                    when "0010" => s_seg <= "0100100";     -- 2
                    when "0011" => s_seg <= "0110000";     -- 3
                    when "0100" => s_seg <= "0011001";     -- 4
                    when "0101" => s_seg <= "0010010";     -- 5
                    when "0110" => s_seg <= "0000010";     -- 6
                    when "0111" => s_seg <= "1111000";     -- 7
                    when "1000" => s_seg <= "0000000";     -- 8
                    when "1001" => s_seg <= "0010000";     -- 9
                    when "1010" => s_seg <= "0001000";     -- A
                    when "1011" => s_seg <= "0000011";     -- B
                    when "1100" => s_seg <= "1000110";     -- C
                    when "1101" => s_seg <= "0100001";     -- D
                    when "1110" => s_seg <= "0000110";     -- E
                    when "1111" => s_seg <= "0001110";     -- F
                    when others => s_seg <= "1111111";     -- no light
                end case;
            end process;
            
    sgMux: process(s_seg, s_digit_en)
           begin
              if (s_digit_en = '1') then
                seg <= s_seg;
              else
                seg <= "1111111";
              end if;
           end process;
           
    an <= s_an or s_brLimit;

end Behavioral;
