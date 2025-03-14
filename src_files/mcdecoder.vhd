----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Mo Song
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


LIBRARY ieee;

USE ieee.std_logic_1164.ALL;

use ieee.numeric_std.all;

entity mcdecoder is

    port (

        din     : IN std_logic_vector(2 downto 0);

        valid   : IN std_logic;

        clr     : IN std_logic;

        clk     : IN std_logic;

        dout    : OUT std_logic_vector(7 downto 0);

        dvalid  : OUT std_logic;

        error   : OUT std_logic);

end mcdecoder;

architecture Behavioral of mcdecoder is

    type state_type is (St_RESET, St_ERROR,BOS2, BOS3, BOS4,DECODE1, DECODE2, EOS1,EOS2,EOS3);

    signal state, next_state : state_type := St_RESET;

    signal row_val : std_logic_vector(2 downto 0);

    signal col_val : std_logic_vector(2 downto 0);

    signal x: integer := 0;

    constant ZERO_VECTOR : std_logic_vector(2 downto 0) := "000";

 type CharArrayType is array (1 to 6, 1 to 6) of std_logic_vector(7 downto 0);

    

    -- Declare the array

    signal CharArray : CharArrayType := (

        (x"00", x"41", x"42", x"43", x"44", x"45"),  -- NA, A, B, C, D, E

        (x"46", x"00", x"47", x"48", x"49", x"4A"),  -- F, NA, G, H, I, J

        (x"4B", x"4C", x"00", x"4D", x"4E", x"4F"),  -- K, L, NA, M, N, O

        (x"50", x"51", x"52", x"00", x"53", x"54"),  -- P, Q, R, NA, S, T

        (x"55", x"56", x"57", x"58", x"00", x"59"),  -- U, V, W, X, NA, Y

        (x"5A", x"21", x"2E", x"3F", x"20", x"00")   -- Z, !, ., ?, SPACE, NA

    );

  

    begin

    sync_process: process (clk, clr)

    begin

        if clr = '1' then

            state <= St_RESET;

        elsif rising_edge(clk) then

            state <= next_state;  -- Make sure to update state on the clock edge   

        end if;

    end process;

    state_logic: process (clk)

    begin

        if rising_edge(clk) then

        if valid = '1' then 

        -- Initialize next_state

        next_state <= state;  -- Start by assuming the next state is the same as the current state

        case(state) is

            when St_RESET =>

                                x <= to_integer(unsigned(din));

                report integer'image(x);

                if din = "000" and valid = '1' then

        

                    next_state <= BOS2;

--                else

--                    REPORT "WENT BACK TO RESET";

--                    next_state <= St_RESET;

                end if;

                    

            when BOS2 =>

                report " IN BOS2";

                                                x <= to_integer(unsigned(din));

                report integer'image(x);

                if  din = "111" then

                    next_state <= BOS3;  -- Update next_state instead of state

                else

                    next_state <= St_RESET;

                end if;

            when BOS3 =>

                report " IN BOS3";

                if  din = "000"  then

                                x <= to_integer(unsigned(din));

                report integer'image(x);

                    next_state <= BOS4;

                else

                    next_state <= St_RESET;

                end if;

            when BOS4 =>

                report " IN BOS4";

                if din = "111" then

                                x <= to_integer(unsigned(din));

                report integer'image(x);

                    next_state <= DECODE1;  -- Remains in the same state

                else

                    next_state <= St_ERROR;

                

                end if;

            when DECODE1 =>

                report " IN DECODE1";

                x <= to_integer(unsigned(din));

                report integer'image(x);

                report "##########";  

                if din = "111" then             

                    next_state <= EOS1;

                elsif din = "000" then

                    next_state <= St_ERROR;

                else

                    next_state <= DECODE2;

                end if;

            when DECODE2 =>

            report " IN DECODE2";

                x <= to_integer(unsigned(din));

                report integer'image(x);

                report "@@@@@@@@@@@";  

                if din = "000" then

                    next_state <= St_ERROR;

                elsif din = "111" then

                    next_state <= EOS1;

                else

                    -- 

                    next_state <= DECODE1;

                end if;

                

            when EOS1 =>

                report " IN EOS1";

                if din = "000"  then

                    next_state <= EOS2;

                else

                    next_state <= St_ERROR;

                end if;

                

            when EOS2 =>      

                report " IN EOS2";

                if din = "111"  then

                    next_state <= EOS3;

                else

                    next_state <= St_ERROR;

                end if;

            when EOS3 =>

                report " IN EOS3";

                if din = "000"  then

                    next_state <= St_RESET;

                else

                    next_state <= St_ERROR;

                end if;

        

            when St_ERROR =>     

                report " IN ERROR";

                next_state <= St_RESET;

        end case;

        end if;

        end if;

    end process;

    output_logic: process (clk)

    begin

        if rising_edge(clk) then

        dvalid <= '0';

        if valid = '1' then

        case(state) is

            when St_ERROR =>

                error <= '1';

                dvalid <= '0';

            when St_RESET =>

                error <= '0';

                dvalid <= '0';

                row_val <= din;

            when DECODE1 =>

                error <= '0';

                dvalid <= '0';

                row_val <= din;

            when DECODE2 =>

                error <= '0';

                col_val <= din;

                dvalid <= '1';

                dout <= CharArray(to_integer(unsigned(row_val)), to_integer(unsigned(din)));

            when others =>

                error <= '0';

                dvalid <= '0';

        end case;

        end if;

        end if;

    end process;

    

end Behavioral;


