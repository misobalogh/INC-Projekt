library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register_tb is
end entity;

architecture tb_arch of shift_register_tb is
  component shift_register is
    port (
      CLK : in std_logic;
      DIN : in std_logic;
      EN : in std_logic;
      DOUT : out std_logic_vector(7 downto 0)
    );
  end component;
  
  signal CLK : std_logic := '0';
  signal DIN : std_logic := '0';
  signal EN : std_logic := '0';
  signal DOUT : std_logic_vector(7 downto 0);
  
  constant clk_period : time := 10 ns; 
  
begin

  uut : shift_register
    port map (
      CLK => CLK,
      DIN => DIN,
      EN => EN,
      DOUT => DOUT
    );

  clk_process : process
  begin
    while now < 1000 ns loop 
      CLK <= not CLK;
      wait for clk_period / 2;
    end loop;
    wait;
  end process;

  din_process : process
  begin
    DIN <= '0'; -- start bit

    wait for clk_period;
    DIN <= '1';
    wait for clk_period;
    DIN <= '0';
    wait for clk_period;
    DIN <= '0';
    wait for clk_period;
    DIN <= '1';

    wait for clk_period;
    DIN <= '0';
    wait for clk_period;
    DIN <= '1';
    wait for clk_period;
    DIN <= '1';
    wait for clk_period;
    DIN <= '0';

    wait for clk_period;
    DIN <= '1'; -- stop bit
    EN <= '1'; -- write to output

    wait for clk_period;
    DIN <= '1'; -- isnt start bit
    EN <= '0';
    

    wait for clk_period;
    DIN <= '0'; -- start bit
    

    wait for clk_period;
    DIN <= '0';
    wait for clk_period;
    DIN <= '1';
    wait for clk_period;
    DIN <= '1';
    wait for clk_period;
    DIN <= '0';

    wait for clk_period;
    DIN <= '1';
    wait for clk_period;
    DIN <= '0';
    wait for clk_period;
    DIN <= '1';
    wait for clk_period;
    DIN <= '1';
    EN <= '1'; -- write to output
   
    wait for clk_period;
    DIN <= '1'; -- stop bit
    

    wait for clk_period;
    DIN <= '1';
    EN <= '0';

    wait for clk_period;
    DIN <= '1';

    wait;


  end process;

  stim_process : process
  begin
    wait for clk_period * 15; -- wait for 15 clock cycles
    wait for clk_period;
    assert DOUT = std_logic_vector(to_unsigned(16#69#, DOUT'length)) report "Error: DOUT expected to be 0x88" severity failure;
    wait;
    wait for clk_period * 15; -- wait for 15 clock cycles
    wait for clk_period;
    assert DOUT = std_logic_vector(to_unsigned(16#CB#, DOUT'length)) report "Error: DOUT expected to be 0x88" severity failure;
    wait;
  end process;

end tb_arch;
