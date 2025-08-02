-- uart_rx.vhd: UART Receiver Implementation
--
-- Description:
--   Complete UART receiver implementation with the following features:
--   - 8-bit data reception with start/stop bits
--   - 16x oversampling for robust bit detection
--   - Metastability protection for asynchronous inputs
--   - Finite state machine control
--   - Configurable baud rate (default 9600 bps)
--
-- Protocol:
--   Frame format: [START][D0][D1][D2][D3][D4][D5][D6][D7][STOP]
--   Data bits are received LSB first
--   Start bit = '0', Stop bit = '1'
--
-- Author(s): Michal Balogh (xbalog06)
-- Date: 2025
-- Project: INC-Projekt (Digital Design Course)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration for UART Receiver
-- Note: Do not modify this interface as it may be used by external modules
entity UART_RX is
    port(
        CLK      : in  std_logic;                    -- System clock (16x baud rate)
        RST      : in  std_logic;                    -- Asynchronous reset (active high)
        DIN      : in  std_logic;                    -- Serial data input
        DOUT     : out std_logic_vector(7 downto 0); -- Parallel data output
        DOUT_VLD : out std_logic                     -- Data valid output pulse
    );
end entity;



-- UART Receiver Architecture Implementation
architecture behavioral of UART_RX is
    
    -- Internal counters
    signal bit_cnt  : std_logic_vector(3 downto 0); -- Bit counter (0-8)
    signal clk_cnt  : std_logic_vector(3 downto 0); -- Clock counter (0-15)
    
    -- Control signals from FSM
    signal rst_cnt  : std_logic := '0';              -- Reset clock counter
    signal rst_bit  : std_logic := '0';              -- Reset bit counter
    signal vld_out  : std_logic := '0';              -- Internal valid signal
    
    -- Data storage
    signal reg_data : std_logic_vector(7 downto 0);  -- Shift register for incoming data
    
    -- Synchronized input signals (metastability protection)
    signal din_sync1 : std_logic;                    -- First synchronizer stage
    signal din_sync2 : std_logic;                    -- Second synchronizer stage (clean)
    
    -- Synchronized reset signals
    signal rst_sync1 : std_logic;                    -- First reset synchronizer stage
    signal rst_sync2 : std_logic;                    -- Second reset synchronizer stage

begin

    -- Instantiate UART RX Finite State Machine
    uart_fsm: entity work.UART_RX_FSM
    port map (
        CLK       => CLK,
        RST       => RST,
        DIN_FSM   => din_sync2,    -- Use synchronized input
        NEXT_BIT  => clk_cnt,
        READY     => clk_cnt(2 downto 0),
        BIT_CNT   => bit_cnt,  
        RST_BIT   => rst_bit,
        RST_CNT   => rst_cnt,
        VLD_OUT   => vld_out
    );

    -- Input synchronizer for metastability protection
    -- Two flip-flop synchronizer chain
    input_synchronizer: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                din_sync1 <= '1';  -- Default to idle state
                din_sync2 <= '1';
            else
                din_sync1 <= DIN;
                din_sync2 <= din_sync1;
            end if;
        end if;
    end process input_synchronizer;

    -- Reset synchronizer (optional, for very clean design)
    reset_synchronizer: process(CLK)
    begin
        if rising_edge(CLK) then
            rst_sync1 <= RST;
            rst_sync2 <= rst_sync1;
        end if;
    end process reset_synchronizer;

    -- Connect internal valid signal to output
    DOUT_VLD <= vld_out;
    
    -- Main data path and counter management
    main_process: process (CLK) 
    begin
        if rising_edge(CLK) then
            if RST = '1' then 
                -- Reset all counters and data
                bit_cnt <= (others => '0');
                clk_cnt <= (others => '0');
                reg_data <= (others => '0');
                DOUT <= (others => '0');
            else
                -- Clock counter management (16x oversampling)
                if rst_cnt = '1' then
                    clk_cnt <= (others => '0');
                else 
                    clk_cnt <= clk_cnt + 1;
                end if;

                -- Bit counter and data shift register management
                if rst_bit = '1' then   
                    bit_cnt <= (others => '0');
                elsif clk_cnt = "1111" then  -- Sample at end of bit period
                    bit_cnt <= bit_cnt + 1;
                    -- Shift data in LSB first (UART standard)
                    reg_data <= din_sync2 & reg_data(7 downto 1);
                end if; 

                -- Output data when frame is complete
                if bit_cnt = "1000" and clk_cnt = "1111" then
                    DOUT <= reg_data;  -- Output received byte
                end if;     

            end if;
        end if;
    end process main_process;
    
end architecture;
