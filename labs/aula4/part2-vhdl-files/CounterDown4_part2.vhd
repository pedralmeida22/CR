library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CounterDown4_part2 is
    generic(MAX : natural);
    Port ( clk : in STD_LOGIC;
           clk_en : in std_logic;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           setup : in std_logic;
           up : in std_logic;
           down : in std_logic;
           value_out : out std_logic_vector (3 downto 0);
           is_zero : out STD_LOGIC);
end CounterDown4_part2;

architecture Behavioral of CounterDown4_part2 is

    subtype type_count is natural range 0 to MAX;
    
    signal s_value : type_count;
        
begin

    process(clk)
    begin
        if rising_edge (clk) then
            if (reset = '1') then
                s_value <= MAX;
            -- setup
            elsif(clk_en = '1' and setup = '1') then
                if (up = '1') then
                    if (s_value = MAX) then
                        s_value <= 0;
                    else
                        s_value <= s_value + 1;
                    end if;
                elsif (down = '1') then
                    if (s_value = 0) then
                        s_value <= MAX;
                    else
                        s_value <= s_value - 1;
                    end if;
                end if;
            -- default (conta para baixo)
            elsif (enable = '1' and clk_en = '1') then
                if (s_value = 0) then
                    s_value <= MAX;
                else
                    s_value <= s_value - 1;
                end if;            
            end if;
        end if;
    end process;
    
    value_out <= std_logic_vector(to_unsigned(s_value, 4));
    
    is_zero <= '1' when (s_value = 0) else '0';
    
end Behavioral;
