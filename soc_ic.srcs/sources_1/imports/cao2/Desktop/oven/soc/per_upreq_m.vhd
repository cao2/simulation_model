library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.util.all;
--use work.rand.all;
use work.test.all;

entity per_upreq_m is
  Port(
    clock : in  std_logic;
    reset : in  std_logic;

    tag_i : IPTAG_T;

    fifo_re_io : inout std_logic;
    fifo_empty_i : in std_logic;
    fifo_dat_i : in MSG_T;
    req_o : out MSG_T;
    req_ack_i : in std_logic
	);

end per_upreq_m;

architecture rtl of per_upreq_m is
begin
  --* handles up requests
  --* rs: fifo_re_io, fifo_dat_i, fifo_empty_i
  --* ws: fifo_re_io, req_o
  per_upreq_p : process(clock)
    variable nilreq : std_logic_vector(50 downto 0) := (others => '0');
    variable st  : natural := 0;
  variable count: integer:=0;
  begin
   if rising_edge(Clock) then
       if reset = '1' then
      ---up_snp_req_o <= "000"&nilreq;
      ---pwr_req1 <= "00000";
      fifo_re_io <='0';
      elsif st = 0 then -- init
        if (fifo_re_io = '0' and
            fifo_empty_i = '0') then -- not (in use or empty)
          fifo_re_io   <= '1';
          st := 1;
        end if;
      elsif st = 1 then -- snd_to_arbiter
        fifo_re_io <= '0';
        if fifo_dat_i.val = '1' then
          req_o <= (fifo_dat_i.val, fifo_dat_i.cmd,
                     tag_i, fifo_dat_i.id,
                     fifo_dat_i.adr, fifo_dat_i.dat);
          --report "<<<<<<<up request snoop request tag is "& integer'image(to_integer(unsigned(tag_i)));
          st  := 2;
        end if;
      elsif st = 2 then -- done
        if req_ack_i = '1' then
          req_o <= ZERO_MSG;
          st  := 0;
        end if;
      end if;
    end if;
  end process;

  
end rtl;
