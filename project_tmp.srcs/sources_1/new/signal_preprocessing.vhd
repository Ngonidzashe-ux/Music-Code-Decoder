

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2024 17:47:37
-- Design Name: 
-- Module Name: signal_preprocessing - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity signal_preprocessing is
 port (
        clk     : in  STD_LOGIC;
        clr   : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR(11 downto 0);
        data_out: out STD_LOGIC_VECTOR(11 downto 0)
    );
end signal_preprocessing;

architecture Behavioral of signal_preprocessing is
   constant N : integer := 32;
    type shift_register is array (0 to N-1) of unsigned(11 downto 0);
    signal shift_reg : shift_register;
    signal data_sum  : unsigned(16 downto 0) := (others => '0'); -- Sum of N samples
    
begin
    process(clk, clr)
    begin
        if clr = '1' then
            shift_reg <= (others => (others => '0'));
            data_sum <= (others => '0');
        elsif rising_edge(clk) then
            shift_reg(1 to N-1) <= shift_reg(0 to N-2);
            shift_reg(0) <= unsigned(data_in);
            -- Update the sum
            data_sum <= data_sum - shift_reg(N-1) + unsigned(data_in);
        end if;
    end process;
    
    -- Compute the average
    data_out <= std_logic_vector(data_sum(16 downto 5)); 

end Behavioral;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity signal_preprocessing is
--    port (
--        clk     : in  STD_LOGIC;
--        clr     : in  STD_LOGIC;
--        data_in : in  STD_LOGIC_VECTOR(11 downto 0);
--        data_out: out STD_LOGIC_VECTOR(11 downto 0)
--    );
--end signal_preprocessing;

--architecture Behavioral of signal_preprocessing is
--    constant n_taps : integer := 16;
--    type type_byte_array is array (0 to n_taps - 1) of signed(11 downto 0);
--    signal data_sequence : type_byte_array;
--    signal data_sum : signed(15 downto 0);
--    signal data_norm : signed(15 downto 0);
--    type state_t is (idle, sum, norm, output);
--    signal state : state_t := idle;
--begin

--    state_machine: process(clk)
--    begin
--        if clr = '1' then
--            data_sequence <= (others => (others => '0'));
--            data_sum <= (others => '0');
--            data_norm <= (others => '0');
--            data_out <= (others => '0');
--        elsif rising_edge(clk) then
--            case state is
--                when idle =>
--                    if clr = '0' then
--                        state <= sum;
--                    end if;
--                when sum =>
--                    data_sum <= resize(signed(data_in), 16) - resize(data_sequence(n_taps - 1), 16) + resize(data_sum, 16);
--                    data_sequence <= signed(data_in) & data_sequence(0 to n_taps - 2);
--                    state <= norm;
--                when norm =>
--                    data_norm <= data_sum / to_signed(n_taps, 16);
--                    state <= output;
--                when output =>
--                    data_out <= std_logic_vector(data_norm(11 downto 0));
--                    state <= idle;
--            end case;
--        end if;
--    end process state_machine;

--end Behavioral;