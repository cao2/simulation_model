library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.util.all;
--use work.rand.all;
use work.test.all;

entity wb_m is
  Port(
    clock : in  std_logic;
    reset : in  std_logic;

    fifo_empty_i : in std_logic;
    
    wb_o : in BMSG_T;
    mem_write_o : out BMSG_T;
    gfx_write_o : out BMSG_T;
    uart_write_o : out BMSG_T;
    usb_write_o : out BMSG_T;
    audio_write_o : out BMSG_T;

    mem_write_ack_i : in std_logic;
    gfx_write_ack_i : in std_logic;
    uart_write_ack_i : in std_logic;
    usb_write_ack_i : in std_logic;
    audio_write_ack_i : in std_logic;

    wready_gfx_i : in std_logic;
    wready_uart_i : in std_logic;
    wready_usb_i : in std_logic;
    wready_audio_i : in std_logic;
    
    re_io : inout std_logic
    
	);
end wb_m;

architecture rtl of wb_m is
  --signal tmp_cache_req1, tmp_cache_req2: MSG_T;

begin
  ----write_back process
  ----this need to be edited, 
  ----1. axi protocl
  ----2. more than 2 ips
  wb_p : process( Clock)
    variable state : integer;
    variable tdata:std_logic_vector(511 downto 0);
    variable lp:integer :=0;
  begin
   if rising_edge(Clock) then
       if reset = '1' then
        state   := 0;
      elsif state = 0 then
        if re_io = '0' and fifo_empty_i = '0' then
          re_io   <= '1';
          state := 1;
        end if;
      elsif state = 1 then
        re_io <= '0';
        if wb_o.val = '1' then
          if wb_o.adr(31 downto 31) = "1" then -- to mem
            mem_write_o <= wb_o;
          elsif (wb_o.adr(30 downto 29) = "00" and
                 wready_gfx_i = '0') then
            gfx_write_o <= wb_o;
            state      := 3;
          elsif (wb_o.adr(30 downto 29) = "01" and
                 wready_uart_i = '0') then
            uart_write_o <= wb_o;
            state       := 4;
          elsif (wb_o.adr(30 downto 29) = "10" and
                 wready_usb_i = '0') then
            usb_write_o <= wb_o;
            state      := 5;
          elsif (wb_o.adr(30 downto 29) = "11" and
                 wready_audio_i = '0') then
            audio_write_o <= wb_o;
            state        := 6;
          end if;
        end if;
      elsif state = 1 then
        if mem_write_ack_i='1' then
          clr(mem_write_o);
          state :=0;
        end if;

      elsif state = 3 then
        if gfx_write_ack_i='1' then
          clr(gfx_write_o);
          state :=0;
        end if;
      elsif state = 4 then
        if uart_write_ack_i='1' then
          clr(uart_write_o);
          state :=0;
        end if;
      elsif state = 5 then
        if usb_write_ack_i='1' then
          clr(usb_write_o);
          state :=0;
        end if;
      elsif state = 6 then
        if audio_write_ack_i='1' then
          clr(audio_write_o);
          state :=0;
        end if;
      end if;

    end if;
  end process;
  
end rtl;
