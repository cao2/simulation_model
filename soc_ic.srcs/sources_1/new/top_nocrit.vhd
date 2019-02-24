library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.defs.all;
--use work.rand.all;
use work.util.all;
use work.test.all;
Library UNISIM;
use UNISIM.vcomponents.all;
-- IBUFGDS: Differential Global Clock Input Buffer
-- 7 Series
-- Xilinx HDL Libraries Guide, version 14.7

entity top_nocrit is
	Port(
		--		Clock   : in  std_logic;
		--		--	       clk1 : in std_logic;
		--		reset   : in  std_logic;
		tx_out : out std_logic;
		rx_in  : in  std_logic;
		tra_data: out TST_TO
	);
end top_nocrit;

architecture tb of top_nocrit is
	signal clock        : std_logic;
	signal reset        : std_logic;
	-- Clock frequency and signal
	constant tb_period  : time      := 10 ps;
	signal tb_clk       : std_logic := '0';
	signal tb_sim_ended : std_logic := '0';

	signal full_c1_u, full_c2_u, full_b_m                                                                  : std_logic;
	signal cpu_res1, cpu_res2, cpu_req1, cpu_req2                                                          : MSG_T;
	signal bus_res1, bus_res2                                                                              : BMSG_T;
	signal snp_hit1, snp_hit2                                                                              : std_logic;
	signal snp_req1, snp_req2                                                                              : MSG_T;
	signal snp_res1, snp_res2                                                                              : cacheline;
	signal snp_req                                                                                         : MSG_T;
	-- -this should be DATA_WIDTH - 1
	signal snp_res                                                                                         : MSG_T;
	signal snp_hit                                                                                         : std_logic;
	signal bus_req1, bus_req2                                                                              : MSG_T;
	signal memres, tomem                                                                                   : MSG_T;
	signal full_crq1, full_srq1, full_brs1, full_wb1, full_srs1, full_crq2, full_brs2, full_wb2, full_srs2 : std_logic;
	-- -signal full_mrs: std_logic;
	signal done1, done2                                                                                    : std_logic;
	signal mem_wb, wb_req1, wb_req2                                                                        : BMSG_T;
	signal wb_ack                                                                                          : std_logic;
	signal ic_pwr_req                                                                                      : MSG_T;
	signal ic_pwr_res                                                                                      : MSG_T;
	signal pwr_req_full                                                                                    : std_logic;

	signal gfx_b, togfx                 : MSG_T;
	signal gfx_upreq, gfx_upres, gfx_wb : MSG_T;
	signal gfx_upreq_full, gfx_wb_ack   : std_logic;

	-- pwr
	signal pwr_gfx_req, pwr_gfx_res     : MSG_T;
	signal pwr_audio_req, pwr_audio_res : MSG_T;
	signal pwr_usb_req, pwr_usb_res     : MSG_T;
	signal pwr_uart_req, pwr_uart_res   : MSG_T;

	signal audio_b, toaudio                   : std_logic_vector(53 downto 0);
	signal audio_upreq, audio_upres, audio_wb : MSG_T;
	signal audio_upreq_full, audio_wb_ack     : std_logic;

	signal usb_b, tousb                 : MSG_T;
	signal usb_upreq, usb_upres, usb_wb : MSG_T;
	signal usb_upreq_full, usb_wb_ack   : std_logic;

	signal zero : std_logic := '0';

	signal uart_b, touart                  : MSG_T;
	signal uart_upreq, uart_upres, uart_wb : MSG_T;
	signal uart_upreq_full, uart_wb_ack    : std_logic;

	signal up_snp_req, up_snp_res : MSG_T;
	signal up_snp_hit             : std_logic;

	signal waddr      : ADR_T;
	signal wlen       : std_logic_vector(9 downto 0);
	signal wsize      : std_logic_vector(9 downto 0);
	signal wvalid     : std_logic;
	signal wready     : std_logic;
	-- -write data channel
	signal wdata      : DAT_T;
	signal wtrb       : std_logic_vector(3 downto 0);
	signal wlast      : std_logic;
	signal wdvalid    : std_logic;
	signal wdataready : std_logic;
	-- -write response channel
	signal wrready    : std_logic;
	signal wrvalid    : std_logic;
	signal wrsp       : std_logic_vector(1 downto 0);

	-- -read address channel
	signal raddr   : ADR_T;
	signal rlen    : std_logic_vector(9 downto 0);
	signal rsize   : std_logic_vector(9 downto 0);
	signal rvalid  : std_logic;
	signal rready  : std_logic;
	-- -read data channel
	signal rdata   : DAT_T;
	signal rstrb   : std_logic_vector(3 downto 0);
	signal rlast   : std_logic;
	signal rdvalid : std_logic;
	signal rdready : std_logic;
	signal rres    : std_logic_vector(1 downto 0);

	-- GFX
	-- -_gfx write address channel
	signal waddr_gfx      : ADR_T;
	signal wlen_gfx       : std_logic_vector(9 downto 0);
	signal wsize_gfx      : std_logic_vector(9 downto 0);
	signal wvalid_gfx     : std_logic;
	signal wready_gfx     : std_logic;
	-- _gfx-write data channel
	signal wdata_gfx      : std_logic_vector(31 downto 0);
	signal wtrb_gfx       : std_logic_vector(3 downto 0);
	signal wlast_gfx      : std_logic;
	signal wdvalid_gfx    : std_logic;
	signal wdataready_gfx : std_logic;
	-- _gfx-write response channel
	signal wrready_gfx    : std_logic;
	signal wrvalid_gfx    : std_logic;
	signal wrsp_gfx       : std_logic_vector(1 downto 0);

	-- _gfx-read address channel
	signal raddr_gfx   : ADR_T;
	signal rlen_gfx    : std_logic_vector(9 downto 0);
	signal rsize_gfx   : std_logic_vector(9 downto 0);
	signal rvalid_gfx  : std_logic;
	signal rready_gfx  : std_logic;
	-- _gfx-read data channel
	signal rdata_gfx   : DAT_T;
	signal rstrb_gfx   : std_logic_vector(3 downto 0);
	signal rlast_gfx   : std_logic;
	signal rdvalid_gfx : std_logic;
	signal rdready_gfx : std_logic;
	signal rres_gfx    : std_logic_vector(1 downto 0);

	-- UART
	-- _uart-write address channel
	signal waddr_uart      : ADR_T;
	signal wlen_uart       : std_logic_vector(9 downto 0);
	signal wsize_uart      : std_logic_vector(9 downto 0);
	signal wvalid_uart     : std_logic;
	signal wready_uart     : std_logic;
	-- _uart-write data channel
	signal wdata_uart      : DAT_T;
	signal wtrb_uart       : std_logic_vector(3 downto 0);
	signal wlast_uart      : std_logic;
	signal wdvalid_uart    : std_logic;
	signal wdataready_uart : std_logic;
	-- _uart-write response channel
	signal wrready_uart    : std_logic;
	signal wrvalid_uart    : std_logic;
	signal wrsp_uart       : std_logic_vector(1 downto 0);

	-- _uart-read address channel
	signal raddr_uart   : ADR_T;
	signal rlen_uart    : std_logic_vector(9 downto 0);
	signal rsize_uart   : std_logic_vector(9 downto 0);
	signal rvalid_uart  : std_logic;
	signal rready_uart  : std_logic;
	-- _uart-read data channel
	signal rdata_uart   : DAT_T;
	signal rstrb_uart   : std_logic_vector(3 downto 0);
	signal rlast_uart   : std_logic;
	signal rdvalid_uart : std_logic;
	signal rdready_uart : std_logic;
	signal rres_uart    : std_logic_vector(1 downto 0);

	-- USB
	-- _usb-write address channel
	signal waddr_usb      : ADR_T;
	signal wlen_usb       : std_logic_vector(9 downto 0);
	signal wsize_usb      : std_logic_vector(9 downto 0);
	signal wvalid_usb     : std_logic;
	signal wready_usb     : std_logic;
	-- _usb-write data channel
	signal wdata_usb      : DAT_T;
	signal wtrb_usb       : std_logic_vector(3 downto 0);
	signal wlast_usb      : std_logic;
	signal wdvalid_usb    : std_logic;
	signal wdataready_usb : std_logic;
	-- _usb-write response channel
	signal wrready_usb    : std_logic;
	signal wrvalid_usb    : std_logic;
	signal wrsp_usb       : std_logic_vector(1 downto 0);

	-- _usb-read address channel
	signal raddr_usb   : ADR_T;
	signal rlen_usb    : std_logic_vector(9 downto 0);
	signal rsize_usb   : std_logic_vector(9 downto 0);
	signal rvalid_usb  : std_logic;
	signal rready_usb  : std_logic;
	-- _usb-read data channel
	signal rdata_usb   : DAT_T;
	signal rstrb_usb   : std_logic_vector(3 downto 0);
	signal rlast_usb   : std_logic;
	signal rdvalid_usb : std_logic;
	signal rdready_usb : std_logic;
	signal rres_usb    : std_logic_vector(1 downto 0);

	-- AUDIO
	-- _audio-write address channel
	signal waddr_audio      : ADR_T;
	signal wlen_audio       : std_logic_vector(9 downto 0);
	signal wsize_audio      : std_logic_vector(9 downto 0);
	signal wvalid_audio     : std_logic;
	signal wready_audio     : std_logic;
	-- _audio-write data channel
	signal wdata_audio      : DAT_T;
	signal wtrb_audio       : std_logic_vector(3 downto 0);
	signal wlast_audio      : std_logic;
	signal wdvalid_audio    : std_logic;
	signal wdataready_audio : std_logic;
	-- _audio-write response channel
	signal wrready_audio    : std_logic;
	signal wrvalid_audio    : std_logic;
	signal wrsp_audio       : std_logic_vector(1 downto 0);

	-- _audio-read address channel
	signal raddr_audio   : ADR_T;
	signal rlen_audio    : std_logic_vector(9 downto 0);
	signal rsize_audio   : std_logic_vector(9 downto 0);
	signal rvalid_audio  : std_logic;
	signal rready_audio  : std_logic;
	-- _audio-read data channel
	signal rdata_audio   : DAT_T;
	signal rstrb_audio   : std_logic_vector(3 downto 0);
	signal rlast_audio   : std_logic;
	signal rdvalid_audio : std_logic;
	signal rdready_audio : std_logic;
	signal rres_audio    : std_logic_vector(1 downto 0);

	signal cpu1_pwr_req, cpu1_pwr_res, cpu2_pwr_req, cpu2_pwr_res : MSG_T;

	signal proc0_done, proc1_done, usb_done, uart_done, gfx_done, audio_done : std_logic;
	signal full_snpres                                                       : std_logic;
	--	signal Clock : std_logic;

	------MONITOR SIGNALS
	-- GFX
	-- -_gfx1 write address channel
	signal waddr_gfx1      : ADR_T;
	signal wlen_gfx1       : std_logic_vector(9 downto 0);
	signal wsize_gfx1      : std_logic_vector(9 downto 0);
	signal wvalid_gfx1     : std_logic;
	signal wready_gfx1     : std_logic;
	-- _gfx1-write data channel
	signal wdata_gfx1      : std_logic_vector(31 downto 0);
	signal wtrb_gfx1       : std_logic_vector(3 downto 0);
	signal wlast_gfx1      : std_logic;
	signal wdvalid_gfx1    : std_logic;
	signal wdataready_gfx1 : std_logic;
	-- _gfx1-write response channel
	signal wrready_gfx1    : std_logic;
	signal wrvalid_gfx1    : std_logic;
	signal wrsp_gfx1       : std_logic_vector(1 downto 0);

	-- _gfx1-read address channel
	signal raddr_gfx1   : ADR_T;
	signal rlen_gfx1    : std_logic_vector(9 downto 0);
	signal rsize_gfx1   : std_logic_vector(9 downto 0);
	signal rvalid_gfx1  : std_logic;
	signal rready_gfx1  : std_logic;
	-- _gfx1-read data channel
	signal rdata_gfx1   : DAT_T;
	signal rstrb_gfx1   : std_logic_vector(3 downto 0);
	signal rlast_gfx1   : std_logic;
	signal rdvalid_gfx1 : std_logic;
	signal rdready_gfx1 : std_logic;
	signal rres_gfx1    : std_logic_vector(1 downto 0);

	-- -_uart1 write address channel
	signal waddr_uart1      : ADR_T;
	signal wlen_uart1       : std_logic_vector(9 downto 0);
	signal wsize_uart1      : std_logic_vector(9 downto 0);
	signal wvalid_uart1     : std_logic;
	signal wready_uart1     : std_logic;
	-- _uart1-write data channel
	signal wdata_uart1      : std_logic_vector(31 downto 0);
	signal wtrb_uart1       : std_logic_vector(3 downto 0);
	signal wlast_uart1      : std_logic;
	signal wdvalid_uart1    : std_logic;
	signal wdataready_uart1 : std_logic;
	-- _uart1-write response channel
	signal wrready_uart1    : std_logic;
	signal wrvalid_uart1    : std_logic;
	signal wrsp_uart1       : std_logic_vector(1 downto 0);

	-- _uart1-read address channel
	signal raddr_uart1   : ADR_T;
	signal rlen_uart1    : std_logic_vector(9 downto 0);
	signal rsize_uart1   : std_logic_vector(9 downto 0);
	signal rvalid_uart1  : std_logic;
	signal rready_uart1  : std_logic;
	-- _uart1-read data channel
	signal rdata_uart1   : DAT_T;
	signal rstrb_uart1   : std_logic_vector(3 downto 0);
	signal rlast_uart1   : std_logic;
	signal rdvalid_uart1 : std_logic;
	signal rdready_uart1 : std_logic;
	signal rres_uart1    : std_logic_vector(1 downto 0);

	-- -_usb1 write address channel
	signal waddr_usb1      : ADR_T;
	signal wlen_usb1       : std_logic_vector(9 downto 0);
	signal wsize_usb1      : std_logic_vector(9 downto 0);
	signal wvalid_usb1     : std_logic;
	signal wready_usb1     : std_logic;
	-- _usb1-write data channel
	signal wdata_usb1      : std_logic_vector(31 downto 0);
	signal wtrb_usb1       : std_logic_vector(3 downto 0);
	signal wlast_usb1      : std_logic;
	signal wdvalid_usb1    : std_logic;
	signal wdataready_usb1 : std_logic;
	-- _usb1-write response channel
	signal wrready_usb1    : std_logic;
	signal wrvalid_usb1    : std_logic;
	signal wrsp_usb1       : std_logic_vector(1 downto 0);

	-- _usb1-read address channel
	signal raddr_usb1   : ADR_T;
	signal rlen_usb1    : std_logic_vector(9 downto 0);
	signal rsize_usb1   : std_logic_vector(9 downto 0);
	signal rvalid_usb1  : std_logic;
	signal rready_usb1  : std_logic;
	-- _usb1-read data channel
	signal rdata_usb1   : DAT_T;
	signal rstrb_usb1   : std_logic_vector(3 downto 0);
	signal rlast_usb1   : std_logic;
	signal rdvalid_usb1 : std_logic;
	signal rdready_usb1 : std_logic;
	signal rres_usb1    : std_logic_vector(1 downto 0);

	-- -_gfx1 write address channel
	signal waddr_audio1      : ADR_T;
	signal wlen_audio1       : std_logic_vector(9 downto 0);
	signal wsize_audio1      : std_logic_vector(9 downto 0);
	signal wvalid_audio1     : std_logic;
	signal wready_audio1     : std_logic;
	-- _audio1-write data channel
	signal wdata_audio1      : std_logic_vector(31 downto 0);
	signal wtrb_audio1       : std_logic_vector(3 downto 0);
	signal wlast_audio1      : std_logic;
	signal wdvalid_audio1    : std_logic;
	signal wdataready_audio1 : std_logic;
	-- _audio1-write response channel
	signal wrready_audio1    : std_logic;
	signal wrvalid_audio1    : std_logic;
	signal wrsp_audio1       : std_logic_vector(1 downto 0);

	-- _audio1-read address channel
	signal raddr_audio1   : ADR_T;
	signal rlen_audio1    : std_logic_vector(9 downto 0);
	signal rsize_audio1   : std_logic_vector(9 downto 0);
	signal rvalid_audio1  : std_logic;
	signal rready_audio1  : std_logic;
	-- _audio1-read data channel
	signal rdata_audio1   : DAT_T;
	signal rstrb_audio1   : std_logic_vector(3 downto 0);
	signal rlast_audio1   : std_logic;
	signal rdvalid_audio1 : std_logic;
	signal rdready_audio1 : std_logic;
	signal rres_audio1    : std_logic_vector(1 downto 0);

	signal waddr1      : ADR_T;
	signal wlen1       : std_logic_vector(9 downto 0);
	signal wsize1      : std_logic_vector(9 downto 0);
	signal wvalid1     : std_logic;
	signal wready1     : std_logic;
	-- -write data channel
	signal wdata1      : DAT_T;
	signal wtrb1       : std_logic_vector(3 downto 0);
	signal wlast1      : std_logic;
	signal wdvalid1    : std_logic;
	signal wdataready1 : std_logic;
	-- -write response channel
	signal wrready1    : std_logic;
	signal wrvalid1    : std_logic;
	signal wrsp1       : std_logic_vector(1 downto 0);

	-- -read address channel
	signal raddr1   : ADR_T;
	signal rlen1    : std_logic_vector(9 downto 0);
	signal rsize1   : std_logic_vector(9 downto 0);
	signal rvalid1  : std_logic;
	signal rready1  : std_logic;
	-- -read data channel
	signal rdata1   : DAT_T;
	signal rstrb1   : std_logic_vector(3 downto 0);
	signal rlast1   : std_logic;
	signal rdvalid1 : std_logic;
	signal rdready1 : std_logic;
	signal rres1    : std_logic_vector(1 downto 0);
