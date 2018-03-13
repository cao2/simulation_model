library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;
use work.util.all;

entity pwr is
  Port (  Clock: in std_logic;
          reset: in std_logic;
          
          req_i   : in MSG_T;
          res_o  : out MSG_T;
          full_preq: out std_logic:='0';
          
          gfx_res_i  : in MSG_T;
          gfx_req_o : out MSG_T;

          uart_res_i : in MSG_T;
          uart_req_o : out MSG_T;
          
          usb_res_i : in MSG_T;
          usb_req_o : out MSG_T;

          audio_res_i : in MSG_T;
          audio_req_o : out MSG_T
          );            
end pwr;

architecture rtl of pwr is
  signal in1,out1 : MSG_T;
  signal in2,out2 : MSG_T := ZERO_MSG;
  signal we1,re1,emp1,we2,re2,emp2 : std_logic:='0';
  signal test: MSG_T;
begin

  pwr_req_fifo: entity work.fifo(rtl) 
	generic map(
      FIFO_DEPTH => 16
     )
	port map(
      CLK=>Clock,
      RST=>reset,
      DataIn=>in1,
      WriteEn=>we1,
      ReadEn=>re1,
      DataOut=>out1,
      Full=>full_preq,
      Empty=>emp1
      );
  
  pwr_req_fifo_p: process (Clock)      
  begin
    if rising_edge(Clock) then
         we1 <='0';
      if req_i.val = '1' then
        in1 <= req_i;
        we1 <= '1';
      else
        we1 <= '0';
      end if;
    end if;
  end process;

  --* Forwards req from ic to dev,
  --*    waits for resp from dev, and
  --*    forwards res back to ic
  req_p : process ( Clock)
    variable st: integer :=0;
    variable dev : IPTAG_T;
    variable tmp_req, tmp: MSG_T;
  begin
    if rising_edge(clock) then
  	test <= tmp;
      res_o <= ZERO_MSG;
      if (reset = '1') then
            gfx_req_o <= ZERO_MSG;
            audio_req_o <= ZERO_MSG;
            usb_req_o <= ZERO_MSG;
            uart_req_o <= ZERO_MSG;
        elsif st =0 then
        gfx_req_o <= ZERO_MSG;
        audio_req_o <= ZERO_MSG;
        usb_req_o <= ZERO_MSG;
        uart_req_o <= ZERO_MSG;
        if re1 = '0' and emp1 ='0' then
          re1 <= '1';
          st := 1;
        end if;
        
      elsif st = 1 then -- wait output (out1) from fifo
        re1 <= '0';
        if out1.val = '1' then
          tmp := out1;
          if out1.dat = pad32(GFX_TAG) then
            --report "ready to send gfx req";
            dev := GFX_TAG;
          elsif out1.dat = pad32(AUDIO_TAG) then
            dev := AUDIO_TAG;
          elsif out1.dat = pad32(USB_TAG) then
            dev := USB_TAG;
          elsif out1.dat = pad32(UART_TAG) then
          	dev := UART_TAG;
          else
          	report "device id unkonwn 1";
          	
          end if;
          st := 2;
        end if;
      elsif st = 2 then -- output
        if dev = GFX_TAG then
          --report "output gfx req";
          gfx_req_o <= tmp;
        elsif dev = AUDIO_TAG then
          audio_req_o <= tmp;
        elsif dev = USB_TAG then
          usb_req_o <= tmp;
        elsif dev = UART_TAG then
          uart_req_o <= tmp;
        else
          report "device id unkonwn 2";
        end if;
        st := 3;
      elsif st = 3 then
        if dev = GFX_TAG then
          tmp := gfx_res_i;
          gfx_req_o <= ZERO_MSG;
        elsif dev = AUDIO_TAG then
          tmp := audio_res_i;
          audio_req_o <= ZERO_MSG;
        elsif dev = USB_TAG then
          tmp := usb_res_i;
          usb_req_o <= ZERO_MSG;
        elsif dev = UART_TAG then
          tmp := uart_res_i;
          uart_req_o <= ZERO_MSG;
        end if;
        
        if tmp.val = '1' then
          res_o <= tmp;
          st :=0;
        end if;
      end if;
    end if;
  end process;
  
end rtl;
