-- 10-bit serial-in and 8-bit serial-out shift register
-- CLK: in STD_LOGIC;
-- DIN: in STD_LOGIC;
-- DOUT: out STD_LOGIC_VECTOR(7 downto 0);
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register is
  port (
    CLK  : in  std_logic;
    DIN  : in  std_logic;
    EN   : in  std_logic := '0';
    DOUT : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of shift_register is
  signal REG : std_logic_vector(9 downto 0);
begin
  process(CLK)
  begin
    if rising_edge(CLK) then
      REG <= DIN & REG(9 downto 1);
      if EN = '1' then
        DOUT <= REG(9 downto 2);
      end if;
    end if;
  end process;
end rtl;
