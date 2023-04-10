-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Michal Balogh (xbalog06)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

------------------------------------------------------------------------

entity UART_RX_FSM is
    port(
       CLK       : in  std_logic;  
       RST       : in  std_logic;
       DIN_FSM   : in  std_logic;                    -- data in from UART_TX
       NEXT_BIT  : in  std_logic_vector(3 downto 0); -- 1 bit read
       READY     : in  std_logic_vector(2 downto 0); -- wait for the middle of the start bit
       BIT_CNT   : in  std_logic_vector(3 downto 0); -- bit counter
       RST_BIT   : out std_logic := '0';             -- reset bit counter
       RST_CNT   : out std_logic := '0';             -- reset counter (counter counts 16 periods)
       VLD_OUT   : out std_logic                     -- validate output
    );
end entity;

------------------------------------------------------------------------

architecture behavioral of UART_RX_FSM is
type FSM_STATE is (IDLE, START_BIT, DATA, STOP_BIT);
signal state : FSM_STATE := IDLE;
begin
    RST_BIT <= '1' when state = START_BIT else '0';
    process (CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE;
            else
                case state is

                    when IDLE =>
                        VLD_OUT <= '0';
                        if DIN_FSM = '0' then -- start bit
                            state <= START_BIT;
                            RST_CNT <= '1';
                        end if;

                    when START_BIT =>
                        RST_CNT <= '0';
                        if READY = "100" then -- iba 4, nie 8, lebo signal je posunuty resetmi a tak o 4 periody
                            RST_CNT <= '1';
                            state <= DATA;
                        end if;

                    when DATA =>
                    RST_CNT <= '0';
                    if BIT_CNT = "1000" then -- read 8 bits
                        state <= STOP_BIT;
                    end if;

                    when STOP_BIT =>
                        if NEXT_BIT = "1111" then -- wait for one period (16 clocks)
                            if DIN_FSM = '1' then -- stop bit
                                VLD_OUT <= '1';
                                state <= IDLE;
                            end if;
                        end if;
                    when others => null;
                end case;
                
            end if;
        end if;
    end process;
end architecture;