signal up_snp_req1          : MSG_T;
     signal up_snp_res1          : MSG_T;
     signal snp_req11, snp_req21 : MSG_T;
     signal snp_res11, snp_res21 : cacheline;
    
     signal cpu_res11, cpu_res21, cpu_req11, cpu_req21                                                          : MSG_T;
    
     signal uart_upreq1, uart_upres1, audio_upreq1, audio_upres1                                                                         : MSG_T;
     signal gfx_upreq1, gfx_upres1, usb_upreq1, usb_upres1                                                                               : MSG_T;
     signal bus_req11, bus_req21                                                                                                         : MSG_T;
     signal bus_res11, bus_res21                                                                                                         : BMSG_T;
     signal up_snp_req11, up_snp_res11                                                                                                   : MSG_T;
    
     signal mon_snp_res_1, mon_snp_res_2, mon_cpu_req1, mon_cpu_res1, mon_cpu_req2, mon_cpu_res2                                         : TST_T;
     signal snp_req_1_mon, snp_req_2_mon, up_snp_req_mon, up_snp_res_mon                                                                 : TST_T;
     
     signal mon_mem_read, mon_mem_write, mon_audio_read, mon_audio_write, mon_uart_read, mon_uart_write                                  : AXI_T;
     signal mon_usb_read, mon_usb_write, mon_gfx_read, mon_gfx_write                                                                     : AXI_T;
     signal mon_bus_req1, mon_bus_req2, mon_bus_res1, mon_bus_res2                                                                       : TST_T;
     signal mon_gfx_upreq, mon_gfx_upres, mon_usb_upreq, mon_usb_upres, mon_uart_upreq, mon_uart_upres, mon_audio_upreq, mon_audio_upres : TST_T;
