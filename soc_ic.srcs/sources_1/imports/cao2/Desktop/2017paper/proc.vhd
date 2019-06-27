library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.defs.all;
use work.util.all;
use work.test.all;
--use work.rand.all;

entity proc is
  port(
    Clock        : in  std_logic;
    reset        : in  std_logic;

    id_i         : in IP_T;
    restart_i    : in std_logic;
    snp_req_i    : in  MSG_T;
    bus_res_i    : in  BMSG_T;
    snp_hit_o    : out std_logic;
    snp_res_o    : out cacheline := ZERO_c;
	full_snpres_i:in std_logic;
    --goes to cache controller ask for data
    snp_req_o    : out MSG_T;
    snp_res_i    : in  cacheline;
    snp_hit_i    : in  std_logic;
    up_snp_req_i : in  MSG_T; --TODO rename to ureq
    up_snp_res_o : out MSG_T;
    up_snp_hit_o : out std_logic;
    wb_req_o     : out BMSG_T;

    bus_req_o    : out MSG_T := ZERO_MSG; -- a down req
    seed_i       : in natural;
    -- for observation only:
    done_o       : out std_logic;
    cpu_req_o    : out MSG_T;
    cpu_res_o    : out MSG_T;
    full_cache_req_i : in std_logic;
    ---snp request full input
    srf_full_i: in std_logic;
    ---snp request full input
    srf_full_o: out std_logic;
    ---bur snp request full
    
    upsnp_req_full :out std_logic
    );

end proc;

architecture rtl of proc is
  signal cpu_req, req : MSG_T;
  signal cpu_res : MSG_T;

  signal sim_end : std_logic := '0';
  
  signal rwt_req, rwt_res : MSG_T;
  signal rwt_req_ack, rwt_en : std_logic;
  signal rwt_done : std_logic := '0';

  signal pwrt_req, pwrt_res : MSG_T;
  signal pwrt_req_ack : std_logic;
  signal pwrt_done : std_logic := '0';
  signal crf_full: std_logic;
begin
  


  cache_ent : entity work.l1_cache(rtl) port map(
    Clock       => Clock,
    reset       => reset,

    id_i        => id_i,
    crf_full_o=>crf_full,
    cpu_req_i  => req,
    cpu_res_o => cpu_res,

    snp_req_i  => snp_req_i, -- snoop req from cache 2
    snp_hit_o => snp_hit_o,
    snp_res_o => snp_res_o,

    up_snp_req_i  => up_snp_req_i, -- upstream snoop req 
    up_snp_hit_o => up_snp_hit_o,
    up_snp_res_o => up_snp_res_o,

    snp_req_o => snp_req_o, -- fwd snp req to other cache
    snp_hit_i => snp_hit_i,
    snp_res_i => snp_res_i,
	full_snpres_i => full_snpres_i,
	full_cache_req_i=> full_cache_req_i,
    bus_req_o  => bus_req_o, -- mem or pwr req to ic
    bus_res_i   => bus_res_i, -- mem or pwr resp from ic
    srf_full_i =>srf_full_i,
    srf_full_o  => srf_full_o,
    brf_full_o  => upsnp_req_full,
    
    wb_req_o      => wb_req_o,
    full_crq_i    => '0',
    full_wb_i     => '0',
    full_srs_i    => '0'
    );

  rwt_ent : entity work.cpu_test(rwt) port map(
   rst     => reset,
   clk     => Clock,
   en      => is_tset(RW),
   restart_i => restart_i,
   seed_i   => seed_i,
   id_i      => id_i,
    
   cpu_res_i => rwt_res,
   cpu_req_o => rwt_req,
   cpu_req_ack_i => rwt_req_ack,
   done_o    => rwt_done
  
   );

  pwrt_ent : entity work.cpu_test(pwrt) port map(
   rst     => reset,
   clk     => Clock,
   en      => is_tset(PWR),
   restart_i => restart_i,
   seed_i   => seed_i,
   id_i      => id_i,
    
   cpu_res_i => pwrt_res,
   cpu_req_o => pwrt_req,
   cpu_req_ack_i => pwrt_req_ack,
   done_o    => pwrt_done
  
   );
  
  cpu_req_arbiter : entity work.arbiter6_full(rtl) port map(
   clock => Clock,
   reset => reset,
   din1  => cpu_req,
   --ack1  =>
   din2  => rwt_req,
   ack2  => rwt_req_ack,
   din3  => pwrt_req,
   ack3  => pwrt_req_ack,
   
   din4  => ZERO_MSG,
   din5  => ZERO_MSG,
   din6  => ZERO_MSG,
   dout  => req,
   full=>crf_full
   );
  
  cpu_req_o <= req;
  cpu_res_o <= cpu_res;

  rwt_res <= cpu_res when is_rw_cmd(cpu_res) else ZERO_MSG;
  pwrt_res <= cpu_res when is_pwr_cmd(cpu_res) else ZERO_MSG;

  done_o <= rwt_done;
end rtl;
