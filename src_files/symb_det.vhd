----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Jiajun Wu
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top
-- Module Name: top - Behavioral
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

----------------------------------------------------------------------------------
-- Course: ELEC3342
-- Module Name: mucodec - Behavioral Testbench
-- Project Name: Template for Music Code Decoder for Homework 1
-- Created By: hso and jjwu
--
-- Copyright (C) 2023 Hayden So
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity symb_det is
    Port (  clk: in STD_LOGIC; -- input clock 96kHz
            clr: in STD_LOGIC; -- input synchronized reset
            adc_data: in STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
            symbol_valid: out STD_LOGIC;
            symbol_out: out STD_LOGIC_VECTOR(2 DOWNTO 0) -- output 3-bit detection symbol
            );
end symb_det;

architecture Behavioral of symb_det is
    type state_type is (St_IDLE, ST_DETECT_BEGIN, St_PROCESS_FREQ, St_GENERATE_SYMBOL, St_WAIT);
    signal state, next_state : state_type := St_IDLE;
    signal prev_sample : SIGNED(11 downto 0);
    signal curr_sample : SIGNED(11 downto 0);
    signal zcd : STD_LOGIC := '0';
    signal cycle_counter : integer := 0;
    signal delay_count : integer:=0;
    signal start : STD_LOGIC := '0';
    signal complete : STD_LOGIC := '0';
    signal initial_delay_count : integer := 0;
    signal  symbol_valid_freq_count : integer := 0;


begin
    sync_process: process (clk, clr)
    begin
        if clr = '1' then
            state <= St_IDLE;
            prev_sample <= (others => '0');
            curr_sample <= (others => '0');
        elsif rising_edge(clk) then
            state <= next_state; 
        end if;
    end process;


   state_logic: process (clk, state)
    begin
       if rising_edge(clk) then
            next_state <= state;  
            case(state) is
                when St_IDLE =>
--                    if adc_data /= "000000000000" then --This was with no problems with Mic3
                        if adc_data /= "011111111111" then --This is the adc reading from mic3 when there is no sound

                            next_state <= St_DETECT_BEGIN;
                        end if;
                    
                when ST_DETECT_BEGIN =>
                    if initial_delay_count > 10 then
                        next_state <= St_PROCESS_FREQ;
                    end if;
            
                when St_PROCESS_FREQ =>
                    if zcd = '1' then
                        next_state <= St_GENERATE_SYMBOL;
                    end if;

                when St_GENERATE_SYMBOL =>
                    next_state <= St_WAIT;
                
                when St_WAIT =>
                    if delay_count >= 6000 then
                        next_state <= St_PROCESS_FREQ;
                    end if;  
            end case;
        end if;
    end process;


    output_logic: process ( clk)--, clk)
    variable start_var : std_logic := '0';
    variable complete_var : std_logic := '0';
    variable  zero_crossing_var : std_logic := '0';
    variable curr_sample_var : SIGNED(11 downto 0);
    variable prev_sample_var : SIGNED(11 downto 0);
    variable symbol_out_varr : STD_LOGIC_VECTOR(2 downto 0);
    variable  cycle_count_var : integer := 0;
    variable symbol_valid_var : std_logic := '0';
    variable  delay_count_var : integer := 0;
    variable  initial_delay_count_var : integer := 0;
    variable  symbol_valid_freq_count_var : integer := 0;
    variable symbol_output : STD_LOGIC_VECTOR(2 downto 0);
    variable mic3_offset : SIGNED(11 downto 0) := "100000000000";


    begin
        if rising_edge(clk) then
            case(state) is
                when St_IDLE =>
                report "IDLE";
                    symbol_out_varr := "000";

    
                when ST_DETECT_BEGIN =>
                    initial_delay_count_var := initial_delay_count_var + 1;
                    report "DETECT BEGIN";


                when St_PROCESS_FREQ =>
                    report "PROCESS_FREQ";

                    delay_count_var := 0;
                    symbol_valid_freq_count_var := 0;
                    --curr_sample_var := SIGNED(adc_data);
                    curr_sample_var := SIGNED(adc_data) - mic3_offset;

                    if to_integer(curr_sample_var) > 0 and to_integer(prev_sample_var) < 0 then
                        if start_var = '0' then
                            start_var := '1';
                        else
                            complete_var := '1';
                            zero_crossing_var := '1';
                        end if;
                    else
                        if start_var = '1' and complete_var = '0' then
                            cycle_count_var := cycle_count_var + 1;
                        elsif start_var = '1' and complete_var = '1' then
                            complete_var := '0';
                            start_var := '0';
                        end if;
                    end if;
                    prev_sample_var := curr_sample_var;  
                
    
                when St_GENERATE_SYMBOL =>
                    report "GENERATE";
                    symbol_valid_var := '1';
                    if cycle_counter > 0 AND symbol_valid_var = '1' then
                            if cycle_counter >= 42 and cycle_counter <= 48 then
                                symbol_output := "000"; -- Symbol 0
                            elsif cycle_counter >= 52 and cycle_counter <= 56 then
                                symbol_output := "001"; -- Symbol 1

                            elsif cycle_counter >= 66 and cycle_counter <= 71 then
                                symbol_output := "010"; -- Symbol 2

                            elsif cycle_counter >= 80 and cycle_counter <= 84 then
                                symbol_output := "011"; -- Symbol 3

                            elsif cycle_counter >= 94 and cycle_counter <= 100 then
                                symbol_output := "100"; -- Symbol 4

                            elsif cycle_counter >= 120 and cycle_counter <= 125 then
                                symbol_output := "101"; -- Symbol 5

                            elsif cycle_counter >= 140 and cycle_counter <= 146 then
                                symbol_output := "110"; -- Symbol 6

                            elsif cycle_counter >= 180 and cycle_counter <= 186 then
                                symbol_output := "111"; -- Symbol 7

                            end if;
                            symbol_valid_var := '0';
                            cycle_count_var := 0;
                            zero_crossing_var := '0';
                    end if;


                when ST_WAIT =>
                    symbol_valid_var := '0';
                    delay_count_var := delay_count_var + 1;
            end case;
        cycle_counter <= cycle_count_var;
        zcd <= zero_crossing_var;
        symbol_out <= symbol_output;
        symbol_valid <= symbol_valid_var;
        initial_delay_count <= initial_delay_count_var;
        delay_count <= delay_count_var;
        symbol_valid_freq_count <= symbol_valid_freq_count_var;
        start <= start_var;
        complete <= complete_var;

    end if;
    end process;

    
end Behavioral;