signal mon_data: TST_TO;
signal mon_full: std_logic;
signal mon_mem_read_t, mon_mem_write_t, mon_audio_read_t, mon_audio_write_t, mon_uart_read_t, mon_uart_write_t                                  : TST_T;
signal mon_usb_read_t, mon_usb_write_t, mon_gfx_read_t, mon_gfx_write_t  ,mon_emp                                                                  : TST_T;
     signal mon_array: ALL_T:=(others =>('0',"00000",(others=>'0'),(others=>'0'),(others=>'0'),"000"));
    signal mem_rid, mem_rtag: std_logic_vector(7 downto 0);
    signal mem_wid, mem_wtag: std_logic_vector(7 downto 0);
    signal ZERO_TSTT: TST_TO:=('0',"00000",(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),'0');
    signal monitor_data: std_logic_vector(33 downto 0);
    
    ----Configuration for monitors
    signal cmd_en_0,cmd_en_1,cmd_en_2,cmd_en_3,cmd_en_4,cmd_en_5,cmd_en_6,cmd_en_7: std_logic_vector(4 downto 0) := "11111";
    signal cmd_en_8,cmd_en_9,cmd_en_10,cmd_en_11,cmd_en_12,cmd_en_13,cmd_en_14,cmd_en_15: std_logic_vector(4 downto 0):= "11111";
    signal cmd_en_16,cmd_en_17,cmd_en_18,cmd_en_19,cmd_en_20,cmd_en_21,cmd_en_22,cmd_en_23: std_logic_vector(4 downto 0):= "11111";
    signal cmd_en_24,cmd_en_25,cmd_en_26,cmd_en_27,cmd_en_28,cmd_en_29,cmd_en_30,cmd_en_31: std_logic_vector(4 downto 0):= "11111";
    signal tag_en_0,tag_en_1,tag_en_2,tag_en_3,tag_en_4,tag_en_5,tag_en_6,tag_en_7: std_logic_vector(7 downto 0):= "11111111";
    signal tag_en_8,tag_en_9,tag_en_10,tag_en_11,tag_en_12,tag_en_13,tag_en_14,tag_en_15: std_logic_vector(7 downto 0):= "11111111";
    signal tag_en_16,tag_en_17,tag_en_18,tag_en_19,tag_en_20,tag_en_21,tag_en_22,tag_en_23: std_logic_vector(7 downto 0):= "11111111";
    signal tag_en_24,tag_en_25,tag_en_26,tag_en_27,tag_en_28,tag_en_29,tag_en_30,tag_en_31: std_logic_vector(7 downto 0):= "11111111";
    signal id_en_0,id_en_1,id_en_2,id_en_3,id_en_4,id_en_5,id_en_6,id_en_7: std_logic_vector(7 downto 0):= "11111111";
    signal id_en_8,id_en_9,id_en_10,id_en_11,id_en_12,id_en_13,id_en_14,id_en_15: std_logic_vector(7 downto 0):= "11111111";
    signal id_en_16,id_en_17,id_en_18,id_en_19,id_en_20,id_en_21,id_en_22,id_en_23: std_logic_vector(7 downto 0):= "11111111";
    signal id_en_24,id_en_25,id_en_26,id_en_27,id_en_28,id_en_29,id_en_30,id_en_31: std_logic_vector(7 downto 0):= "11111111";
    

    signal data_dropped: std_logic_vector (4 downto 0);
    
    signal ranks: rank_list;
