-- uart_rx_fsm.vhd: UART Receiver Finite State Machine
-- 
-- Description:
--   Finite state machine controlling the UART RX protocol
--   Handles frame detection, bit timing, and validation
--
-- States:
--   IDLE     - Waiting for start bit
--   START_BIT - Validating start bit
--   DATA     - Receiving 8 data bits
--   STOP_BIT - Validating stop bit
--
-- Author(s): Michal Balogh (xbalog06)
-- Date: 2025
-- Project: INC-Projekt (Digital Design Course)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

------------------------------------------------------------------------

entity UART_RX_FSM is
    port(
       CLK       : in  std_logic;                    -- System clock (16x baud rate)
       RST       : in  std_logic;                    -- Asynchronous reset
       DIN_FSM   : in  std_logic;                    -- Serial data input from UART TX
       NEXT_BIT  : in  std_logic_vector(3 downto 0); -- Clock counter (0-15)
       READY     : in  std_logic_vector(2 downto 0); -- Ready signal for start bit detection
       BIT_CNT   : in  std_logic_vector(3 downto 0); -- Bit counter (0-8)
       RST_BIT   : out std_logic := '0';             -- Reset bit counter signal
       RST_CNT   : out std_logic := '0';             -- Reset clock counter signal
       VLD_OUT   : out std_logic                     -- Output data valid signal
    );
end entity;

------------------------------------------------------------------------

architecture behavioral of UART_RX_FSM is
    -- FSM state definition
    type FSM_STATE is (IDLE, START_BIT, DATA, STOP_BIT);
    signal state : FSM_STATE := IDLE;
begin
    -- Reset bit counter during START_BIT state
    RST_BIT <= '1' when state = START_BIT else '0';
    
    -- Main FSM process
    fsm_process: process (CLK) 
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE;
                VLD_OUT <= '0';
                RST_CNT <= '0';
            else
                case state is

                    when IDLE =>
                        VLD_OUT <= '0';
                        RST_CNT <= '0';
                        -- Detect start bit (falling edge)
                        if DIN_FSM = '0' then 
                            state <= START_BIT;
                            RST_CNT <= '1';  -- Start timing
                        end if;

                    when START_BIT =>
                        -- Wait for middle of start bit and validate
                        if READY = "100" then  -- Middle of bit period
                            if DIN_FSM = '0' then  -- Valid start bit
                                RST_CNT <= '1';     -- Reset for data bits
                                state <= DATA;
                            else                    -- Invalid start bit (noise)
                                state <= IDLE;
                                RST_CNT <= '0';
                            end if;
                        else
                            RST_CNT <= '0';
                        end if;

                    when DATA =>
                        RST_CNT <= '0';
                        -- Receive 8 data bits
                        if BIT_CNT = "1000" then  -- 8 bits received
                            state <= STOP_BIT;
                        end if;

                    when STOP_BIT =>
                        -- Wait for stop bit and validate
                        if NEXT_BIT = "1111" then  -- End of bit period
                            if DIN_FSM = '1' then  -- Valid stop bit
                                VLD_OUT <= '1';    -- Signal valid data
                                state <= IDLE;
                            else                   -- Invalid stop bit
                                state <= IDLE;     -- Discard frame
                            end if;
                        end if;
                        
                    when others => 
                        state <= IDLE;  -- Safe fallback
                        
                end case;
            end if;
        end if;
    end process fsm_process;
    
end architecture;
