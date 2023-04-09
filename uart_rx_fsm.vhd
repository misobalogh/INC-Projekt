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
       DIN_FSM   : in  std_logic;
       NEXT_BIT  : in  std_logic_vector(3 downto 0);
       READY     : in  std_logic_vector(2 downto 0);
       BIT_CNT   : in  std_logic_vector(3 downto 0);
       RST_BIT   : out std_logic := '0';
       RST_CNT   : out std_logic := '0';
       --SHIFT_REG : out std_logic := '0';
       VLD_OUT   : out std_logic
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
                        if DIN_FSM = '0' then
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
                    if BIT_CNT = "1000" then
                        state <= STOP_BIT;
                    end if;

                    when STOP_BIT =>
                        if NEXT_BIT = "1111" then
                            if DIN_FSM = '1' then
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