begin
     rank_set: process(reset)
     begin
        if (reset='1') then
        ranks(0) <=0;
        ranks(1) <=1;
        ranks(2) <=2;
        ranks(3) <=3;
        ranks(4) <=4;
        ranks(5) <=5;
        ranks(6) <=6;
        ranks(7) <=7;
        ranks(8) <=8;
        ranks(9) <=9;
        ranks(10) <=10;
        ranks(11) <=11;
        ranks(12) <=12;
        ranks(13) <=13;
        ranks(14) <=14;
        ranks(15) <=15;
        ranks(16) <=16;
        ranks(17) <=17;
        ranks(18) <=18;
        ranks(19) <=19;
        ranks(20) <=20;
        ranks(21) <=21;
        ranks(22) <=22;
        ranks(23) <=23;
        ranks(24) <=24;
        ranks(25) <=25;
        ranks(26) <=26;
        ranks(27) <=27;
        ranks(28) <=28;
        ranks(29) <=29;
        ranks(30) <=30;
        ranks(31) <=31;
        end if;
     end process;
     
     
     
      trace_output_logger: process(tb_clk)
       file trace_file: TEXT open write_mode is "trace_output.tstt";
       variable l: line;
     begin
               if GEN_TRACE1 then
                   if rising_edge(tb_clk) or falling_edge(tb_clk) then
                       ---- cpu
                       write(l, monitor_data&data_dropped);     --35
                       
                       writeline(trace_file, l);
                   end if;
               end if;
           end process; 
  trace_ip: entity work.arbiter32_nocritical(rtl)
    generic map(
     FIFO_DEPTH => 8
    )
             port map(
             CLK => Clock,
             RST => reset,
             ranks => ranks,
             ranks_fifo => ranks,
             critical => 12,
             DataIn => mon_array,
             DataOut => monitor_data,
             data_dropped => data_dropped
             --control_full => mon_full
             );

    mon_array_driver: process(tb_clk)
    begin
        if rising_edge(tb_clk) then
             mon_array(0)<=mon_cpu_req1; ----1
             mon_array(1)<=mon_cpu_res1; ----2
             mon_array(2)<=mon_cpu_req2; ----3
             mon_array(3)<=mon_cpu_res2; ----4
             
             mon_array(4)<=mon_gfx_upreq; ----5
             mon_array(5)<=mon_gfx_upres; ----6
                          mon_array(6)<=mon_audio_upreq; ----7
                          mon_array(7)<=mon_audio_upres; ----8
              mon_array(8)<=mon_uart_upreq; ----9
              mon_array(9)<=mon_uart_upres; ----10  
              mon_array(10)<=mon_usb_upreq; ----11
              mon_array(11)<=mon_usb_upres; ----12  
                                        
             mon_array(12)<=mon_bus_req1; ----11
                                                    mon_array(13)<=mon_bus_req2; ----12
                                                    mon_array(14)<=mon_bus_res1; ----13
                                                    mon_array(15)<=mon_bus_res2; ----14                   
             mon_array(16)<=mon_mem_read_t; ----15
                                                                 mon_array(17)<=mon_mem_write_t; ----16
                                                                 mon_array(18)<=mon_gfx_read_t; ----17
                                                                 mon_array(19)<=mon_gfx_write_t; ----18
                                                                 mon_array(20)<=mon_audio_read_t; ----19
                                                                 mon_array(21)<=mon_audio_write_t; ----20
                                                                 mon_array(22)<=mon_usb_read_t; ----21
                                                                 mon_array(23)<=mon_usb_write_t; ----22
                                                                 mon_array(24)<=mon_uart_read_t; ----23
                                                                 mon_array(25)<=mon_uart_write_t; ----24  
                                                                            mon_array(26)<=up_snp_req_mon; ----13
                                                                            mon_array(27)<=up_snp_res_mon; ----14           
             mon_array(28)<=snp_req_1_mon; ----5
             mon_array(29)<=snp_req_2_mon; ----6
             mon_array(30)<=mon_snp_res_1; ----7
             mon_array(31)<=mon_snp_res_2; ----8  
        end if;
    end process;
	
    cpu_req1_monitor : entity work.monitor_customized(Behavioral)
        port map(
         clk           => Clock,
         rst           => reset,
         cmd_en        => cmd_en_0,
         id_en         => id_en_0,
         tag_en        => tag_en_0,
         link_id           => "00000",
         ---slave_id   => CACHE0,
         msg_i         => cpu_req1,
         msg_o         => cpu_req11,
         transaction_o => mon_cpu_req1
        );
        
       cpu_res1_monitor : entity work.monitor_customized(Behavioral)
        port map(
         clk           => Clock,
         rst           => reset,
        cmd_en        => cmd_en_1,
        id_en         => id_en_1,
        tag_en        => tag_en_1,         
       
         link_id           =>"00001",
         ---slave_id   => CPU0,
         msg_i         => cpu_res1,
         msg_o         => cpu_res11,
         transaction_o => mon_cpu_res1
        );
       cpu_req2_monitor : entity work.monitor_customized(Behavioral)
        port map(
         clk           => Clock,
         rst           => reset,
         cmd_en        => cmd_en_2,
                  id_en         => id_en_2,
                  tag_en        => tag_en_2,
         link_id           => "00010",
         ---slave_id   => CACHE1,
         msg_i         => cpu_req2,
         msg_o         => cpu_req21,
         transaction_o => mon_cpu_req2
        );
       cpu_res2_monitor : entity work.monitor_customized(Behavioral)
        port map(
         clk           => Clock,
         rst           => reset,
         cmd_en        => cmd_en_3,
                  id_en         => id_en_3,
                  tag_en        => tag_en_3,
         link_id           => "00011",
         ---slave_id   => CPU1,
         msg_i         => cpu_res2,
         msg_o         => cpu_res21,
         transaction_o => mon_cpu_res2
        );
      gfx_upreq_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_4,
                       id_en         => id_en_4,
                       tag_en        => tag_en_4,
              link_id           => "00100",
              ---slave_id   => SA,
              msg_i         => gfx_upreq,
              msg_o         => gfx_upreq1,
              transaction_o => mon_gfx_upreq
          );
      gfx_upres_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_5,
                       id_en         => id_en_5,
                       tag_en        => tag_en_5,
              link_id           => "00101",
              ---slave_id   => GFXM,
              msg_i         => gfx_upres,
              msg_o         => gfx_upres1,
              transaction_o => mon_gfx_upres
          );
  
      audio_upreq_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_6,
                       id_en         => id_en_6,
                       tag_en        => tag_en_6,
              link_id           => "00110",
              ---slave_id   => SA,
              msg_i         => audio_upreq,
              msg_o         => audio_upreq1,
              transaction_o => mon_audio_upreq
          );
      audio_upres_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_7,
                       id_en         => id_en_7,
                       tag_en        => tag_en_7,
              link_id           => "00111",
              ---slave_id   => AUDIOM,
              msg_i         => audio_upres,
              msg_o         => audio_upres1,
              transaction_o => mon_audio_upres
          );
  
      uart_upreq_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_8,
                       id_en         => id_en_8,
                       tag_en        => tag_en_8,
              link_id           => "01000",
              ---slave_id   => SA,
              msg_i         => uart_upreq,
              msg_o         => uart_upreq1,
              transaction_o => mon_uart_upreq
          );
      uart_upres_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_9,
                       id_en         => id_en_9,
                       tag_en        => tag_en_9,
              link_id           => "01001",
              ---slave_id   => UARTM,
              msg_i         => uart_upres,
              msg_o         => uart_upres1,
              transaction_o => mon_uart_upres
          );
  
      usb_upreq_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_10,
                       id_en         => id_en_10,
                       tag_en        => tag_en_10,
              link_id           => "01010",
              ---slave_id   => SA,
              msg_i         => usb_upreq,
              msg_o         => usb_upreq1,
              transaction_o => mon_usb_upreq
          );
      usb_upres_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_11,
                       id_en         => id_en_11,
                       tag_en        => tag_en_11,
              link_id           => "01011",
              ---slave_id   => USBM,
              msg_i         => usb_upres,
              msg_o         => usb_upres1,
              transaction_o => mon_usb_upres
          );
  
      bus_req1_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_12,
                       id_en         => id_en_12,
                       tag_en        => tag_en_12,
              link_id           => "01100",
              ---slave_id   => SA,
              msg_i         => bus_req1,
              msg_o         => bus_req11,
              transaction_o => mon_bus_req1
          );
      bus_req2_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_13,
                       id_en         => id_en_13,
                       tag_en        => tag_en_13,
              link_id           => "01101",
              ---slave_id   => SA,
              msg_i         => bus_req2,
              msg_o         => bus_req21,
              transaction_o => mon_bus_req2
          );
      bus_res1_monitor : entity work.monitor_customized_B(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_14,
                       id_en         => id_en_14,
                       tag_en        => tag_en_14,
              link_id           => "01110",
              ---slave_id   => CACHE0,
              msg_i         => bus_res1,
              msg_o         => bus_res11,
              transaction_o => mon_bus_res1
          );
      bus_res2_monitor : entity work.monitor_customized_B(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_15,
                       id_en         => id_en_15,
                       tag_en        => tag_en_15,
              link_id           => "01111",
              ---slave_id   => CACHE1,
              msg_i         => bus_res2,
              msg_o         => bus_res21,
              transaction_o => mon_bus_res2
          );
      mem_monitor_read : entity work.monitor_axi_read(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_16,
                       id_en         => id_en_16,
                       tag_en        => tag_en_16,
              ----AXI interface
              link_id           => "10000",
              ---slave_id   => MEM,
              tag_i => mem_rtag,
              id_i          => mem_rid,
              ---write address channel
  
              ---read address channel
              raddr_i       => raddr,
              rlen_i        => rlen,
              rsize_i       => rsize,
              rvalid_i      => rvalid,
              rready_i      => rready,
              ---read data channel
              rdata_i       => rdata,
              rstrb_i       => rstrb,
              rlast_i       => rlast,
              rdvalid_i     => rdvalid,
              rdready_i     => rdready,
              rres_i        => rres,
              ----output 
              --id_o         =>,
              ---read address channel
  
              raddr_o       => raddr1,
              rlen_o        => rlen1,
              rsize_o       => rsize1,
              rvalid_o      => rvalid1,
              rready_o      => rready1,
              ---read data channel
              rdata_o       => rdata1,
              rstrb_o       => rstrb1,
              rlast_o       => rlast1,
              rdvalid_o     => rdvalid1,
              rdready_o     => rdready1,
              rres_o        => rres1,
              transaction_o => mon_mem_read,
              tst_t_o => mon_mem_read_t
          );
      mem_monitor_write : entity work.monitor_axi_write(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              ----AXI interface
              cmd_en        => cmd_en_17,
                       id_en         => id_en_17,
                       tag_en        => tag_en_17,
              link_id           => "10001",
              ---slave_id   => MEM,
              tag_i => mem_wtag,
                          id_i          => mem_wid,
              ---write address channel
              waddr_i       => waddr,
              wlen_i        => wlen,
              wsize_i       => wsize,
              wvalid_i      => wvalid,
              wready_i      => wready,
              ---write data channel
              wdata_i       => wdata,
              wtrb_i        => wtrb,      --TODO not implemented
              wlast_i       => wlast,
              wdvalid_i     => wdvalid,
              wdataready_i  => wdataready,
              ---write response channel
              wrready_i     => wrready,
              wrvalid_i     => wrvalid,
              wrsp_i        => wrsp,
              --OUTPUT
              ---write address channel
              waddr_o       => waddr1,
              wlen_o        => wlen1,
              wsize_o       => wsize1,
              wvalid_o      => wvalid1,
              wready_o      => wready1,
              ---write data channel
              wdata_o       => wdata1,
              wtrb_o        => wtrb1,     --TODO not implemented
              wlast_o       => wlast1,
              wdvalid_o     => wdvalid1,
              wdataready_o  => wdataready1,
              ---write response channel
              wrready_o     => wrready1,
              wrvalid_o     => wrvalid1,
              wrsp_o        => wrsp1,
              transaction_o => mon_mem_write,
              tst_t_o => mon_mem_write_t
          );
  
      gfx_monitor_read : entity work.monitor_axi_read(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_18,
                       id_en         => id_en_18,
                       tag_en        => tag_en_18,
              ----AXI interface
              link_id           => "10010",
              ---slave_id   => GFX,
              tag_i => "UUUUUUUU",
              id_i => "UUUUUUUU",
              ---write address channel
  
              ---read address channel
              raddr_i       => raddr_gfx,
              rlen_i        => rlen_gfx,
              rsize_i       => rsize_gfx,
              rvalid_i      => rvalid_gfx,
              rready_i      => rready_gfx,
              ---read data channel
              rdata_i       => rdata_gfx,
              rstrb_i       => rstrb_gfx,
              rlast_i       => rlast_gfx,
              rdvalid_i     => rdvalid_gfx,
              rdready_i     => rdready_gfx,
              rres_i        => rres_gfx,
              ----output 
              --id_o         =>,
              ---read address channel
              raddr_o       => raddr_gfx1,
              rlen_o        => rlen_gfx1,
              rsize_o       => rsize_gfx1,
              rvalid_o      => rvalid_gfx1,
              rready_o      => rready_gfx1,
              ---read data channel
              rdata_o       => rdata_gfx1,
              rstrb_o       => rstrb_gfx1,
              rlast_o       => rlast_gfx1,
              rdvalid_o     => rdvalid_gfx1,
              rdready_o     => rdready_gfx1,
              rres_o        => rres_gfx1,
              transaction_o => mon_gfx_read,
              tst_t_o => mon_gfx_read_t
          );
      gfx_monitor_write : entity work.monitor_axi_write(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_19,
                       id_en         => id_en_19,
                       tag_en        => tag_en_19,
              ----AXI interface
              link_id           => "10011",
              ---slave_id   => GFX,
              tag_i => "UUUUUUUU",
                          id_i => "UUUUUUUU",
              ---write address channel
              waddr_i       => waddr_gfx,
              wlen_i        => wlen_gfx,
              wsize_i       => wsize_gfx,
              wvalid_i      => wvalid_gfx,
              wready_i      => wready_gfx,
              ---write data channel
              wdata_i       => wdata_gfx,
              wtrb_i        => wtrb_gfx,  --TODO not implemented
              wlast_i       => wlast_gfx,
              wdvalid_i     => wdvalid_gfx,
              wdataready_i  => wdataready_gfx,
              ---write response channel
              wrready_i     => wrready_gfx,
              wrvalid_i     => wrvalid_gfx,
              wrsp_i        => wrsp_gfx,
              --OUTPUT
              ---write address channel
              waddr_o       => waddr_gfx1,
              wlen_o        => wlen_gfx1,
              wsize_o       => wsize_gfx1,
              wvalid_o      => wvalid_gfx1,
              wready_o      => wready_gfx1,
              ---write data channel
              wdata_o       => wdata_gfx1,
              wtrb_o        => wtrb_gfx1, --TODO not implemented
              wlast_o       => wlast_gfx1,
              wdvalid_o     => wdvalid_gfx1,
              wdataready_o  => wdataready_gfx1,
              ---write response channel
              wrready_o     => wrready_gfx1,
              wrvalid_o     => wrvalid_gfx1,
              wrsp_o        => wrsp_gfx1,
              transaction_o => mon_gfx_write,
              tst_t_o => mon_gfx_write_t
          );
  
      audio_monitor_read : entity work.monitor_axi_read(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_20,
              id_en         => id_en_20,
              tag_en        => tag_en_20,
              ----AXI interface
              link_id           => "10100",
              ---slave_id   => AUDIO,
              tag_i => "UUUUUUUU",
              id_i => "UUUUUUUU",
              ---write address channel
  
              ---read address channel
              raddr_i       => raddr_audio,
              rlen_i        => rlen_audio,
              rsize_i       => rsize_audio,
              rvalid_i      => rvalid_audio,
              rready_i      => rready_audio,
              ---read data channel
              rdata_i       => rdata_audio,
              rstrb_i       => rstrb_audio,
              rlast_i       => rlast_audio,
              rdvalid_i     => rdvalid_audio,
              rdready_i     => rdready_audio,
              rres_i        => rres_audio,
              ----output 
              --id_o         =>,
              ---read address channel
              raddr_o       => raddr_audio1,
              rlen_o        => rlen_audio1,
              rsize_o       => rsize_audio1,
              rvalid_o      => rvalid_audio1,
              rready_o      => rready_audio1,
              ---read data channel
              rdata_o       => rdata_audio1,
              rstrb_o       => rstrb_audio1,
              rlast_o       => rlast_audio1,
              rdvalid_o     => rdvalid_audio1,
              rdready_o     => rdready_audio1,
              rres_o        => rres_audio1,
              transaction_o => mon_audio_read,
              tst_t_o => mon_audio_read_t
          );
      audio_monitor_write : entity work.monitor_axi_write(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_21,
                       id_en         => id_en_21,
                       tag_en        => tag_en_21,
              ----AXI interface
              link_id           => "10101",
              ---slave_id   => MEM,
              tag_i => "UUUUUUUU",
                          id_i => "UUUUUUUU",
              ---write address channel
              waddr_i       => waddr_audio,
              wlen_i        => wlen_audio,
              wsize_i       => wsize_audio,
              wvalid_i      => wvalid_audio,
              wready_i      => wready_audio,
              ---write data channel
              wdata_i       => wdata_audio,
              wtrb_i        => wtrb_audio, --TODO not implemented
              wlast_i       => wlast_audio,
              wdvalid_i     => wdvalid_audio,
              wdataready_i  => wdataready_audio,
              ---write response channel
              wrready_i     => wrready_audio,
              wrvalid_i     => wrvalid_audio,
              wrsp_i        => wrsp_audio,
              --OUTPUT
              ---write address channel
              waddr_o       => waddr_audio1,
              wlen_o        => wlen_audio1,
              wsize_o       => wsize_audio1,
              wvalid_o      => wvalid_audio1,
              wready_o      => wready_audio1,
              ---write data channel
              wdata_o       => wdata_audio1,
              wtrb_o        => wtrb_audio1, --TODO not implemented
              wlast_o       => wlast_audio1,
              wdvalid_o     => wdvalid_audio1,
              wdataready_o  => wdataready_audio1,
              ---write response channel
              wrready_o     => wrready_audio1,
              wrvalid_o     => wrvalid_audio1,
              wrsp_o        => wrsp_audio1,
              transaction_o => mon_audio_write,
              tst_t_o => mon_audio_write_t
          );
  
      usb_monitor_read : entity work.monitor_axi_read(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_22,
                       id_en         => id_en_22,
                       tag_en        => tag_en_22,
              ----AXI interface
              link_id           => "10110",
              ---slave_id   => MEM,
              tag_i => "UUUUUUUU",
              id_i => "UUUUUUUU",
              ---write address channel
  
              ---read address channel
              raddr_i       => raddr_usb,
              rlen_i        => rlen_usb,
              rsize_i       => rsize_usb,
              rvalid_i      => rvalid_usb,
              rready_i      => rready_usb,
              ---read data channel
              rdata_i       => rdata_usb,
              rstrb_i       => rstrb_usb,
              rlast_i       => rlast_usb,
              rdvalid_i     => rdvalid_usb,
              rdready_i     => rdready_usb,
              rres_i        => rres_usb,
              ----output 
              --id_o         =>,
              ---read address channel
              raddr_o       => raddr_usb1,
              rlen_o        => rlen_usb1,
              rsize_o       => rsize_usb1,
              rvalid_o      => rvalid_usb1,
              rready_o      => rready_usb1,
              ---read data channel
              rdata_o       => rdata_usb1,
              rstrb_o       => rstrb_usb1,
              rlast_o       => rlast_usb1,
              rdvalid_o     => rdvalid_usb1,
              rdready_o     => rdready_usb1,
              rres_o        => rres_usb1,
              transaction_o => mon_usb_read,
              tst_t_o => mon_usb_read_t
          );
      usb_monitor_write : entity work.monitor_axi_write(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_23,
                       id_en         => id_en_23,
                       tag_en        => tag_en_23,
              ----AXI interface
              link_id           => "10111",
              ---slave_id   => MEM,
              tag_i => "UUUUUUUU",
                          id_i => "UUUUUUUU",
              ---write address channel
              waddr_i       => waddr_usb,
              wlen_i        => wlen_usb,
              wsize_i       => wsize_usb,
              wvalid_i      => wvalid_usb,
              wready_i      => wready_usb,
              ---write data channel
              wdata_i       => wdata_usb,
              wtrb_i        => wtrb_usb,  --TODO not implemented
              wlast_i       => wlast_usb,
              wdvalid_i     => wdvalid_usb,
              wdataready_i  => wdataready_usb,
              ---write response channel
              wrready_i     => wrready_usb,
              wrvalid_i     => wrvalid_usb,
              wrsp_i        => wrsp_usb,
              --OUTPUT
              ---write address channel
              waddr_o       => waddr_usb1,
              wlen_o        => wlen_usb1,
              wsize_o       => wsize_usb1,
              wvalid_o      => wvalid_usb1,
              wready_o      => wready_usb1,
              ---write data channel
              wdata_o       => wdata_usb1,
              wtrb_o        => wtrb_usb1, --TODO not implemented
              wlast_o       => wlast_usb1,
              wdvalid_o     => wdvalid_usb1,
              wdataready_o  => wdataready_usb1,
              ---write response channel
              wrready_o     => wrready_usb1,
              wrvalid_o     => wrvalid_usb1,
              wrsp_o        => wrsp_usb1,
              transaction_o => mon_usb_write,
              tst_t_o => mon_usb_write_t
          );
  
      uart_monitor_read : entity work.monitor_axi_read(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_24,
                       id_en         => id_en_24,
                       tag_en        => tag_en_24,
              ----AXI interface
              link_id           => "11000",
              ---slave_id   => MEM,
              tag_i => "UUUUUUUU",
                          id_i => "UUUUUUUU",
              ---write address channel
  
              ---read address channel
              raddr_i       => raddr_uart,
              rlen_i        => rlen_uart,
              rsize_i       => rsize_uart,
              rvalid_i      => rvalid_uart,
              rready_i      => rready_uart,
              ---read data channel
              rdata_i       => rdata_uart,
              rstrb_i       => rstrb_uart,
              rlast_i       => rlast_uart,
              rdvalid_i     => rdvalid_uart,
              rdready_i     => rdready_uart,
              rres_i        => rres_uart,
              ----output 
              --id_o         =>,
              ---read address channel
              raddr_o       => raddr_uart1,
              rlen_o        => rlen_uart1,
              rsize_o       => rsize_uart1,
              rvalid_o      => rvalid_uart1,
              rready_o      => rready_uart1,
              ---read data channel
              rdata_o       => rdata_uart1,
              rstrb_o       => rstrb_uart1,
              rlast_o       => rlast_uart1,
              rdvalid_o     => rdvalid_uart1,
              rdready_o     => rdready_uart1,
              rres_o        => rres_uart1,
              transaction_o => mon_uart_read,
              tst_t_o => mon_uart_read_t
          );
      uart_monitor_write : entity work.monitor_axi_write(rtl)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_25,
                       id_en         => id_en_25,
                       tag_en        => tag_en_25,
              ----AXI interface
              link_id           => "11001",
              ---slave_id   => MEM,
              tag_i => "UUUUUUUU",
                          id_i => "UUUUUUUU",
              ---write address channel
              waddr_i       => waddr_uart,
              wlen_i        => wlen_uart,
              wsize_i       => wsize_uart,
              wvalid_i      => wvalid_uart,
              wready_i      => wready_uart,
              ---write data channel
              wdata_i       => wdata_uart,
              wtrb_i        => wtrb_uart, --TODO not implemented
              wlast_i       => wlast_uart,
              wdvalid_i     => wdvalid_uart,
              wdataready_i  => wdataready_uart,
              ---write response channel
              wrready_i     => wrready_uart,
              wrvalid_i     => wrvalid_uart,
              wrsp_i        => wrsp_uart,
              --OUTPUT
              ---write address channel
              waddr_o       => waddr_uart1,
              wlen_o        => wlen_uart1,
              wsize_o       => wsize_uart1,
              wvalid_o      => wvalid_uart1,
              wready_o      => wready_uart1,
              ---write data channel
              wdata_o       => wdata_uart1,
              wtrb_o        => wtrb_uart1, --TODO not implemented
              wlast_o       => wlast_uart1,
              wdvalid_o     => wdvalid_uart1,
              wdataready_o  => wdataready_uart1,
              ---write response channel
              wrready_o     => wrready_uart1,
              wrvalid_o     => wrvalid_uart1,
              wrsp_o        => wrsp_uart1,
              transaction_o => mon_uart_write,
              tst_t_o => mon_uart_write_t
          );
  
      up_snp_req_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_26,
                       id_en         => id_en_26,
                       tag_en        => tag_en_26,
              link_id           => "11010",
              ---slave_id   => CACHE0,
              msg_i         => up_snp_req,
              msg_o         => up_snp_req11,
              transaction_o => up_snp_req_mon
          );
      up_snp_res_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_27,
                       id_en         => id_en_27,
                       tag_en        => tag_en_27,
              link_id           => "11011",
              ---slave_id   => SAM,
              msg_i         => up_snp_res,
              msg_o         => up_snp_res11,
              transaction_o => up_snp_res_mon
          );
      snp_req_1_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_28,
                       id_en         => id_en_28,
                       tag_en        => tag_en_28,
              link_id           => "11100",
              ---slave_id   => CACHE0,
              msg_i         => snp_req1,
              msg_o         => snp_req11,
              transaction_o => snp_req_1_mon
          );
      snp_req_2_monitor : entity work.monitor_customized(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_29,
                       id_en         => id_en_29,
                       tag_en        => tag_en_29,
              link_id           => "11101",
              ---slave_id   => CACHE1,
              msg_i         => snp_req2,
              msg_o         => snp_req21,
              transaction_o => snp_req_2_mon
          );
      snp_res_1_monitor : entity work.monitor_cacheline(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_30,
                       id_en         => id_en_30,
                       tag_en        => tag_en_30,
              link_id           => "11110",
              ---slave_id   => CACHE1M,
              msg_i         => snp_res1,
              msg_o         => snp_res11,
              transaction_o => mon_snp_res_1
          );
      snp_res_2_monitor : entity work.monitor_cacheline(Behavioral)
          port map(
              clk           => Clock,
              rst           => reset,
              cmd_en        => cmd_en_31,
                       id_en         => id_en_31,
                       tag_en        => tag_en_31,
              link_id           => "11111",
              ---slave_id   => CACHE0M,
              msg_i         => snp_res2,
              msg_o         => snp_res21,
              transaction_o => mon_snp_res_2
          );
      --        IBUFGDS_inst : IBUFGDS
      --generic map (
      --DIFF_TERM => FALSE, -- Differential Termination
      --IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      --IOSTANDARD => "DEFAULT")
      --port map (
      --O => Clock, -- Clock buffer output
      --I => clk, -- Diff_p clock buffer input (connect directly to top-level port)
      --IB => clk1 -- Diff_n clock buffer input (connect directly to top-level port)
      --);
      -- End of IBUFGDS_inst instantiation
      proc0_e : entity work.proc(rtl)
          port map(
              reset         => reset,
              Clock         => Clock,
              id_i          => CPU0,
              snp_req_i     => snp_req11, -- snoop req from cache 2
              snp_hit_o     => snp_hit1,
              snp_res_o     => snp_res1,
              up_snp_req_i  => up_snp_req11, -- upstream snoop req 
              up_snp_hit_o  => up_snp_hit,
              up_snp_res_o  => up_snp_res,
              full_snpres_i => full_snpres,
              snp_req_o     => snp_req2,  -- fwd snp req to other cache
              snp_hit_i     => snp_hit2,
              snp_res_i     => snp_res21,
              bus_req_o     => bus_req1,  -- mem or pwr req to ic
              bus_res_i     => bus_res11, -- mem or pwr resp from ic    
              full_cache_req_i =>'0',
               srf_full_i =>'0',
             
              --     wb_req_o      => wb_req1,
  
              -- for observation:
              done_o        => proc0_done,
              cpu_req_o     => cpu_req1,
              cpu_res_o     => cpu_res1
          );
  
      proc1_e : entity work.proc(rtl)
          port map(
              reset         => reset,
              Clock         => Clock,
              id_i          => CPU1,
              snp_req_i     => snp_req21, -- snoop req from cache 2
              snp_hit_o     => snp_hit2,
              snp_res_o     => snp_res2,
              -- TODO not implemented yet:
               full_cache_req_i =>'0',
                srf_full_i =>'0',
              up_snp_req_i  => ZERO_MSG,  -- upstream snoop req 
              --up_snp_hit_o => ,
              --up_snp_res_o => ,
              full_snpres_i => '0',
              snp_req_o     => snp_req1,  -- fwd snp req to other cache
              snp_hit_i     => snp_hit1,
              snp_res_i     => snp_res11,
              bus_req_o     => bus_req2,  -- mem or pwr req to ic
              bus_res_i     => bus_res21, -- mem or pwr resp from ic    
  
              --     wb_req_o      => wb_req2,
  
              -- for observation:
              done_o        => proc1_done,
              cpu_req_o     => cpu_req2,
              cpu_res_o     => cpu_res2
          );
  
      power : entity work.pwr(rtl)
          port map(
              Clock       => Clock,
              reset       => reset,
              req_i       => ic_pwr_req,
              res_o       => ic_pwr_res,
              audio_req_o => pwr_audio_req,
              audio_res_i => pwr_audio_res,
              usb_req_o   => pwr_usb_req,
              usb_res_i   => pwr_usb_res,
              uart_req_o  => pwr_uart_req,
              uart_res_i  => pwr_uart_res,
              full_preq   => pwr_req_full,
              gfx_req_o   => pwr_gfx_req,
              gfx_res_i   => pwr_gfx_res
          );
  
      interconnect : entity work.ic(rtl)
          port map(
          snp_req_full_i=>'0',
              Clock              => Clock,
              reset              => reset,
              gfx_upreq_i        => gfx_upreq1,
              gfx_upres_o        => gfx_upres,
              gfx_upreq_full_o   => gfx_upreq_full,
              audio_upreq_i      => audio_upreq1,
              audio_upres_o      => audio_upres,
              audio_upreq_full_o => audio_upreq_full,
              usb_upreq_i        => usb_upreq1,
              usb_upres_o        => usb_upres,
              usb_upreq_full_o   => usb_upreq_full,
              uart_upreq_i       => uart_upreq1,
              uart_upres_o       => uart_upres,
              uart_upreq_full_o  => uart_upreq_full,
              full_snpres_o      => full_snpres, -- enabled if snp res fifo is full
              mem_rid => mem_rid,
              mem_rtag=> mem_rtag,
              mem_wid => mem_wid,
              mem_wtag=> mem_wtag,
              -- write
              waddr              => waddr,
              wlen               => wlen,
              wsize              => wsize,
              wvalid             => wvalid,
              wready             => wready1,
              wdata              => wdata,
              wtrb               => wtrb,
              wlast              => wlast,
              wdvalid            => wdvalid,
              wdataready         => wdataready1,
              wrready            => wrready,
              wrvalid_i          => wrvalid1, -- write resp
              wrsp               => wrsp1,
              -- read
              raddr              => raddr,
              rlen               => rlen,
              rsize              => rsize,
              rvalid_o           => rvalid,
              rready             => rready1,
              rdata              => rdata1,
              rstrb              => rstrb1,
              rlast              => rlast1,
              rdvalid_i          => rdvalid1,
              rdready            => rdready,
              rres               => rres1,
              waddr_gfx          => waddr_gfx,
              wlen_gfx           => wlen_gfx,
              wsize_gfx          => wsize_gfx,
              wvalid_gfx         => wvalid_gfx,
              wready_gfx         => wready_gfx1,
              wdata_gfx          => wdata_gfx,
              wtrb_gfx           => wtrb_gfx,
              wlast_gfx          => wlast_gfx,
              wdvalid_gfx        => wdvalid_gfx,
              wdataready_gfx     => wdataready_gfx1,
              wrready_gfx        => wrready_gfx,
              wrvalid_gfx        => wrvalid_gfx1,
              wrsp_gfx           => wrsp_gfx1,
              raddr_gfx          => raddr_gfx,
              rlen_gfx           => rlen_gfx,
              rsize_gfx          => rsize_gfx,
              rvalid_gfx         => rvalid_gfx,
              rready_gfx         => rready_gfx1,
              rdata_gfx          => rdata_gfx1,
              rstrb_gfx          => rstrb_gfx1,
              rlast_gfx          => rlast_gfx1,
              rdvalid_gfx        => rdvalid_gfx1,
              rdready_gfx        => rdready_gfx,
              rres_gfx           => rres_gfx1,
              waddr_uart         => waddr_uart,
              wlen_uart          => wlen_uart,
              wsize_uart         => wsize_uart,
              wvalid_uart        => wvalid_uart,
              wready_uart        => wready_uart1,
              wdata_uart         => wdata_uart,
              wtrb_uart          => wtrb_uart,
              wlast_uart         => wlast_uart,
              wdvalid_uart       => wdvalid_uart,
              wdataready_uart    => wdataready_uart1,
              wrready_uart       => wrready_uart,
              wrvalid_uart       => wrvalid_uart1,
              wrsp_uart          => wrsp_uart1,
              raddr_uart         => raddr_uart,
              rlen_uart          => rlen_uart,
              rsize_uart         => rsize_uart,
              rvalid_uart        => rvalid_uart,
              rready_uart        => rready_uart1,
              rdata_uart         => rdata_uart1,
              rstrb_uart         => rstrb_uart1,
              rlast_uart         => rlast_uart1,
              rdvalid_uart       => rdvalid_uart1,
              rdready_uart       => rdready_uart,
              rres_uart          => rres_uart1,
              waddr_usb          => waddr_usb,
              wlen_usb           => wlen_usb,
              wsize_usb          => wsize_usb,
              wvalid_usb         => wvalid_usb,
              wready_usb         => wready_usb1,
              wdata_usb          => wdata_usb,
              wtrb_usb           => wtrb_usb,
              wlast_usb          => wlast_usb,
              wdvalid_usb        => wdvalid_usb,
              wdataready_usb     => wdataready_usb1,
              wrready_usb        => wrready_usb,
              wrvalid_usb        => wrvalid_usb1,
              wrsp_usb           => wrsp_usb1,
              raddr_usb          => raddr_usb,
              rlen_usb           => rlen_usb,
              rsize_usb          => rsize_usb,
              rvalid_usb         => rvalid_usb,
              rready_usb         => rready_usb1,
              rdata_usb          => rdata_usb1,
              rstrb_usb          => rstrb_usb1,
              rlast_usb          => rlast_usb1,
              rdvalid_usb        => rdvalid_usb1,
              rdready_usb        => rdready_usb,
              rres_usb           => rres_usb1,
              waddr_audio        => waddr_audio,
              wlen_audio         => wlen_audio,
              wsize_audio        => wsize_audio,
              wvalid_audio       => wvalid_audio,
              wready_audio       => wready_audio1,
              wdata_audio        => wdata_audio,
              wtrb_audio         => wtrb_audio,
              wlast_audio        => wlast_audio,
              wdvalid_audio      => wdvalid_audio,
              wdataready_audio   => wdataready_audio1,
              wrready_audio      => wrready_audio,
              wrvalid_audio      => wrvalid_audio1,
              wrsp_audio         => wrsp_audio1,
              raddr_audio        => raddr_audio,
              rlen_audio         => rlen_audio,
              rsize_audio        => rsize_audio,
              rvalid_audio       => rvalid_audio,
              rready_audio       => rready_audio1,
              rdata_audio        => rdata_audio1,
              rstrb_audio        => rstrb_audio1,
              rlast_audio        => rlast_audio1,
              rdvalid_audio      => rdvalid_audio1,
              rdready_audio      => rdready_audio,
              rres_audio         => rres_audio1,
              up_snp_res_i       => up_snp_res11,
              up_snp_hit_i       => up_snp_hit,
              cache1_req_i       => bus_req11,
              cache2_req_i       => bus_req21,
              pwr_res_i          => ic_pwr_res,
              wb_req1_i          => wb_req1,
              wb_req2_i          => wb_req2,
              pwr_req_full_i     => pwr_req_full,
              full_snp_req1_i    => full_srq1,
              bus_res1_o         => bus_res1,
              bus_res2_o         => bus_res2,
              up_snp_req_o       => up_snp_req,
              full_wb1_o         => full_wb1,
              full_srs1_o        => full_srs1,
              full_wb2_o         => full_wb2,
              --full_mrs_o
  
              pwr_req_o          => ic_pwr_req
          );
  
      gfx_entity : entity work.peripheral(rtl)
          port map(
              Clock        => Clock,
              reset        => reset,
              id_i         => GFX,
              -- write address channel
              waddr_i      => waddr_gfx1,
              wlen_i       => wlen_gfx1,
              wsize_i      => wsize_gfx1,
              wvalid_i     => wvalid_gfx1,
              wready_o     => wready_gfx,
              -- write data channel
              wdata_i      => wdata_gfx1,
              wtrb_i       => wtrb_gfx1,
              wlast_i      => wlast_gfx1,
              wdvalid_i    => wdvalid_gfx1,
              wdataready_o => wdataready_gfx,
              -- write response channel
              wrready_i    => wrready_gfx1,
              wrvalid_o    => wrvalid_gfx,
              wrsp_o       => wrsp_gfx,
              -- read address channel
              raddr_i      => raddr_gfx1,
              rlen_i       => rlen_gfx1,
              rsize_i      => rsize_gfx1,
              rvalid_i     => rvalid_gfx1,
              rready_o     => rready_gfx,
              -- read data channel
              rdata_o      => rdata_gfx,
              rstrb_o      => rstrb_gfx,
              rlast_o      => rlast_gfx,
              rdvalid_o    => rdvalid_gfx,
              rdready_i    => rdready_gfx1,
              rres_o       => rres_gfx,
              -- up snp
              upres_i      => gfx_upres1,
              upreq_o      => gfx_upreq,
              upreq_full_i => gfx_upreq_full,
              -- power
              pwr_req_i    => pwr_gfx_req,
              pwr_res_o    => pwr_gfx_res,
              done_o       => gfx_done
          );
  
      audio_entity : entity work.peripheral(rtl)
          port map(
              Clock        => Clock,
              reset        => reset,
              id_i         => AUDIO,
              -- write address channel
              waddr_i      => waddr_audio1,
              wlen_i       => wlen_audio1,
              wsize_i      => wsize_audio1,
              wvalid_i     => wvalid_audio1,
              wready_o     => wready_audio,
              -- write data channel
              wdata_i      => wdata_audio1,
              wtrb_i       => wtrb_audio1,
              wlast_i      => wlast_audio1,
              wdvalid_i    => wdvalid_audio1,
              wdataready_o => wdataready_audio,
              -- write response channel
              wrready_i    => wrready_audio1,
              wrvalid_o    => wrvalid_audio,
              wrsp_o       => wrsp_audio,
              -- read address channel
              raddr_i      => raddr_audio1,
              rlen_i       => rlen_audio1,
              rsize_i      => rsize_audio1,
              rvalid_i     => rvalid_audio1,
              rready_o     => rready_audio,
              -- read data channel
              rdata_o      => rdata_audio,
              rstrb_o      => rstrb_audio,
              rlast_o      => rlast_audio,
              rdvalid_o    => rdvalid_audio,
              rdready_i    => rdready_audio1,
              rres_o       => rres_audio,
              -- up snp
              upres_i      => audio_upres1,
              upreq_o      => audio_upreq,
              upreq_full_i => audio_upreq_full,
              -- power
              pwr_req_i    => pwr_audio_req,
              pwr_res_o    => pwr_audio_res,
              done_o       => audio_done
          );
  
      usb_entity : entity work.peripheral(rtl)
          port map(
              Clock        => Clock,
              reset        => reset,
              id_i         => USB,
              -- write address channel
              waddr_i      => waddr_usb1,
              wlen_i       => wlen_usb1,
              wsize_i      => wsize_usb1,
              wvalid_i     => wvalid_usb1,
              wready_o     => wready_usb,
              -- write data channel
              wdata_i      => wdata_usb1,
              wtrb_i       => wtrb_usb1,
              wlast_i      => wlast_usb1,
              wdvalid_i    => wdvalid_usb1,
              wdataready_o => wdataready_usb,
              -- write response channel
              wrready_i    => wrready_usb1,
              wrvalid_o    => wrvalid_usb,
              wrsp_o       => wrsp_usb,
              -- read address channel
              raddr_i      => raddr_usb1,
              rlen_i       => rlen_usb1,
              rsize_i      => rsize_usb1,
              rvalid_i     => rvalid_usb1,
              rready_o     => rready_usb,
              -- read data channel
              rdata_o      => rdata_usb,
              rstrb_o      => rstrb_usb,
              rlast_o      => rlast_usb,
              rdvalid_o    => rdvalid_usb,
              rdready_i    => rdready_usb1,
              rres_o       => rres_usb,
              -- up snp
              upres_i      => usb_upres1,
              upreq_o      => usb_upreq,
              upreq_full_i => usb_upreq_full,
              -- power
              pwr_req_i    => pwr_usb_req,
              pwr_res_o    => pwr_usb_res,
              done_o       => usb_done
          );
  
      uart_entity : entity work.peripheral(rtl)
          port map(
              Clock        => Clock,
              reset        => reset,
              id_i         => UART,
              --tx_out       => tx_out,
              --rx_in        => rx_in,
              -- write address channel
              waddr_i      => waddr_uart1,
              wlen_i       => wlen_uart1,
              wsize_i      => wsize_uart1,
              wvalid_i     => wvalid_uart1,
              wready_o     => wready_uart,
              -- write data channel
              wdata_i      => wdata_uart1,
              wtrb_i       => wtrb_uart1,
              wlast_i      => wlast_uart1,
              wdvalid_i    => wdvalid_uart1,
              wdataready_o => wdataready_uart,
              -- write response channel
              wrready_i    => wrready_uart1,
              wrvalid_o    => wrvalid_uart,
              wrsp_o       => wrsp_uart,
              -- read address channel
              raddr_i      => raddr_uart1,
              rlen_i       => rlen_uart1,
              rsize_i      => rsize_uart1,
              rvalid_i     => rvalid_uart1,
              rready_o     => rready_uart,
              -- read data channel
              rdata_o      => rdata_uart,
              rstrb_o      => rstrb_uart,
              rlast_o      => rlast_uart,
              rdvalid_o    => rdvalid_uart,
              rdready_i    => rdready_uart1,
              rres_o       => rres_uart,
              -- up snp
              upres_i      => uart_upres1,
              upreq_o      => uart_upreq,
              upreq_full_i => uart_upreq_full,
              -- power
              pwr_req_i    => pwr_uart_req,
              pwr_res_o    => pwr_uart_res,
              done_o       => uart_done
          );
  
      mem : entity work.Memory(rtl)
          port map(
              Clock        => Clock,
              reset        => reset,
              waddr_i      => waddr1,
              wlen_i       => wlen1,
              wsize_i      => wsize1,
              wvalid_i     => wvalid1,
              wready_o     => wready,
              wdata_i      => wdata1,
              wtrb_i       => wtrb1,
              wlast_i      => wlast1,
              wdvalid_i    => wdvalid1,
              wdataready_o => wdataready,
              wrready_i    => wrready1,
              wrvalid_o    => wrvalid,
              wrsp_o       => wrsp,
              raddr_i      => raddr1,
              rlen_i       => rlen1,
              rsize_i      => rsize1,
              rvalid_i     => rvalid1,
              rready_o     => rready,
              rdata_o      => rdata,
              rstrb_o      => rstrb,
              rlast_o      => rlast,
              rdvalid_o    => rdvalid,
              rdready_i    => rdready1,
              rres_o       => rres
          );
  
      -- -- Clock generation, starts at 0
      tb_clk <= not tb_clk after tb_period/2 when tb_sim_ended /= '1' else '0';
      --tb_clk <= not tb_clk after tb_period/2;
      Clock  <= tb_clk;
  
      logger_p : process(tb_clk)
          file trace_file : TEXT open write_mode is "trace1.txt";
          variable l      : line;
          constant SEP    : String(1 to 1) := ",";
      begin
          if GEN_TRACE1 then
              if rising_edge(tb_clk) then
                  ---- cpu
                  write(l, slv(cpu_req1)); --0
                  write(l, SEP);
                  write(l, slv(cpu_res1)); --1
                  write(l, SEP);
                  write(l, slv(cpu_req2)); --02
                  write(l, SEP);
                  write(l, slv(cpu_res2)); --03
                  write(l, SEP);
  
                  ---- snp
                  write(l, slv(snp_req1)); --04
                  write(l, SEP);
                  write(l, slv(snp_res1)); --05
                  write(l, SEP);
                  write(l, snp_hit1);     --06
                  write(l, SEP);
  
                  write(l, slv(snp_req2)); --07
                  write(l, SEP);
                  write(l, slv(snp_res2)); --08
                  write(l, SEP);
                  write(l, snp_hit2);     --09
                  write(l, SEP);
  
                  ---- up_snp
                  write(l, slv(up_snp_req)); --010
                  write(l, SEP);
                  write(l, slv(up_snp_res)); --011
                  write(l, SEP);
                  write(l, up_snp_hit);   --012
                  write(l, SEP);
  
                  ---- cache_req
                  write(l, slv(bus_req1)); --013
                  write(l, SEP);
                  write(l, slv(bus_res1)); --014
                  write(l, SEP);
  
                  write(l, slv(bus_req2)); --015
                  write(l, SEP);
                  write(l, slv(bus_res2)); --016
                  write(l, SEP);
  
                  ---- ic
                  ---- read
                  write(l, rvalid);       --017
                  write(l, SEP);
                  write(l, raddr);        --018
                  write(l, SEP);
                  write(l, rdvalid);      --019
                  write(l, SEP);
                  write(l, rlast);        --020
                  write(l, SEP);
                  ---- write
                  write(l, wvalid);       --021
                  write(l, SEP);
                  write(l, waddr);        --022
                  write(l, SEP);
                  write(l, wdvalid);      --023
                  write(l, SEP);
                  write(l, wlast);        --024
                  write(l, SEP);
  
                  ---- gfx
                  ---- read
                  write(l, rvalid_gfx);   --025
                  write(l, SEP);
                  write(l, raddr_gfx);    --026
                  write(l, SEP);
                  write(l, rdvalid_gfx);  --027
                  write(l, SEP);
                  write(l, rlast_gfx);    --028
                  write(l, SEP);
                  ---- write
                  write(l, wvalid_gfx);   --029
                  write(l, SEP);
                  write(l, waddr_gfx);    --030
                  write(l, SEP);
                  write(l, wdvalid_gfx);  --031
                  write(l, SEP);
                  write(l, wlast_gfx);    --032
                  write(l, SEP);
  
                  ---- uart
                  ---- read
                  write(l, rvalid_uart);  --33
                  write(l, SEP);
                  write(l, raddr_uart);   --34
                  write(l, SEP);
                  write(l, rdvalid_uart); --35
                  write(l, SEP);
                  write(l, rlast_uart);
                  write(l, SEP);
                  ---- write
                  write(l, wvalid_uart);
                  write(l, SEP);
                  write(l, waddr_uart);
                  write(l, SEP);
                  write(l, wdvalid_uart);
                  write(l, SEP);
                  write(l, wlast_uart);
                  write(l, SEP);
  
                  ---- usb
                  ---- read
                  write(l, rvalid_usb);
                  write(l, SEP);
                  write(l, raddr_usb);
                  write(l, SEP);
                  write(l, rdvalid_usb);
                  write(l, SEP);
                  write(l, rlast_usb);
                  write(l, SEP);
                  ---- write
                  write(l, wvalid_usb);
                  write(l, SEP);
                  write(l, waddr_usb);
                  write(l, SEP);
                  write(l, wdvalid_usb);
                  write(l, SEP);
                  write(l, wlast_usb);
                  write(l, SEP);
  
                  ---- audio
                  ---- read
                  write(l, rvalid_audio);
                  write(l, SEP);
                  write(l, raddr_audio);
                  write(l, SEP);
                  write(l, rdvalid_audio);
                  write(l, SEP);
                  write(l, rlast_audio);
                  write(l, SEP);
                  ---- write
                  write(l, wvalid_audio);
                  write(l, SEP);
                  write(l, waddr_audio);
                  write(l, SEP);
                  write(l, wdvalid_audio);
                  write(l, SEP);
                  write(l, wlast_audio);
                  write(l, SEP);
  
                  -- upreq and upres
                  write(l, slv(gfx_upreq));
                  write(l, SEP);
                  write(l, slv(gfx_upres));
                  write(l, SEP);
  
                  write(l, slv(uart_upreq));
                  write(l, SEP);
                  write(l, slv(uart_upres));
                  write(l, SEP);
  
                  write(l, slv(usb_upreq));
                  write(l, SEP);
                  write(l, slv(usb_upres));
                  write(l, SEP);
  
                  write(l, slv(audio_upreq));
                  write(l, SEP);
                  write(l, slv(audio_upres));
                  write(l, SEP);
  
                  ---- pwr sigs
                  -- from ic
                  write(l, slv(ic_pwr_req));
                  write(l, SEP);
                  write(l, slv(ic_pwr_res));
                  write(l, SEP);
  
                  -- from peripherals
                  write(l, slv(pwr_gfx_req));
                  write(l, SEP);
                  write(l, slv(pwr_gfx_res));
                  write(l, SEP);
  
                  write(l, slv(pwr_uart_req));
                  write(l, SEP);
                  write(l, slv(pwr_uart_res));
                  write(l, SEP);
  
                  write(l, slv(pwr_usb_req));
                  write(l, SEP);
                  write(l, slv(pwr_usb_res));
                  write(l, SEP);
  
                  write(l, slv(pwr_audio_req));
                  write(l, SEP);
                  write(l, slv(pwr_audio_res));
                  write(l, SEP);
                  write(l, mem_rid);---75
                  write(l, SEP);
                  write(l, mem_rtag);---76
                  write(l, SEP);
                  write(l, mem_wid);--77
                  write(l, SEP);
                  write(l, mem_wtag);--78
                                 
                  writeline(trace_file, l);
              end if;
          end if;
      end process;
  

      stimuli : process
      begin
          reset <= '1';
          wait for 15 ps;
          reset <= '0';
          wait until tb_sim_ended = '1';
          report "SIM END";
      end process;
  
      tb_sim_ended <= proc0_done and proc1_done and usb_done and uart_done and gfx_done and audio_done;
  end tb;