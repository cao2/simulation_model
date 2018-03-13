library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.util.all;
--use work.rand.all;
use work.test.all;

entity toper_chan_m is
  Port(
    Clock : in  std_logic;
    reset : in  std_logic;

    ---read address channel
    raddr_o      : out  std_logic_vector(31 downto 0);
    rlen_o       : out  std_logic_vector(9 downto 0);
    rsize_o      : out  std_logic_vector(9 downto 0);
    rvalid_o     : out  std_logic;
    rready_i     : in std_logic;
    ---read data channel
    rdata_i       : in std_logic_vector(31 downto 0);
    rstrb_i       : in std_logic_vector(3 downto 0);
    rlast_i       : in std_logic;
    rdvalid_i     : in std_logic;
    rdready_o     : out  std_logic;
    rres_i        : in std_logic_vector(1 downto 0);

    bus_res_c0_ack_i : in std_logic;
    bus_res_c1_ack_i : in std_logic;
    
    toper_i : in MSG_T;
    bus_res_c0_o : out BMSG_T;
    bus_res_c1_o : out BMSG_T;

    gfx_upres_ack_i : in std_logic;
    usb_upres_ack_i : in std_logic;
    uart_upres_ack_i : in std_logic;
    audio_upres_ack_i : in std_logic;
    
    gfx_upres_o : out MSG_T;
    usb_upres_o : out MSG_T;
    uart_upres_o : out MSG_T;
    audio_upres_o : out MSG_T;

    per_write_o : out MSG_T;
    per_write_ack_i : in std_logic;
    per_ack_o : out std_logic
    
	);
end toper_chan_m;

