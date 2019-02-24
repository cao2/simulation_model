library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.test.all;
use work.util.all;

entity uart_peripheral is
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
       
       rx_in: in std_logic;
       tx_out:  out std_logic;
       
       -- up req
       upreq_o       : out MSG_T;
       upres_i       : in  MSG_T;
       upreq_full_i  : in  std_logic;

       -- for debugging only:
       done_o        : out std_logic
       );
end uart_peripheral;

architecture rtl of uart_peripheral is
 
  signal poweron   : std_logic := '1';

 
  signal sim_end : std_logic := '0';
  
  
  signal tx_full, rx_empty: std_logic;
  signal rec_data,rec_data1: std_logic_vector(7 downto 0);
  signal rd,wt: std_logic;
  signal rx,tx :std_logic;
begin
    uart_unit: entity work.uart(str_arch) port map(  clk=>Clock, 
                reset=>reset, 
                rd_uart=>rd,
                wr_uart=>wt, 
                rx=>rx, 
                w_data=>rec_data1,
                tx_full=>tx_full, 
                rx_empty=>rx_empty,
                r_data=>rec_data, tx=>tx);
 output_p: process(Clock)
 begin
    if (rising_edge(Clock)) then
        tx_out<=tx;
    end if;
 end process;
 
 
 
  write_req_p : process(Clock)
    variable address : integer;
    variable len     : integer;
    variable size    : std_logic_vector(9 downto 0);
    variable state   : integer := 0;
    variable lp      : integer := 0;
    variable write_data: std_logic_vector(31 downto 0);
  begin
   if (rising_edge(Clock)) then
    	 if reset = '1' then
        wready_o     <= '1';
        wdataready_o <= '0';
        wt <= '0';
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
          
            wdataready_o              <= '0';
            ---strob here is not considered
            write_data := wdata_i(31 downto 0);
            wt<='1';
            if tx_full/='1' then
                rec_data1 <= write_data(7 downto 0);
                state := 4;
            end if;
         end if;
           
    elsif state =4 then
           if tx_full/='1' then
                   rec_data1 <= write_data(15 downto 8);
                   state := 5;
               end if;    
     elsif state =5 then
            if tx_full/='1' then
                   rec_data1 <= write_data(23 downto 16);
                   state := 6;
            end if;
     elsif state =6 then
            if tx_full/='1' then
                   rec_data1 <= write_data(31 downto 24);
                   state := 3;
                   wdataready_o              <= '1';
                   wt<='0';
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
    variable rd_data : std_logic_vector(31 downto 0);
  begin
   if (rising_edge(Clock)) then
       if reset = '1' then
        rready_o  <= '1';
        rdvalid_o <= '0';
        rstrb_o   <= "1111";
        rlast_o   <= '0';
        address := 0;
        rd <='0';
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
            rdvalid_o <= '1';
            rd <='1';
            rd_data :=(others=>'0');
            if rx_empty/='1' then
                rd_data(7 downto 0) := rec_data;
                state :=4;
            end if;
        end if;
      elsif state =4 then
            if rx_empty/='1' then
                rd_data(15 downto 8) := rec_data;
                state :=5;
            end if;                  
      elsif state =5 then
                  if rx_empty/='1' then
                      rd_data(23 downto 16) := rec_data;
                      state :=6;
                  end if;            
      elsif state =6 then
            if rx_empty/='1' then
                 rd_data(31 downto 24) := rec_data;
                 rdata_o   <= rd_data;
                 state :=3;
                 rres_o    <= "00";
                 rlast_o <= '1';
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

  clk_counter : process(clock, sim_end)
    variable count : natural := 0;
    variable b : boolean := true;
  begin
    if sim_end = '1' and b then
      log(str(id_i) & " ended, clock cycles is " & str(count), INFO);
      b := false;
    elsif (rising_edge(clock)) then
      count := count + 1;
    end if;
  end process;
  
 
  done_o <= (not is_tset(UREQ)) or sim_end;
end rtl;
