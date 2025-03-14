----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer:
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top
-- Module Name: uart
-- Project Name: Music Decoder
-- Target Devices: Xilinx Basys3
-- Tool Versions: Vivado 2022.1
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
library UNISIM;
use UNISIM.VComponents.all;

entity myuart is
    generic ( clks_per_bit : integer := 10 );
    Port ( 
           din : in STD_LOGIC_VECTOR (7 downto 0);
           busy: out STD_LOGIC;
           wen : in STD_LOGIC;
           sout : out STD_LOGIC;
           clr : in STD_LOGIC;
           clk : in STD_LOGIC);
end myuart;

architecture rtl of myuart is
    type state_type is (idle, read, start, transmit, stop);
    signal state, next_state: state_type;
    signal clkcount: integer range 0 to clks_per_bit-1 := 0;
    signal bitindex: integer range 0 to 7 := 0;
    signal data: std_logic_vector(7 downto 0);
    
begin
    sync_process : process(clr, clk)
    begin
        if clr = '1' then
            state <= idle;
            clkcount <= 0;
            bitindex <= 0;
            data <= (others => '0');
        elsif rising_edge(clk) then
            state <= next_state;
            case state is
                when idle =>
                    clkcount <= 0;
                    bitindex <= 0;
                when read =>
                    data <= din;
                    clkcount <= 0;
                when start =>
                    if clkcount = clks_per_bit-1 then
                        clkcount <= 0;
                    else
                        clkcount <= clkcount + 1;
                    end if;
                when transmit =>
                    if clkcount = clks_per_bit-1 then
                        clkcount <= 0;
                        if bitindex = 7 then
                            bitindex <= 0;
                        else
                            bitindex <= bitindex + 1;
                        end if;
                    else
                        clkcount <= clkcount + 1;
                    end if;
                when stop =>
                    if clkcount = clks_per_bit-1 then
                        clkcount <= 0;
                    else
                        clkcount <= clkcount + 1;
                    end if;
            end case;
        end if;
    end process;
    
    state_logic : process(state, wen, clkcount, bitindex)
    begin
        next_state <= state;
        case state is
            when idle =>
                if wen = '1' then
                    next_state <= read;
                end if;
            when read =>
                next_state <= start;
            when start =>
                if clkcount = clks_per_bit-1 then
                    next_state <= transmit;
                end if;
            when transmit =>
                if bitindex = 7 and clkcount = clks_per_bit-1 then
                    next_state <= stop;
                end if;
            when stop =>
                if clkcount = clks_per_bit-1 then
                    next_state <= idle;
                end if;
        end case;
    end process;
    
    output_logic : process(state, data, bitindex)
    begin
        case state is
            when idle =>
                busy <= '0';
                sout <= '1';
            when read =>
                busy <= '1';
                sout <= '1';
            when start =>
                busy <= '1';
                sout <= '0';
            when transmit =>
                busy <= '1';
                sout <= data(bitindex);
            when stop =>
                busy <= '1';
                sout <= '1';
        end case;
    end process;

end rtl;