architecture rtl of toper_chan_m is
begin
 toper_chan_p : process( Clock)
    variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
    variable sdata   : std_logic_vector(31 downto 0)  := (others => '0');
    variable st   : integer                        := 20; -- TODO hack?
    variable lp      : integer                        := 0;
    variable tep_gfx1 : MSG_T;
    variable nullreq : BMSG_T := ZERO_BMSG;
    variable nullreq1 : BMSG_T := ZERO_BMSG;
    variable slot : integer :=0;
    variable prev_st, prev_togfx_p : integer := -1;
  begin
   if rising_edge(Clock) then
      --dbg_chg("togfx_chan_p", st, prev_st);
       if reset = '1' then
           rvalid_o  <= '0';
           rdready_o <= '0';
         elsif st =0 then
        --per_ack_o <='1';
        st :=20;
      elsif st = 20 then -- start
        per_ack_o <='0';
        bus_res_c0_o   <= nullreq;
        bus_res_c1_o   <= nullreq1;
        gfx_upres_o  <= ZERO_MSG;
        uart_upres_o  <= ZERO_MSG;
        audio_upres_o <= ZERO_MSG;
        usb_upres_o   <= ZERO_MSG;
        if (toper_i.val = '1' and
          (toper_i.cmd = READ_CMD or toper_i.tag=CPU0_TAG or toper_i.tag=CPU1_TAG) ) then
          tep_gfx1 := toper_i;
          st   := 6;
        elsif (toper_i.val = '1' and
               toper_i.cmd = WRITE_CMD) then
          per_write_o<=toper_i;
          st   := 9;
        end if;
      elsif st = 6 then -- process read cmd to gfx
        if rready_i = '1' then
          ---per_ack_o <= '0';
          rvalid_o <= '1';
          raddr_o  <= tep_gfx1.adr;
          slot := to_integer(unsigned(tep_gfx1.adr(3 downto 0)));
          if (tep_gfx1.tag = CPU0_TAG or
              tep_gfx1.tag = CPU1_TAG) then
            rlen_o <= "00000" & "10000";
          else
            rlen_o <= "00000" & "00001";
          end if;
          rsize_o <= "00001" & "00000";
          st     := 1;
        end if;
      elsif st = 1 then -- done sending data, get resp
        rvalid_o  <= '0';
        rdready_o <= '1';
        st       := 2;
      elsif st = 2 then
        if rdvalid_i = '1' and rres_i = "00" then
          if (tep_gfx1.tag = CPU0_TAG or
              tep_gfx1.tag = CPU1_TAG) then
            if lp=slot and tep_gfx1.cmd = WRITE_CMD then
              tdata(lp * 32 + 31 downto lp * 32) := tep_gfx1.dat;
            else
              tdata(lp * 32 + 31 downto lp * 32) := rdata_i;
            end if;
            rdready_o                        <= '0';
            lp                                 := lp + 1;
            if rlast_i = '1' then
              st := 3;
              lp    := 0;
            end if;
            rdready_o <= '1';
          else
            rdready_o <= '1';
            sdata       := rdata_i;
            st :=3;
          end if;

        end if;
      elsif st = 3 then -- forward read response from device
        --per_ack_o <= '1';
        if tep_gfx1.tag = CPU0_TAG then
          bus_res_c0_o <= (tep_gfx1.val, tep_gfx1.cmd, tep_gfx1.tag,
                               tep_gfx1.id, tep_gfx1.adr, tdata);
          st      := 4;
        elsif tep_gfx1.tag = CPU1_TAG then
          bus_res_c1_o <= (tep_gfx1.val, tep_gfx1.cmd, tep_gfx1.tag,
                         tep_gfx1.id, tep_gfx1.adr, tdata);
          st      := 4;
        --elsif tep_gfx(75 downto 73)="001" then
        --gfx_upres2 <= tep_gfx(72 downto 32) & sdata;
        --st := 5;
        elsif tep_gfx1.tag = GFX_TAG then
          gfx_upres_o <= (tep_gfx1.val, tep_gfx1.cmd, tep_gfx1.tag,
                          tep_gfx1.id, tep_gfx1.adr, sdata);
          st := 5;
        elsif tep_gfx1.tag = UART_TAG then
          uart_upres_o <= (tep_gfx1.val, tep_gfx1.cmd, tep_gfx1.tag,
                          tep_gfx1.id, tep_gfx1.adr, sdata);
          st := 6;
        elsif tep_gfx1.tag = USB_TAG then
          usb_upres_o <= (tep_gfx1.val, tep_gfx1.cmd, tep_gfx1.tag,
                          tep_gfx1.id, tep_gfx1.adr, sdata);
          st := 7;
        elsif tep_gfx1.tag = AUDIO_TAG then
          audio_upres_o <= (tep_gfx1.val, tep_gfx1.cmd, tep_gfx1.tag,
                          tep_gfx1.id, tep_gfx1.adr, sdata);
          st := 8;
        end if;

      elsif st = 4 then -- wait for ack from bus_resX_arbitor
        if bus_res_c1_ack_i = '1' then
          bus_res_c1_o <= nullreq;
          st      := 0;
        elsif bus_res_c0_ack_i = '1' then
          bus_res_c0_o <= nullreq;
          st      := 0;
        end if;
      elsif st = 5 then
        if gfx_upres_ack_i = '1' then
          gfx_upres_o <= ZERO_MSG;
          st       := 0;
        end if;        
      elsif st = 6 then
        if uart_upres_ack_i = '1' then
          uart_upres_o <= ZERO_MSG;
          st       := 0;
        end if;
      elsif st = 7 then
        if usb_upres_ack_i = '1' then
          usb_upres_o <= ZERO_MSG;
          st      := 0;
        end if;
      elsif st = 8 then
        if audio_upres_ack_i = '1' then
          audio_upres_o <= ZERO_MSG;
          st        := 0;
        end if;
      elsif st = 9 then
        if per_write_ack_i = '1' then
          per_ack_o <='1';
          --bus_res_c0_o <= (per_write_o.val, per_write_o.cmd, per_write_o.tag,
          --                      per_write_o.id, per_write_o.adr, tdata); -- TODO check if tdata has
          --                                         -- correct value
          per_write_o <= ZERO_MSG;
          st := 4;
        end if;
      end if;
    end if;
  end process;
  
end rtl;
