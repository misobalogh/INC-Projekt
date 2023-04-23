-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Michal Balogh (xbalog06)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal bit_cnt : std_logic_vector(3 downto 0);
    signal clk_cnt : std_logic_vector(3 downto 0);
    signal rst_cnt  : std_logic := '0';
    signal rst_bit  : std_logic := '0';
    signal REG : std_logic_vector(7 downto 0);
    signal vld_out : std_logic := '0';
    
    -- Synchronous input signal
    signal din_s : std_logic;
    signal din_in : std_logic;
    
    -- Synchronous reset signal
    signal rst_s : std_logic;
    signal rst_in : std_logic;


begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK       => CLK,
        RST       => RST,
        DIN_FSM   => DIN,
        NEXT_BIT  => clk_cnt,
        READY     => clk_cnt(2 downto 0),
        BIT_CNT   => bit_cnt,  
        RST_BIT   => rst_bit,
        RST_CNT   => rst_cnt,
        VLD_OUT   => vld_out
    );

    -- The input signal is asynchronous, metastability must be handled.
    input_synch:process(clk)
    begin
        if rising_edge(CLK) then
            din_s <= DIN;
            din_in <= din_s;
        end if;
    end process;

    -- Synchonization of reset signal
    rst_synch:process(clk)
    begin
        if rising_edge(CLK) then
            rst_s <= RST;
            rst_in <= rst_s;
        end if;
    end process;

    DOUT_VLD <= vld_out;
    process (CLK) 
    begin
        if rising_edge(CLK) then
            if RST = '1' then -- Reset  
                bit_cnt <= (others => '0');
                clk_cnt <= (others => '0');
                REG <= (others => '0'); 
            else
                -- Clock Counter
                if rst_cnt = '1' then
                    clk_cnt <= (others => '0');
                else 
                    clk_cnt <= clk_cnt + 1;
                end if;

                -- Reset bit Counter
                if rst_bit = '1' then   
                    bit_cnt <= (others => '0');
                 -- REG <= REG; 
                elsif clk_cnt = "1111" then -- counter = 16
                    bit_cnt <= bit_cnt + 1; -- +1 bit
                    REG <= din_in & REG(7 downto 1);
                end if; 

                -- Output
                if bit_cnt = "1000" and clk_cnt = "1111" then      -- 8 bits
                    DOUT <= REG(7 downto 0); -- output
                end if;     

            end if;
        end if;
    end process;
end architecture;
