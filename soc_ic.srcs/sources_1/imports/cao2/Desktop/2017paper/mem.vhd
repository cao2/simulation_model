library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.util.all;
use work.test.all;

entity memory is
  Port(Clock      : in  std_logic;
       reset      : in  std_logic;
       ---write address chanel
       waddr_i      : in  std_logic_vector(31 downto 0);
       wlen_i       : in  std_logic_vector(9 downto 0);
       wsize_i      : in  std_logic_vector(9 downto 0);
       wvalid_i     : in  std_logic;
       wready_o     : out std_logic;
       ---write data channel
       wdata_i      : in  std_logic_vector(31 downto 0);
       wtrb_i       : in  std_logic_vector(3 downto 0);
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
       rvalid_i  : in  std_logic;
       rready_o     : out std_logic;
       ---read data channel
       rdata_o      : out std_logic_vector(31 downto 0);
       rstrb_o      : out std_logic_vector(3 downto 0);
       rlast_o      : out std_logic;
       rdvalid_o    : out std_logic; -- sig from mem to ic meaning "here comes
       -- the data"
       rdready_i    : in  std_logic; -- sig from ic to mem meaning "done"
       -- sending data
       rres_o   : out std_logic_vector(1 downto 0)
       );
end Memory;

architecture rtl of Memory is
 
  signal r,w : std_logic := '0';
  signal rv, wv,r_ack,w_ack: std_logic;
  signal radx, wadx, rda, wda: std_logic_vector(31 downto 0);
begin
 mem_ent : entity work.real_mem(rtl) port map(
    Clock       => Clock,
    reset       => reset,
    rvalid => rv,
    rdaddr_i => radx,
          r_ack => r_ack,
          rddata_o => rda,
          wvalid => wv,
          wtaddr_i => wadx,
          wtdata_i => wda,
          w_ack=>w_ack
    );
  write : process(Clock)
    variable slot       : integer;
    variable address    : integer;
    variable len        : integer;
    variable size       : std_logic_vector(9 downto 0);
    variable st, st_nxt : natural := 0;
    variable cnt        : natural;
    variable lp         : integer := 0;
  begin
   if (rising_edge(Clock)) then
    	 if reset = '1' then
        wready_o     <= '1';
        wdataready_o <= '0';
      elsif st = 0 then
    		wready_o <='1';
        wrvalid_o <= '0';
        wrsp_o    <= "10";
        if wvalid_i = '1' then
          wready_o     <= '0';
          slot       := to_integer(unsigned(waddr_i(26 downto 15)));
          address    := to_integer(unsigned(waddr_i(15 downto 0)));
          len        := to_integer(unsigned(wlen_i));
          size       := wsize_i;
          wdataready_o <= '1';
          st      := 2;
        end if;

      elsif st = 2 then
        if wdvalid_i = '1' then
          
           if lp < len - 1 then
             wdataready_o <= '0';
          ---strob here is not considered
            wv<='1';
             wadx<=waddr_i;
            wda<=wdata_i;
            st := 6;
            else
                st := 3;
            end if;
         end if;
      elsif st=6 then
          wv <='0';
          if w_ack ='1' then
            lp := lp + 1;
            wdataready_o <= '1';
            if wlast_i = '1' then
                st := 3;
            else 
                st := 2;
            end if;
          end if;
        
      elsif st = 3 then
  --      w <= '0';
        if wrready_i = '1' then
          wrvalid_o <= '1';
          wrsp_o    <= "00";
          st   := 0;
        end if;

      end if;
    end if;
  end process;

  read : process(Clock, reset)
    variable slot    : integer;
    variable address : std_logic_vector(31 downto 0);
    variable len     : integer;
    variable size    : std_logic_vector(9 downto 0);
    variable st, st_nxt   : natural := 0;
    variable lp      : integer := 0;
    variable dt      : std_logic_vector(31 downto 0);
    variable cnt     : natural;
    variable data : std_logic_vector(31 downto 0);
  begin
    if reset = '1' then
      rready_o  <= '1';
      rdvalid_o <= '0';
      rstrb_o   <= "1111";
      rlast_o   <= '0';
    elsif (rising_edge(Clock)) then
      if st = 0 then
        lp := 0;
        if rvalid_i = '1' then
          rready_o  <= '0';
          address := raddr_i;
          len     := to_integer(unsigned(rlen_i));
          size    := rsize_i;
          st   := 2;
        end if;

      elsif st = 2 then
        rdvalid_o <= '0';
        if rdready_i = '1' then
          if lp < 16 then
            
            rv<='1';
            radx<=address;
            st := 6;
          else
            st := 3;
          end if;
      end if;
     elsif st=6 then 
--            rdata_o   <= ROM_array(slot)(address + lp);
            if r_ack ='1' then
                rdvalid_o <= '1';
                rdata_o <= rda;
                lp      := lp + 1;
                rres_o <= "00";
                if lp = len then
                    st := 3;
                    rlast_o <= '1';
                else
                    st := 2;
                end if;
          end if;

      elsif st = 3 then
--        r <= '0';
        rdvalid_o <= '0';
        rready_o  <= '1';
        rlast_o   <= '0';
        st   := 0;
    end if;
   end if;
  end process;

end rtl;
