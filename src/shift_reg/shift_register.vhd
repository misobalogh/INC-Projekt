-- shift_register.vhd: Generic Shift Register Component
--
-- Description:
--   10-bit serial-in, 8-bit parallel-out shift register
--   Useful for UART data reception and other serial protocols
--
-- Features:
--   - Serial data input with clock enable
--   - Parallel data output (8 bits from 10-bit internal register)
--   - Enable signal for output control
--
-- Usage:
--   - Connect DIN to serial data stream
--   - Assert EN to capture parallel output
--   - DOUT provides the middle 8 bits of the shift register
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register is
  port (
    CLK  : in  std_logic;                    -- System clock
    DIN  : in  std_logic;                    -- Serial data input
    EN   : in  std_logic := '0';             -- Enable signal for output capture
    DOUT : out std_logic_vector(7 downto 0)  -- Parallel data output
  );
end entity;

architecture rtl of shift_register is
  -- 10-bit internal shift register
  signal reg_internal : std_logic_vector(9 downto 0);
begin

  -- Shift register process
  shift_process: process(CLK)
  begin
    if rising_edge(CLK) then
      -- Shift data: new bit enters from left, oldest bit exits from right
      reg_internal <= DIN & reg_internal(9 downto 1);

      -- Output middle 8 bits when enabled
      if EN = '1' then
        DOUT <= reg_internal(9 downto 2);
      end if;
    end if;
  end process shift_process;

end rtl;
