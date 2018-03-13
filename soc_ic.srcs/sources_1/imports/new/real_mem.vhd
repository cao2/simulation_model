----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/31/2017 11:34:08 AM
-- Design Name: 
-- Module Name: real_mem - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity real_mem is
Port(  Clock      : in  std_logic;
       reset      : in  std_logic;
       rvalid: in std_logic;
       rdaddr_i: in std_logic_vector(31 downto 0);
       r_ack: out std_logic;
       rddata_o: out std_logic_vector(31 downto 0);
       wvalid: in std_logic;
       wtaddr_i: in std_logic_vector(31 downto 0);
       wtdata_i: in std_logic_vector(31 downto 0);
       w_ack: out std_logic
       );
end real_mem;

architecture rtl of real_mem is
     --type rom_type is array (2**32-1 downto 0) of std_logic_vector (31 downto 0);
 type ram_type is array (0 to 2**10-1) of std_logic_vector(31 downto 0);
 
 signal ram : ram_type := (others => (others => '0'));

begin

 process (Clock)
        variable address : integer;
        variable addr : integer;
    begin
   if (rising_edge(Clock)) then
         r_ack<='0';
         w_ack<='0';
          if reset = '1' then
                r_ack<='0';
                w_ack<='0';
            else
            if rvalid = '1' then
                  address    := to_integer(unsigned(rdaddr_i(9 downto 0)));
                  r_ack<='1';
                  rddata_o <= ram(address);
             end if;
            
             if wvalid = '1' then
                  addr    := to_integer(unsigned(wtaddr_i(9 downto 0)));
                  ram(addr) <= wtdata_i;
                  w_ack <='1';
             end if;
         end if;
         end if;
     end process;
 
end architecture rtl;
