library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.test.all;
use work.util.all;

entity peripheral is
  Port(Clock      : in  std_logic;
       reset      : in  std_logic;

       id_i       : in IP_T;
       
       ---write address channel
       waddr_i      : in  ADR_T;
       wlen_i       : in  std_logic_vector(9 downto 0);
       wsize_i      : in  std_logic_vector(9 downto 0);
       wvalid_i     : in  std_logic;
       wready_o     : out std_logic;
       ---write data channel
       wdata_i      : in  std_logic_vector(31 downto 0);
       wtrb_i       : in  std_logic_vector(3 downto 0);  --TODO not implemented
       wlast_i      : in  std_logic;
       wdvalid_i    : in  std_logic;
       wdataready_o : out std_logic;
       ---write response channel
       wrready_i    : in  std_logic;
       wrvalid_o    : out std_logic;
       wrsp_o       : out std_logic_vector(1 downto 0);

       ---read address channel
       raddr_i      : in  std_logic_vector(31 downto 0);
       rlen_i       : in  std_logic_vector(9 downto 0);
       rsize_i      : in  std_logic_vector(9 downto 0);
       rvalid_i     : in  std_logic;
       rready_o     : out std_logic;
       ---read data channel
       rdata_o       : out std_logic_vector(31 downto 0);
       rstrb_o       : out std_logic_vector(3 downto 0);
       rlast_o       : out std_logic;
       rdvalid_o     : out std_logic;
       rdready_i     : in  std_logic;
       rres_o        : out std_logic_vector(1 downto 0);
       pwr_req_i     : in  MSG_T;
       pwr_res_o     : out MSG_T;
       
       -- up req
       upreq_o       : out MSG_T;
       upres_i       : in  MSG_T;
       upreq_full_i  : in  std_logic;

       -- for debugging only:
       done_o        : out std_logic
       );
end peripheral;

architecture rtl of peripheral is
  type ram_type is array (0 to 15) of ADR_T;
  signal ROM_array : ram_type  := (others => (others => '0'));
  signal poweron   : std_logic := '1';

  signal emp3, emp2 : std_logic := '0';
  signal tmp_req : std_logic_vector(50 downto 0);

  signal sim_end : std_logic := '0';
  signal tag: IPTAG_T:= ZERO_TAG;
  signal r: std_logic_vector(31 downto 0);
  constant overall_delay: positive := 20;
begin

-- rndgen_ent : entity work.rndgen(rtl) port map (
--     clk    => Clock,
--     rst    => reset,
--     en     => '1',
--     seed_i => nat(id_i),
--     rnd_o  => r
--     );

set_tag: process(Clock)
	begin
		if rising_edge(Clock) then
			if id_i = GFX then
      			tag <= GFX_TAG;
     		elsif id_i=AUDIO then
     			tag <= AUDIO_TAG;
     		elsif id_i=USB then
     			tag <= USB_TAG;
     		elsif id_i=UART then
     			tag <= UART_TAG;
     		end if;
		end if;
	end process;
 
  write_req_p : process(Clock)
    variable address : integer;
    variable len     : integer;
    variable size    : std_logic_vector(9 downto 0);
    variable state   : integer := 0;
    variable lp      : integer := 0;
  begin
   if (rising_edge(Clock)) then
    	 if reset = '1' then
        wready_o     <= '1';
        wdataready_o <= '0';
      elsif state = 0 then
    		wready_o <='1';
    		wdataready_o <='0';
        wrvalid_o <= '0';
        wrsp_o    <= "10";
        if wvalid_i = '1' then
          wready_o     <= '0';
          address    := to_integer(unsigned(waddr_i(31 downto 29)));
          len        := to_integer(unsigned(wlen_i));
          size       := wsize_i;
          state      := 2;
          wdataready_o <= '1';
        end if;

      elsif state = 2 then
        if wdvalid_i = '1' then
          ---not sure if lengh or length -1
          if lp < len - 1 then
            wdataready_o              <= '0';
            ---strob here is not considered
            ROM_array(address + lp) <= wdata_i(31 downto 0);
            lp                      := lp + 1;
            wdataready_o              <= '1';
            if wlast_i = '1' then
              state := 3;
            end if;
          else
            state := 3;
          end if;

        end if;
      elsif state = 3 then
        if wrready_i = '1' then
          wrvalid_o <= '1';
          wrsp_o    <= "00";
          state   := 0;
        end if;
      end if;
    end if;
  end process;
