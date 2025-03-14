library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sim_top is
    Port (  
        clk         : in STD_LOGIC; -- input clock 96kHz
        clr         : in STD_LOGIC; -- input synchronized reset
        adc_data    : in STD_LOGIC_VECTOR(11 DOWNTO 0);
        sout        : out STD_LOGIC;
        led_busy    : out STD_LOGIC
    );
end sim_top;

architecture Behavioral of sim_top is
    component signal_preprocessing is
        Port (
            clk     : in  STD_LOGIC;
            clr     : in  STD_LOGIC;
            data_in : in  STD_LOGIC_VECTOR(11 downto 0);
            data_out: out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component signal_preprocessing;

    component symb_det is
        Port (  clk         : in STD_LOGIC; -- input clock 96kHz
                clr         : in STD_LOGIC; -- input synchronized reset
                adc_data    : in STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
                symbol_valid: out STD_LOGIC;
                symbol_out  : out STD_LOGIC_VECTOR(2 DOWNTO 0) -- output 3-bit detection symbol
                );
    end component symb_det;

    component mcdecoder is
        port (
                din     : IN std_logic_vector(2 downto 0);
                valid   : IN std_logic;
                clr     : IN std_logic;
                clk     : IN std_logic;
                dout    : OUT std_logic_vector(7 downto 0);
                dvalid  : OUT std_logic;
                error   : OUT std_logic);
    end component mcdecoder;

    component myuart is
        Port ( 
            din : in STD_LOGIC_VECTOR (7 downto 0);
            busy: out STD_LOGIC;
            wen : in STD_LOGIC;
            sout : out STD_LOGIC;
            clr : in STD_LOGIC;
            clk : in STD_LOGIC);
    end component myuart;

    signal preprocessed_data : STD_LOGIC_VECTOR(11 downto 0);
    signal symbol_valid     : STD_LOGIC;
    signal symbol_out       : STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol 
    signal dout             : STD_LOGIC_VECTOR(7 downto 0);
    signal dvalid           : STD_LOGIC;
    signal error            : STD_LOGIC;
begin

    -- Instantiate signal preprocessing
    signal_preprocessing_inst: signal_preprocessing
        port map (
            clk     => clk,
            clr     => clr,
            data_in => adc_data,
            data_out => preprocessed_data
        );

    -- Instantiate symbol detection
    symb_det_inst: symb_det port map (
        clk         => clk, 
        clr         => clr, 
        adc_data    => preprocessed_data, 
        symbol_valid=> symbol_valid, 
        symbol_out  => symbol_out
    );

    -- Instantiate music code decoder
    mcdecoder_inst: mcdecoder port map (
        din     => symbol_out, 
        valid   => symbol_valid, 
        clr     => clr, 
        clk     => clk, 
        dout    => dout, 
        dvalid  => dvalid,
        error   => error
    );

    -- Instantiate UART
    myuart_inst: myuart port map (
        din     => dout,
        busy    => led_busy,
        wen     => dvalid,
        sout    => sout,
        clr     => clr,
        clk     => clk
    );

end Behavioral;