--
  read_req_p : process(Clock)
    variable address : integer;
    variable len     : integer;
    variable size    : std_logic_vector(9 downto 0);
    variable state   : integer := 0;
    variable lp      : integer := 0;
    variable dt      : std_logic_vector(31 downto 0);
  begin
    if (rising_edge(Clock)) then
      if reset = '1' then
          rready_o  <= '1';
          rdvalid_o <= '0';
          rstrb_o   <= "1111";
          rlast_o   <= '0';
          address := 0;
        elsif state = 0 then
        lp := 0;
        if rvalid_i = '1' then
          rready_o  <= '0';
          address := to_integer(unsigned(raddr_i(31 downto 29)));
          len     := to_integer(unsigned(rlen_i));
          size    := rsize_i;
          state   := 2;
        end if;

      elsif state = 2 then
        if rdready_i = '1' then
          if lp < 16 then
            rdvalid_o <= '1';
            rdata_o   <= ROM_array(address);
            lp      := lp + 1;
            rres_o    <= "00";
            if lp = len then
              state := 3;
              rlast_o <= '1';
            end if;
          else
            state := 3;
          end if;

        end if;
      elsif state = 3 then
        rdvalid_o <= '0';
        rready_o  <= '1';
        rlast_o   <= '0';
        state   := 0;
      end if;
    end if;
  end process;

  pwr_req_p : process(Clock)
    variable pwr_req : MSG_T;
  begin
    if (rising_edge(clock)) then
     pwr_res_o <= ZERO_MSG;
      pwr_res_o <= pwr_req;
      pwr_req := pwr_req_i;
      if pwr_req.cmd = PWRUP_CMD then
      	poweron <= '1';
      	report "pheriphal power on";
      elsif pwr_req.cmd = PWRDN_CMD then
      	poweron <= '0';
      	report "pheriphal power off";
      else
        pwr_req := ZERO_MSG;
      end if;
    end if;
  end process;

  clk_counter : process(clock)
    variable count : natural := 0;
    variable b : boolean := true;
  begin
    if (rising_edge(clock)) then
      count := count + 1;
    end if;
  end process;
  
  ureqt_p : process(clock) -- up read test
    variable dc, tc, st_nxt : natural := 0;
    variable s : natural := nat(id_i)+overall_delay;
    variable st : natural := 0;
    variable b : boolean := true;
    variable t_adr : ADR_T;
    variable tcmd : CMD_T;
    variable offset : ADR_T;
    variable seqid : integer := -1;
    variable c_delay: natural:=overall_delay;
    --HACKS
    variable c1 : integer := 900;
    variable c2 : integer := 400;
    variable c3 : integer := 800;
    variable c4 : integer := 600;
    
  begin
      if(rising_edge(clock)) then
        if reset = '1' then
              upreq_o <= ZERO_MSG;
              --ct := rand_nat(to_integer(unsigned(TEST(UREQ))));
              st := 0;
       elsif st = 1 then -- delay
              report "state is "& integer'image(st);
              report "delay cycle "& integer'image(c_delay);
         delay(c_delay, st, st_nxt);
        elsif st = 2 then -- done
          upreq_o <= ZERO_MSG;
          sim_end <= '1';
        elsif st = 0 then -- check
          if is_tset(TEST(UREQ)) and
            ((UREQT_SRC and ip_enc(id_i)) /= ip_enc(NONE)) then
            if tc < UREQT_CNT then
              log("sending req from " & str(id_i), DEBUG);
              tc := tc + 1;
             --- st_nxt := 3;
              st := 3;
            else
              st := 2;
            end if;
          end if;
        elsif st = 3 then -- snd
          -- report integer'image(to_integer(unsigned(devid_i))) & " snd ureq";
          -- rmz adr
         
          -- set sequence id
          
          if upreq_full_i/='1' then
             s := s + nat(id_i);
                   --t_adr := std_logic_vector(to_unsigned(rand_nat(s), t_adr'length));
                   --t_adr := rnd_adr(s);
         
                   -- HACK 1 : force devices to request different addresses
                   if id_i = GFX then
                     t_adr := std_logic_vector(to_unsigned(c1, t_adr'length));
                     c1 := c1 + 1;
                     --t_adr := t_adr and X"000000FF";
                   elsif id_i = USB then
                     t_adr := std_logic_vector(to_unsigned(c2, t_adr'length));
                     c2 := c2 + 1;
                     --t_adr := t_adr and X"0000FF00";
                   elsif id_i = UART then
                     t_adr := std_logic_vector(to_unsigned(c3, t_adr'length));
                     c3 := c3 + 1;
                     --t_adr := t_adr and X"00FF0000";
                   elsif id_i = AUDIO then
                     t_adr := std_logic_vector(to_unsigned(c4, t_adr'length));
                     c4 := c4 + 1;
                     --t_adr := t_adr and X"FF000000";
                   end if;
                   
                     
                   t_adr := t_adr or X"80000000"; -- HACK 2 to make it go to memory
                            
                   -- rmz cmd
                   if (id_i = USB) or
                     (id_i = UART) or
                     (to_integer(unsigned(r)) mod 2) = 1 then
                     tcmd := READ_CMD;
                   else
                     tcmd := WRITE_CMD;
                   end if;

          seqid := seqid + 1;
          upreq_o <= ('1', tcmd, tag, std_logic_vector(to_unsigned(seqid, 8)),
                      t_adr, ZERO_DAT);
          --report "<<<<<<<up request tag is "& integer'image(to_integer(unsigned(tag)));
          st := 4;
          end if;
        elsif st = 4 then
          upreq_o <= ZERO_MSG;
          -- do not wait for response
         --- if upres_i.val='1' then
            st_nxt := 0;
            st := 1; -- delay next check
            c_delay := nat(id_i)-1;
          ---end if;
        end if;
      end if;
  end process;  

  done_o <= (not is_tset(UREQ)) or sim_end;
end rtl;
