library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.util.all;
--use work.rand.all;
use work.test.all;

entity ic is
	Port(
		Clock                                           : in  std_logic;
		reset                                           : in  std_logic;
		cache1_req_i                                    : in  MSG_T;
		cache2_req_i                                    : in  MSG_T;
		wb_req1_i                                       : in  BMSG_T;
		wb_req2_i                                       : in  BMSG_T;
		up_snp_res_i                                    : in  MSG_T;
		up_snp_hit_i                                    : in  std_logic;
		full_snp_req1_i                                 : in  std_logic;
		pwr_res_i                                       : in  MSG_T;
		pwr_req_full_i                                  : in  std_logic;
		bus_res1_o                                      : out BMSG_T;
		bus_res2_o                                      : out BMSG_T;
		up_snp_req_o                                    : out MSG_T;
		full_wb1_o, full_srs1_o, full_wb2_o, full_mrs_o : out std_logic;
		pwr_req_o                                       : out MSG_T;
		gfx_upreq_i                                     : in  MSG_T;
		gfx_upres_o                                     : out MSG_T;
		gfx_upreq_full_o                                : out std_logic;
		audio_upreq_i                                   : in  MSG_T;
		audio_upres_o                                   : out MSG_T;
		audio_upreq_full_o                              : out std_logic;
		usb_upreq_i                                     : in  MSG_T;
		usb_upres_o                                     : out MSG_T;
		usb_upreq_full_o                                : out std_logic;
		uart_upreq_i                                    : in  MSG_T;
		uart_upres_o                                    : out MSG_T;
		uart_upreq_full_o                               : out std_logic;
		full_cache_req1, full_cache_req2: out std_logic;
		mem_rid : out std_logic_vector(7 downto 0);
		mem_rtag: out std_logic_vector(7 downto 0);
		mem_wid : out std_logic_vector(7 downto 0);
        mem_wtag: out std_logic_vector(7 downto 0);		
		full_snpres_o									: out std_logic;
		-- -write address channel
		waddr                                           : out ADR_T;
		wlen                                            : out std_logic_vector(9 downto 0);
		wsize                                           : out std_logic_vector(9 downto 0);
		wvalid                                          : out std_logic;
		wready                                          : in  std_logic;
		-- -write data channel
		wdata                                           : out DAT_T;
		wtrb                                            : out std_logic_vector(3 downto 0);
		wlast                                           : out std_logic;
		wdvalid                                         : out std_logic;
		wdataready                                      : in  std_logic;
		-- -write response channel
		wrready                                         : out std_logic;
		wrvalid_i                                       : in  std_logic;
		wrsp                                            : in  std_logic_vector(1 downto 0);
		-- -read address channel
		raddr                                           : out ADR_T;
		rlen                                            : out std_logic_vector(9 downto 0);
		rsize                                           : out std_logic_vector(9 downto 0);
		rvalid_o                                        : out std_logic;
		rready                                          : in  std_logic;
		-- -read data channel
		rdata                                           : in  DAT_T;
		rstrb                                           : in  std_logic_vector(3 downto 0);
		rlast                                           : in  std_logic;
		rdvalid_i                                       : in  std_logic;
		rdready                                         : out std_logic;
		rres                                            : in  std_logic_vector(1 downto 0);
		-- -usb write address channel
		waddr_usb                                       : out ADR_T;
		wlen_usb                                        : out std_logic_vector(9 downto 0);
		wsize_usb                                       : out std_logic_vector(9 downto 0);
		wvalid_usb                                      : out std_logic;
		wready_usb                                      : in  std_logic;
		-- _usb-write data channel
		wdata_usb                                       : out DAT_T;
		wtrb_usb                                        : out std_logic_vector(3 downto 0);
		wlast_usb                                       : out std_logic;
		wdvalid_usb                                     : out std_logic;
		wdataready_usb                                  : in  std_logic;
		-- _usb-write response channel
		wrready_usb                                     : out std_logic;
		wrvalid_usb                                     : in  std_logic;
		wrsp_usb                                        : in  std_logic_vector(1 downto 0);
		-- _usb-read address channel
		raddr_usb                                       : out ADR_T;
		rlen_usb                                        : out std_logic_vector(9 downto 0);
		rsize_usb                                       : out std_logic_vector(9 downto 0);
		rvalid_usb                                      : out std_logic;
		rready_usb                                      : in  std_logic;
		-- _usb-read data channel
		rdata_usb                                       : in  DAT_T;
		rstrb_usb                                       : in  std_logic_vector(3 downto 0);
		rlast_usb                                       : in  std_logic;
		rdvalid_usb                                     : in  std_logic;
		rdready_usb                                     : out std_logic;
		rres_usb                                        : in  std_logic_vector(1 downto 0);
		-- -gfx write address channel
		waddr_gfx                                       : out ADR_T;
		wlen_gfx                                        : out std_logic_vector(9 downto 0);
		wsize_gfx                                       : out std_logic_vector(9 downto 0);
		wvalid_gfx                                      : out std_logic;
		wready_gfx                                      : in  std_logic;
		-- _gfx-write data channel
		wdata_gfx                                       : out DAT_T;
		wtrb_gfx                                        : out std_logic_vector(3 downto 0);
		wlast_gfx                                       : out std_logic;
		wdvalid_gfx                                     : out std_logic;
		wdataready_gfx                                  : in  std_logic;
		-- _gfx-write response channel
		wrready_gfx                                     : out std_logic;
		wrvalid_gfx                                     : in  std_logic;
		wrsp_gfx                                        : in  std_logic_vector(1 downto 0);
		-- _gfx-read address channel
		raddr_gfx                                       : out ADR_T;
		rlen_gfx                                        : out std_logic_vector(9 downto 0);
		rsize_gfx                                       : out std_logic_vector(9 downto 0);
		rvalid_gfx                                      : out std_logic;
		rready_gfx                                      : in  std_logic;
		-- _gfx-read data channel
		rdata_gfx                                       : in  DAT_T;
		rstrb_gfx                                       : in  std_logic_vector(3 downto 0);
		rlast_gfx                                       : in  std_logic;
		rdvalid_gfx                                     : in  std_logic;
		rdready_gfx                                     : out std_logic;
		rres_gfx                                        : in  std_logic_vector(1 downto 0);
		-- -uart write address channel
		waddr_uart                                      : out ADR_T;
		wlen_uart                                       : out std_logic_vector(9 downto 0);
		wsize_uart                                      : out std_logic_vector(9 downto 0);
		wvalid_uart                                     : out std_logic;
		wready_uart                                     : in  std_logic;
		-- _uart-write data channel
		wdata_uart                                      : out DAT_T;
		wtrb_uart                                       : out std_logic_vector(3 downto 0);
		wlast_uart                                      : out std_logic;
		wdvalid_uart                                    : out std_logic;
		wdataready_uart                                 : in  std_logic;
		-- _uart-write response channel
		wrready_uart                                    : out std_logic;
		wrvalid_uart                                    : in  std_logic;
		wrsp_uart                                       : in  std_logic_vector(1 downto 0);
		-- _uart-read address channel
		raddr_uart                                      : out ADR_T;
		rlen_uart                                       : out std_logic_vector(9 downto 0);
		rsize_uart                                      : out std_logic_vector(9 downto 0);
		rvalid_uart                                     : out std_logic;
		rready_uart                                     : in  std_logic;
		-- _uart-read data channel
		rdata_uart                                      : in  DAT_T;
		rstrb_uart                                      : in  std_logic_vector(3 downto 0);
		rlast_uart                                      : in  std_logic;
		rdvalid_uart                                    : in  std_logic;
		rdready_uart                                    : out std_logic;
		rres_uart                                       : in  std_logic_vector(1 downto 0);
		-- -audio write address channel
		waddr_audio                                     : out ADR_T;
		wlen_audio                                      : out std_logic_vector(9 downto 0);
		wsize_audio                                     : out std_logic_vector(9 downto 0);
		wvalid_audio                                    : out std_logic;
		wready_audio                                    : in  std_logic;
		-- _audio-write data channel
		wdata_audio                                     : out DAT_T;
		wtrb_audio                                      : out std_logic_vector(3 downto 0);
		wlast_audio                                     : out std_logic;
		wdvalid_audio                                   : out std_logic;
		wdataready_audio                                : in  std_logic;
		-- _audio-write response channel
		wrready_audio                                   : out std_logic;
		wrvalid_audio                                   : in  std_logic;
		wrsp_audio                                      : in  std_logic_vector(1 downto 0);
		-- _audio-read address channel
		raddr_audio                                     : out ADR_T;
		rlen_audio                                      : out std_logic_vector(9 downto 0);
		rsize_audio                                     : out std_logic_vector(9 downto 0);
		rvalid_audio                                    : out std_logic;
		rready_audio                                    : in  std_logic;
		-- _audio-read data channel
		rdata_audio                                     : in  DAT_T;
		rstrb_audio                                     : in  std_logic_vector(3 downto 0);
		rlast_audio                                     : in  std_logic;
		rdvalid_audio                                   : in  std_logic;
		rdready_audio                                   : out std_logic;
		rres_audio                                      : in  std_logic_vector(1 downto 0);
		snp_req_full_i: in std_logic
	);
end ic;

architecture rtl of ic is
	-- fifo has 53 bits
	-- 3 bits for indicating its source¡
	-- 50 bits for packet

	signal pwr_res1_s, pwr_res2_s         : BMSG_T;
	signal pwr_res1_ack_s, pwr_res2_ack_s : std_logic;

	signal in6, in7, out6, out7 : BMSG_T;

	signal in2, out2                    : SNP_RES_T;
	signal we2, we6,we17,re17, we7, re7, re2, re6 : std_logic := '0';
	signal emp2, emp6, emp7, ful2 ,emp17      : std_logic := '0';

	signal bus_res_mem_to_c0, bus_res_gfx_to_c0, bus_res_mem_to_c1, bus_res2_2 : BMSG_T;
	signal mem_ack1, mem_ack2, brs1_ack1, brs1_ack2, brs2_ack1, brs2_ack2      : std_logic;
	signal mem_ack, mem_ack3, mem_ack4, mem_ack5, mem_ack6                     : std_logic;

	signal tomem1, tomem2, tomem3, tomem4, tomem5, tomem6 : MSG_T := ZERO_MSG;

	signal wb_ack1, wb_ack2 : std_logic;
	signal mem_wb1, mem_wb2 : BMSG_T := ZERO_BMSG;
	-- state information of power
	signal gfxpoweron : std_logic := '0';

	signal adr_1              : ADR_T;
	signal tmp_sp1, tmp_sp2   : MSG_T;
	signal pwr_req1, pwr_req2 : MSG_T;
	-- (9 bits)
	signal pwr_ack1, pwr_ack2                             : std_logic;
	signal mem_wb, gfx_wb, audio_wb, usb_wb, uart_wb      : BMSG_T;
	signal tomem_p, togfx_p, touart_p, tousb_p, toaudio_p : MSG_T;

	signal gfx_fifo_din, gfx_fifo_dout                                                                        : MSG_T;
	signal in13, out13, in14, out14, in15, out15 , in16,out16   ,in17,out17                                                          : MSG_T;
	signal in8, out8, in10, out10, in11, out11, in12, out12                                                   : MSG_t;
	signal we8, re8, gfx_fifo_re, we9, re10, we10, re11, we11, re12, we12, re13, we13, re14, we14, re15, we15,re16,we16 : std_logic := '0';
	signal emp8, gfx_fifo_emp, emp10, emp11, emp12, emp13, emp14, emp15 ,emp16                                      : std_logic := '0';

	signal bus_res1_3, bus_res2_3, bus_res1_4, bus_res1_5, bus_res1_7, bus_res2_4, bus_res2_5, bus_res1_6, bus_res2_6 : BMSG_T;

	signal gfx_ack1, gfx_ack2, audio_ack1, audio_ack2, usb_ack1, usb_ack2, uart_ack1                                    : std_logic;
	signal gfx_ack3, gfx_ack4, gfx_ack5, gfx_ack6, gfx_ack, usb_ack, uart_ack, audio_ack                                : std_logic;
	signal uart_ack3, uart_ack4, uart_ack5, uart_ack6                                                                   : std_logic;
	signal usb_ack3, usb_ack4, usb_ack5, usb_ack6                                                                       : std_logic;
	signal audio_ack3, audio_ack4, audio_ack5, audio_ack6                                                               : std_logic;
	signal uart_ack2, brs1_ack3, brs2_ack3, brs1_ack4, brs1_ack5, brs1_ack6, brs1_ack7, brs2_ack5, brs2_ack4, brs2_ack6 : std_logic;
	signal togfx1, togfx2, togfx3       -- , togfx4, togfx5, togfx6
	                                                    : MSG_T := ZERO_MSG;
	signal toaudio1, toaudio2, toaudio3, toaudio4, toaudio5, toaudio6                                                   : MSG_T := ZERO_MSG;
	signal tousb1, tousb2, tousb3, tousb4, tousb5, tousb6                                                               : MSG_T := ZERO_MSG;
	signal touart1, touart2, touart3, touart4, touart5, touart6                                                         : MSG_T := ZERO_MSG;

	signal gfx_wb_ack1, gfx_wb_ack2, audio_wb_ack1, audio_wb_ack2, usb_wb_ack1, usb_wb_ack2, uart_wb_ack1, uart_wb_ack2 : std_logic;
	signal gfx_wb1, gfx_wb2, audio_wb1, audio_wb2, usb_wb1, usb_wb2, uart_wb1, uart_wb2                                 : BMSG_T := ZERO_BMSG;
	-- state information of power
	signal audiopoweron : std_logic := '0';
	signal usbpoweron   : std_logic := '0';
	signal uartpoweron  : std_logic := '0';

	-- signal pwr_req3, pwr_req4, pwr_req5, pwr_req6 : std_logic_vector(4 downto 0);
	-- signal pwr_ack3, pwr_ack4, pwr_ack5, pwr_ack6 : std_logic;

	signal snp1_1, snp1_2, snp1_3, snp1_4, snp1_5, snp1_6, snp2_1, snp2_2, snp2_3, snp2_4, snp2_5, snp2_6                                     : MSG_T;
	signal snp1_ack1, snp1_ack2, snp1_ack3, snp1_ack4, snp1_ack5, snp1_ack6, snp2_ack1, snp2_ack2, snp2_ack3, snp2_ack4, snp2_ack5, snp2_ack6 : std_logic;

	signal gfx_upres1, gfx_upres2, gfx_upres3                   : MSG_T;
	signal gfx_upres_ack1, gfx_upres_ack2, gfx_upres_ack3       : std_logic;
	signal audio_upres1, audio_upres2, audio_upres3             : MSG_T;
	signal audio_upres_ack1, audio_upres_ack2, audio_upres_ack3 : std_logic;
	signal usb_upres1, usb_upres2, usb_upres3                   : MSG_T;
	signal usb_upres_ack1, usb_upres_ack2, usb_upres_ack3       : std_logic;
	signal uart_upres1, uart_upres2, uart_upres3                : MSG_T;
	signal uart_upres_ack1, uart_upres_ack2, uart_upres_ack3    : std_logic;
	signal gfx_upres4, gfx_upres5, gfx_upres6                   : MSG_T;
	signal gfx_upres_ack4, gfx_upres_ack5, gfx_upres_ack6       : std_logic;
	signal audio_upres4, audio_upres5, audio_upres6             : MSG_T;
	signal audio_upres_ack4, audio_upres_ack5, audio_upres_ack6 : std_logic;
	signal usb_upres4, usb_upres5, usb_upres6                   : MSG_T;
	signal usb_upres_ack4, usb_upres_ack5, usb_upres_ack6       : std_logic;
	signal uart_upres4, uart_upres5, uart_upres6                : MSG_T;
	signal uart_upres_ack4, uart_upres_ack5, uart_upres_ack6    : std_logic;

	signal gfx_write1, mem_write1, usb_write1, uart_write1, audio_write1                                                                : MSG_T;
	signal mem_write2, mem_write3, gfx_write2, gfx_write3, usb_write2, usb_write3, uart_write2, uart_write3, audio_write2, audio_write3 : BMSG_T;
	signal mem_write_ack1, gfx_write_ack1, usb_write_ack1, uart_write_ack1, audio_write_ack1                                            : std_logic;
	signal mem_write_ack2, gfx_write_ack2, usb_write_ack2, uart_write_ack2, audio_write_ack2                                            : std_logic;
	signal mem_write_ack3, gfx_write_ack3, usb_write_ack3, uart_write_ack3, audio_write_ack3                                            : std_logic;

	signal tmp_cache_req1, tmp_cache_req2 : MSG_T;
    signal emp_full:std_logic;
    
    signal test_v:std_logic;
    signal test_cmd:std_logic_vector(7 downto 0);
begin
	togfx_chan_p : entity work.toper_chan_m(rtl)
		port map(
			clock             => Clock,
			reset             => reset,
			-- read address channel
			raddr_o           => raddr_gfx,
			rlen_o            => rlen_gfx,
			rsize_o           => rsize_gfx,
			rvalid_o          => rvalid_gfx,
			rready_i          => rready_gfx,
			-- read data channel
			rdata_i           => rdata_gfx,
			rstrb_i           => rstrb_gfx,
			rlast_i           => rlast_gfx,
			rdvalid_i         => rdvalid_gfx,
			rdready_o         => rdready_gfx,
			rres_i            => rres_gfx,
			bus_res_c0_ack_i  => brs1_ack2,
			bus_res_c1_ack_i  => brs2_ack2,
			toper_i           => togfx_p,
			bus_res_c0_o      => bus_res_gfx_to_c0,
			bus_res_c1_o      => bus_res2_2,
			gfx_upres_ack_i   => '0',
			usb_upres_ack_i   => usb_upres_ack2,
			uart_upres_ack_i  => uart_upres_ack2,
			audio_upres_ack_i => audio_upres_ack2,
			-- gfx_upres_o => gfx_upres2,
			usb_upres_o       => usb_upres2,
			uart_upres_o      => uart_upres2,
			audio_upres_o     => audio_upres2,
			per_write_o       => gfx_write1,
			per_write_ack_i   => gfx_write_ack1,
			per_ack_o         => gfx_ack
		);

	tousb_chan_p : entity work.toper_chan_m(rtl)
		port map(
			clock             => Clock,
			reset             => reset,
			-- read address channel
			raddr_o           => raddr_usb,
			rlen_o            => rlen_usb,
			rsize_o           => rsize_usb,
			rvalid_o          => rvalid_usb,
			rready_i          => rready_usb,
			-- read data channel
			rdata_i           => rdata_usb,
			rstrb_i           => rstrb_usb,
			rlast_i           => rlast_usb,
			rdvalid_i         => rdvalid_usb,
			rdready_o         => rdready_usb,
			rres_i            => rres_usb,
			bus_res_c0_ack_i  => brs1_ack4,
			bus_res_c1_ack_i  => brs2_ack4,
			toper_i           => tousb_p,
			bus_res_c0_o      => bus_res1_4,
			bus_res_c1_o      => bus_res2_4,
			gfx_upres_ack_i   => gfx_upres_ack4,
			usb_upres_ack_i   => '0',
			uart_upres_ack_i  => uart_upres_ack4,
			audio_upres_ack_i => audio_upres_ack4,
			gfx_upres_o       => gfx_upres4,
			-- usb_upres_o => usb_upres4,
			uart_upres_o      => uart_upres4,
			audio_upres_o     => audio_upres4,
			per_write_o       => usb_write1,
			per_write_ack_i   => usb_write_ack1,
			per_ack_o         => usb_ack
		);

	toaudio_chan_p : entity work.toper_chan_m(rtl)
		port map(
			clock             => Clock,
			reset             => reset,
			-- read address channel
			raddr_o           => raddr_audio,
			rlen_o            => rlen_audio,
			rsize_o           => rsize_audio,
			rvalid_o          => rvalid_audio,
			rready_i          => rready_audio,
			-- read data channel
			rdata_i           => rdata_audio,
			rstrb_i           => rstrb_audio,
			rlast_i           => rlast_audio,
			rdvalid_i         => rdvalid_audio,
			rdready_o         => rdready_audio,
			rres_i            => rres_audio,
			bus_res_c0_ack_i  => brs1_ack2,
			bus_res_c1_ack_i  => brs2_ack2,
			toper_i           => toaudio_p,
			bus_res_c0_o      => bus_res1_5,
			bus_res_c1_o      => bus_res2_5,
			gfx_upres_ack_i   => '0',
			usb_upres_ack_i   => usb_upres_ack5,
			uart_upres_ack_i  => uart_upres_ack5,
			audio_upres_ack_i => audio_upres_ack5,
			gfx_upres_o       => gfx_upres5,
			usb_upres_o       => usb_upres5,
			uart_upres_o      => uart_upres5,
			-- audio_upres_o => audio_upres5,

			per_write_o       => audio_write1,
			per_write_ack_i   => audio_write_ack1,
			per_ack_o         => audio_ack
		);

	touart_chan_p : entity work.toper_chan_m(rtl)
		port map(
			clock             => Clock,
			reset             => reset,
			-- read address channel
			raddr_o           => raddr_uart,
			rlen_o            => rlen_uart,
			rsize_o           => rsize_uart,
			rvalid_o          => rvalid_uart,
			rready_i          => rready_uart,
			-- read data channel
			rdata_i           => rdata_uart,
			rstrb_i           => rstrb_uart,
			rlast_i           => rlast_uart,
			rdvalid_i         => rdvalid_uart,
			rdready_o         => rdready_uart,
			rres_i            => rres_uart,
			bus_res_c0_ack_i  => brs1_ack3,
			bus_res_c1_ack_i  => brs2_ack3,
			toper_i           => touart_p,
			bus_res_c0_o      => bus_res1_3,
			bus_res_c1_o      => bus_res2_3,
			gfx_upres_ack_i   => gfx_upres_ack3,
			usb_upres_ack_i   => usb_upres_ack3,
			uart_upres_ack_i  => '0',
			audio_upres_ack_i => audio_upres_ack4,
			gfx_upres_o       => gfx_upres3,
			usb_upres_o       => usb_upres3,
			-- uart_upres_o => uart_upres3,
			audio_upres_o     => audio_upres3,
			per_write_o       => uart_write1,
			per_write_ack_i   => uart_write_ack1,
			per_ack_o         => uart_ack
		);

	wb_fifo1 : entity work.b_fifo(rtl)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in6,
			WriteEn => we6,
			ReadEn  => re6,
			DataOut => out6,
			Full    => full_wb1_o,
			Empty   => emp6
		);
	wb_fifo2 : entity work.b_fifo(rtl)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in7,
			WriteEn => we7,
			ReadEn  => re7,
			DataOut => out7,
			Full    => full_wb2_o,
			Empty   => emp7
		);

	gfx_fifo : entity work.fifo(rtl)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => gfx_fifo_din,
			WriteEn => we9,
			ReadEn  => gfx_fifo_re,
			DataOut => gfx_fifo_dout,
			Full    => gfx_upreq_full_o,
			Empty   => gfx_fifo_emp
		);
	gfx_upreq_m : entity work.per_upreq_m(rtl)
		port map(
			clock        => clock,
			reset        => reset,
			tag_i        => GFX_TAG,
			fifo_re_io   => gfx_fifo_re,
			fifo_empty_i => gfx_fifo_emp,
			fifo_dat_i   => gfx_fifo_dout,
			req_o        => snp1_2,
			req_ack_i    => snp1_ack2
		);

  gfx_fifo_p : entity work.msg_fifo_m(rtl)
    port map (
      clock => clock,
      reset => reset,
      data_i => gfx_upreq_i,
      tofifo_o => gfx_fifo_din,
      we_o => we9
      );

	usb_fifo : entity work.fifo(rtl)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in14,
			WriteEn => we14,
			ReadEn  => re14,
			DataOut => out14,
			Full    => usb_upreq_full_o,
			Empty   => emp14
		);
	cache0_req_fifo: entity work.fifo(rtl)
	  
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in16,
			WriteEn => we16,
			ReadEn  => re16,
			DataOut => out16,
			Full    => full_cache_req1,
			Empty   => emp16
		);
	cache1_req_fifo: entity work.fifo(rtl)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in17,
			WriteEn => we17,
			ReadEn  => re17,
			DataOut => out17,
			Full    => full_cache_req2,
			Empty   => emp17
		);
	usb_upreq_m : entity work.per_upreq_m(rtl)
		port map(
			clock        => clock,
			reset        => reset,
			tag_i        => USB_TAG,
			fifo_re_io   => re14,
			fifo_empty_i => emp14,
			fifo_dat_i   => out14,
			req_o        => snp1_4,
			req_ack_i    => snp1_ack4
		);

  usb_fifo_p : entity work.msg_fifo_m(rtl)
    port map (
      clock => clock,
      reset => reset,
      data_i => usb_upreq_i,
      tofifo_o => in14,
      we_o => we14
      );

  c0_req_fifo_p : entity work.msg_fifo_m(rtl)
    port map (
      clock => clock,
      reset => reset,
      data_i => cache1_req_i,
      tofifo_o => in16,
      we_o => we16
      );

  c1_req_fifo_p : entity work.msg_fifo_m(rtl)
    port map (
      clock => clock,
      reset => reset,
      data_i => cache2_req_i,
      tofifo_o => in17,
      we_o => we17
      );
  
	snp_res_fifo : entity work.fifo_snp(rtl)
	generic map(
                FIFO_DEPTH => 32
            )
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in2,
			WriteEn => we2,
			ReadEn  => re2,
			DataOut => out2,
			Full    => full_snpres_o,
			Empty   => emp2
		);

	audio_fifo : entity work.fifo(rtl)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in13,
			WriteEn => we13,
			ReadEn  => re13,
			DataOut => out13,
			Full    => audio_upreq_full_o,
			Empty   => emp13
		);

  audio_fifo_p : entity work.msg_fifo_m(rtl)
    port map (
      clock => clock,
      reset => reset,
      data_i => audio_upreq_i,
      tofifo_o => in13,
      we_o => we13
      );

	uart_fifo : entity work.fifo(rtl)
		port map(
			CLK     => Clock,
			RST     => reset,
			DataIn  => in15,
			WriteEn => we15,
			ReadEn  => re15,
			DataOut => out15,
			Full    => uart_upreq_full_o,
			Empty   => emp15
		);

  uart_fifo_p : entity work.msg_fifo_m(rtl)
    port map (
      clock => clock,
      reset => reset,
      data_i => uart_upreq_i,
      tofifo_o => in15,
      we_o => we15
      );
  
	audio_upreq_m : entity work.per_upreq_m(rtl)
		port map(
			clock        => clock,
			reset        => reset,
			tag_i        => AUDIO_TAG,
			fifo_re_io   => re13,
			fifo_empty_i => emp13,
			fifo_dat_i   => out13,
			req_o        => snp1_3,
			req_ack_i    => snp1_ack3
		);

	
	uart_upreq_m : entity work.per_upreq_m(rtl)
		port map(
			clock        => clock,
			reset        => reset,
			tag_i        => UART_TAG,
			fifo_re_io   => re15,
			fifo_empty_i => emp15,
			fifo_dat_i   => out15,
			req_o        => snp1_5,
			req_ack_i    => snp1_ack5
		);

	tomem_arbiter : entity work.arbiter6_ack(rtl)
		port map(
			clock  => Clock,
			reset  => reset,
			din1   => tomem1,
			ack1_o => mem_ack1,
			din2   => tomem2,
			ack2_o => mem_ack2,
			din3   => tomem3,
			ack3_o => mem_ack3,
			din4   => tomem4,
			ack4_o => mem_ack4,
			din5   => tomem5,
			ack5_o => mem_ack5,
			din6   => tomem6,
			ack6_o => mem_ack6,
			dout   => tomem_p,
			ack_i  => mem_ack
		);

	tomem_chan_p : process( Clock)
		variable tdata   : std_logic_vector(511 downto 0) := (others => '0');
		variable sdata   : std_logic_vector(31 downto 0)  := (others => '0');
		variable state   : integer                        := 0;
		variable prev_st : integer                        := -1;
		variable lp      : integer                        := 0;
		variable tep_mem : MSG_T;
		variable nullreq : BMSG_T                         := ZERO_BMSG;
		variable slot    : integer;
	begin
		if rising_edge(Clock) then
			-- dbg_chg("tomem_chan_p", state, prev_st);
			test_v<=tomem_p.val;
			test_cmd<=tomem_p.cmd;
			if reset = '1' then
                        rvalid_o <= '0';
                        rdready  <= '0';
                        state    := 0;
                    elsif state = 0 then
				mem_ack           <= '0';
				bus_res_mem_to_c0 <= nullreq;
				bus_res_mem_to_c1 <= nullreq;
				gfx_upres1        <= ZERO_MSG;
				uart_upres1       <= ZERO_MSG;
				audio_upres1      <= ZERO_MSG;
				usb_upres1        <= ZERO_MSG;
				--report "00";
				if tomem_p.val = '1' and (tomem_p.cmd = READ_CMD or tomem_p.tag=CPU0_TAG or tomem_p.tag=CPU1_TAG) then
					tep_mem := tomem_p;
					state   := 16;
					--report "read )::::::::::::::::::::::::::::::tomemp i's ag info: " & integer'image(to_integer(unsigned(tomem_p.tag)));
          
        			elsif tomem_p.val = '1' and tomem_p.cmd = WRITE_CMD then
					-- if (dst_eq(tomem_p, GFX_TAG) or
					-- dst_eq(tomem_p, USB_TAG)  or
					-- dst_eq(tomem_p, UART_TAG)  or
					-- dst_eq(tomem_p, AUDIO_TAG)) then
					mem_write1 <= tomem_p;
					state      := 9;
					--report "write)::::::::::::::::::::::::::::::tomemp's tag info: " & integer'image(to_integer(unsigned(tomem_p.tag)));
				elsif tomem_p.val='1' then
					--report "something is wrong";
					
				-- tep_mem := tomem_p;
				-- state   := 6;
				-- end if;
				end if;

			elsif state = 16 then
				if rready = '1' then
					-- mem_ack <= '0';
					--report "state 16 of mem read";
					mem_rid <= tep_mem.id;
					mem_rtag <= tep_mem.tag;
					rvalid_o <= '1';
					raddr    <= tep_mem.adr;
					slot     := to_integer(unsigned(tep_mem.adr(3 downto 0)));
					if (tep_mem.tag = CPU0_TAG or tep_mem.tag = CPU1_TAG) then
						rlen <= "00000" & "10000";
					else
						rlen <= "00000" & "00001";
					end if;
					rsize    <= "00001" & "00000";
					state    := 1;
				end if;
			elsif state = 1 then
				rvalid_o <= '0';
				rdready  <= '1';
				state    := 2;
			elsif state = 2 then
				if rdvalid_i = '1' and rres = "00" then
					if (tep_mem.tag = CPU0_TAG or tep_mem.tag = CPU1_TAG) then
						rdready <= '0';
						if lp = slot and tep_mem.cmd = WRITE_CMD then
							tdata(lp * 32 + 31 downto lp * 32) := tep_mem.dat;
						else
							tdata(lp * 32 + 31 downto lp * 32) := rdata;
						end if;
						lp      := lp + 1;
						if rlast = '1' or lp= 16 then
							state := 3;
							lp    := 0;
						end if;
						rdready <= '1';
					else
						rdready <= '1';
						sdata   := rdata;
						rdready <= '1';
						state   := 3;
					end if;

				end if;
			elsif state = 3 then
				-- mem_ack <= '1';
				if tep_mem.tag = CPU0_TAG then
					bus_res_mem_to_c0 <= (tep_mem.val, tep_mem.cmd, tep_mem.tag,
					                      tep_mem.id, tep_mem.adr, tdata);
					state             := 4;
				elsif tep_mem.tag = CPU1_TAG then
					bus_res_mem_to_c1 <= (tep_mem.val, tep_mem.cmd, tep_mem.tag,
					                      tep_mem.id, tep_mem.adr, tdata);
					state             := 4;
				elsif tep_mem.tag = GFX_TAG then
					gfx_upres1 <= (tep_mem.val, tep_mem.cmd, tep_mem.tag,
					               tep_mem.id, tep_mem.adr, sdata);
					state      := 5;
				elsif tep_mem.tag = UART_TAG then
					uart_upres1 <= (tep_mem.val, tep_mem.cmd, tep_mem.tag,
					                tep_mem.id, tep_mem.adr, sdata);
					state       := 6;
				elsif tep_mem.tag = USB_TAG then
					usb_upres1 <= (tep_mem.val, tep_mem.cmd, tep_mem.tag,
					               tep_mem.id, tep_mem.adr, sdata);
					state      := 7;
				elsif tep_mem.tag = AUDIO_TAG then
					audio_upres1 <= (tep_mem.val, tep_mem.cmd, tep_mem.tag,
					                 tep_mem.id, tep_mem.adr, sdata);
					state        := 8;
				end if;
				--report "3";
			elsif state = 4 then
				--report "4";
				-- -TODO need to add for other pheripharals => .!!!!!!
				if brs2_ack1 = '1' then
					bus_res_mem_to_c1 <= nullreq;
					state             := 0;
					mem_ack           <= '1';
					
				elsif brs1_ack1 = '1' then
					bus_res_mem_to_c0 <= nullreq;
					state             := 0;
					mem_ack           <= '1';
					
				end if;
			elsif state = 5 then
				if gfx_upres_ack1 = '1' then
					--report "5";
					gfx_upres1 <= ZERO_MSG;
					state      := 0;
					mem_ack    <= '1';
				end if;
			elsif state = 6 then
				if uart_upres_ack1 = '1' then
					uart_upres1 <= ZERO_MSG;
					state       := 0;
					mem_ack     <= '1';
					--report "6";
				end if;
			elsif state = 7 then
				if usb_upres_ack1 = '1' then
					usb_upres1 <= ZERO_MSG;
					state      := 0;
					mem_ack    <= '1';
					--report "7";
				end if;
			elsif state = 8 then
				if audio_upres_ack1 = '1' then
					audio_upres1 <= ZERO_MSG;
					state        := 0;
					mem_ack      <= '1';
					--report "8";
				end if;
			elsif state = 9 then
				if mem_write_ack1 = '1' then
					-- dbg(mem_write1);
					-- --report "state 9 of mem write, mem ack1 is set, now the mem write should be empty";
					-- --report "mem_ack1's tag info: "& integer'image(to_integer(unsigned(mem_write1.tag)));
					if mem_write1.tag = CPU0_TAG then
						bus_res_mem_to_c0 <= (mem_write1.val, mem_write1.cmd, mem_write1.tag,
						                      mem_write1.id, mem_write1.adr, tdata);
						state             := 4;
					elsif mem_write1.tag = CPU1_TAG then
						bus_res_mem_to_c1 <= (mem_write1.val, mem_write1.cmd, mem_write1.tag,
						                      mem_write1.id, mem_write1.adr, tdata);
						state             := 4;
					elsif mem_write1.tag = GFX_TAG then
						gfx_upres1 <= (mem_write1.val, mem_write1.cmd, mem_write1.tag,
						               mem_write1.id, mem_write1.adr, sdata);
						state      := 5;
					elsif mem_write1.tag = UART_TAG then
						uart_upres1 <= (mem_write1.val, mem_write1.cmd, mem_write1.tag,
						                mem_write1.id, mem_write1.adr, sdata);
						state       := 6;
					elsif mem_write1.tag = USB_TAG then
						usb_upres1 <= (mem_write1.val, mem_write1.cmd, mem_write1.tag,
						               mem_write1.id, mem_write1.adr, sdata);
						state      := 7;
					elsif mem_write1.tag = AUDIO_TAG then
						audio_upres1 <= (mem_write1.val, mem_write1.cmd, mem_write1.tag,
						                 mem_write1.id, mem_write1.adr, sdata);
						state        := 8;
					end if;
					mem_write1 <= ZERO_MSG;
				end if;
			end if;
		end if;
	end process;

	togfx_arbiter : entity work.arbiter6_ack(rtl)
		port map(
			clock  => Clock,
			reset  => reset,
			din1   => togfx1,           -- dn from cache 0
			ack1_o => gfx_ack1,
			din2   => togfx2,           -- dn from cache 1
			ack2_o => gfx_ack2,
			din3   => togfx3,           -- up response 
			ack3_o => gfx_ack3,
			-- NOT IMPLEMENTED:
			din4   => ZERO_MSG,         -- togfx4,
			-- ack4_o  => gfx_ack4,
			din5   => ZERO_MSG,         -- togfx5,
			-- ack5_o  => gfx_ack5,
			din6   => ZERO_MSG,         -- togfx6,
			-- ack6_o  => gfx_ack6,

			dout   => togfx_p,
			ack_i  => gfx_ack
		);

	mem_write_p : process(Clock)
		variable state         : integer := 0;
		variable prev_st       : integer := -1;
		variable tep_mem       : MSG_T;
		variable tep_mem_l     : BMSG_T;
		variable flag          : std_logic;
		variable tdata         : std_logic_vector(511 downto 0);
		variable lp            : integer := 0;
		constant MEMOP_TIMEOUT : integer := 10;
		variable timeout_cnt   : integer := 0;
	-- -- if flag is 1, then return mem write 2
	begin
		if rising_edge(Clock) then
        mem_wid <= tep_mem.id;
        mem_wtag<= tep_mem.tag;
		if reset = '1' then
			flag := '0';
		elsif state = 0 then
				lp             := 0;
				mem_write_ack1 <= '0';
				mem_write_ack2 <= '0';
				mem_write_ack3 <= '0';
                
				if mem_write1.val = '1' then
					-- --report "state 0 of mem write";
					state   := 1;
					tep_mem := mem_write1;
				elsif mem_write2.val = '1' then
					state     := 4;
					tep_mem_l := mem_write2;
					flag      := '1';
				elsif mem_write3.val = '1' then
					state     := 4;
					tep_mem_l := mem_write3;
					flag      := '0';
				end if;
				
			elsif state = 1 then
				if wready = '1' then    -- MERGE durw: [1/0]
					wvalid <= '1';
					waddr  <= tep_mem.adr;
					wlen   <= "00000" & "00001"; -- MERGE durw: [10000/00001]
					wsize  <= "00001" & "00000";
					
					-- wdata_audio := tep_mem.dat;
					state := 2;
				else
					timeout_cnt := timeout_cnt + 1;
				end if;
				
			elsif state = 2 then
				wvalid <= '0';          -- MERGE durw: [*/]
				if wdataready = '1' then
					wdvalid <= '1';
					wtrb    <= "0001";  -- MERGE durw: [1111/0001]
					wdata   <= tep_mem.dat;
					wlast   <= '1';
					state   := 3;
				end if;

			elsif state = 3 then
				wdvalid <= '0';
				wrready <= '1';
				if wrvalid_i = '1' then
					-- if wrsp = "00" then
					state          := 7;
					mem_write_ack1 <= '1';
					-- -this is a successful write back, yayyy
					-- --report "state 3 of mem write";
					-- end if;
					wrready <= '0';
				else
					timeout_cnt := timeout_cnt + 1;
				end if;
				
			elsif state = 4 then
				if wready = '1' then    -- MERGE durw: [1/0]
					wvalid <= '1';
					waddr  <= mem_wb.adr;
					wlen   <= "00000" & "10000";
					wsize  <= "00001" & "00000";
					tdata  := tep_mem_l.dat;
					state  := 5;
				end if;
			elsif state = 5 then
				if wdataready = '1' then
					wdvalid <= '1';
					wtrb    <= "1111";
					wdata   <= tdata(lp + 31 downto lp);
					lp      := lp + 32;
					if lp = 512 then
						wlast <= '1';
						state := 6;
						lp    := 0;
					end if;
				end if;
			elsif state = 7 then
				state := 0;
			elsif state = 6 then
				wdvalid <= '0';
				wrready <= '1';
				if wrvalid_i = '1' then
					state := 0;
					if wrsp = "00" then
						-- -this is a successful write back, yayyy
						if flag = '1' then
							mem_write_ack2 <= '1';
						else
							mem_write_ack3 <= '1';
						end if;
					end if;
					-- --report "state 6 of mem write";
					wrready <= '0';
				end if;
			-- elsif state = 7 then -- fwd resp to bus_res1_arbitor
			-- dbg(tep_mem);
			-- if tep_mem(75 downto 72) = ip_enc(CPU0) then
			-- bus_res_mem_to_c0 <= rpad(tep_mem(72 downto 0));
			-- state := 4;
			-- end if;
			end if;
		end if;
	end process;

	gfx_write_p : entity work.per_write_m(rtl)
		port map(
			clock  => Clock,
			reset  => reset,

      write_ack1_o => gfx_write_ack1,
      write_ack2_o => gfx_write_ack2,
      write_ack3_o => gfx_write_ack3,
      
      write1_i => gfx_write1,
      write2_i => gfx_write2,
      write3_i => gfx_write3,

      wready_i => wready_gfx,

      wvalid_o =>  wvalid_gfx,
      waddr_o =>  waddr_gfx,
      wlen_o => wlen_gfx,
      wsize_o => wsize_gfx,

      wdataready_i => wdataready_gfx,
      wdvalid_o => wdvalid_gfx,
      wtrb_o => wtrb_gfx,
      wdata_o => wdata_gfx,
      wlast_o => wlast_gfx,

      wrready_o => wrready_gfx,
      wrvalid_i => wrvalid_gfx,
      wrsp_i => wrsp_gfx,

      mem_wb_i => mem_wb

      );

	uart_write_p : entity work.per_write_m(rtl)
		port map(
			clock  => Clock,
			reset  => reset,

      write_ack1_o => uart_write_ack1,
      write_ack2_o => uart_write_ack2,
      write_ack3_o => uart_write_ack3,
      
      write1_i => uart_write1,
      write2_i => uart_write2,
      write3_i => uart_write3,

      wready_i => wready_uart,

      wvalid_o =>  wvalid_uart,
      waddr_o =>  waddr_uart,
      wlen_o => wlen_uart,
      wsize_o => wsize_uart,

      wdataready_i => wdataready_uart,
      wdvalid_o => wdvalid_uart,
      wtrb_o => wtrb_uart,
      wdata_o => wdata_uart,
      wlast_o => wlast_uart,

      wrready_o => wrready_uart, --o
      wrvalid_i => wrvalid_uart, --i
      wrsp_i => wrsp_uart,

      mem_wb_i => mem_wb

      );  

	toaudio_arbiter : entity work.arbiter2_ack(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => toaudio1,
			ack1  => audio_ack1,
			din2  => toaudio2,
			ack2  => audio_ack2,
			dout  => toaudio_p,
			ack   => audio_ack
		);

	tousb_arbiter : entity work.arbiter2_ack(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => tousb1,
			ack1  => usb_ack1,
			din2  => tousb2,
			ack2  => usb_ack2,
			dout  => tousb_p,
			ack   => usb_ack
		);

	audio_write_p : entity work.per_write_m(rtl)
		port map(
			clock  => Clock,
			reset  => reset,

      write_ack1_o => audio_write_ack1,
      write_ack2_o => audio_write_ack2,
      write_ack3_o => audio_write_ack3,
      
      write1_i => audio_write1,
      write2_i => audio_write2,
      write3_i => audio_write3,

      wready_i => wready_audio,

      wvalid_o =>  wvalid_audio,
      waddr_o =>  waddr_audio,
      wlen_o => wlen_audio,
      wsize_o => wsize_audio,

      wdataready_i => wdataready_audio,
      wdvalid_o => wdvalid_audio,
      wtrb_o => wtrb_audio,
      wdata_o => wdata_audio,
      wlast_o => wlast_audio,

      wrready_o => wrready_audio,
      wrvalid_i => wrvalid_audio,
      wrsp_i => wrsp_audio,

      mem_wb_i => mem_wb

      );

	usb_write_p : entity work.per_write_m(rtl)
		port map(
			clock  => Clock,
			reset  => reset,

      write_ack1_o => usb_write_ack1,
      write_ack2_o => usb_write_ack2,
      write_ack3_o => usb_write_ack3,
      
      write1_i => usb_write1,
      write2_i => usb_write2,
      write3_i => usb_write3,

      wready_i => wready_usb,

      wvalid_o =>  wvalid_usb,
      waddr_o =>  waddr_usb,
      wlen_o => wlen_usb,
      wsize_o => wsize_usb,

      wdataready_i => wdataready_usb,
      wdvalid_o => wdvalid_usb,
      wtrb_o => wtrb_usb,
      wdata_o => wdata_usb,
      wlast_o => wlast_usb,

      wrready_o => wrready_usb,
      wrvalid_i => wrvalid_usb,
      wrsp_i => wrsp_usb,

      mem_wb_i => mem_wb

      );  

	touart_arbiter : entity work.arbiter2_ack(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => touart1,
			ack1  => uart_ack1,
			din2  => touart2,
			ack2  => uart_ack2,
			dout  => touart_p,
			ack   => uart_ack
		);

	toproc1_res_arbiter : entity work.b_arbiter6(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => bus_res_mem_to_c1, -- tomem chan
			ack1  => brs2_ack1,
			din2  => bus_res2_2,        -- togfx chan
			ack2  => brs2_ack2,
			din3  => bus_res2_3,        -- touart chan
			ack3  => brs2_ack3,
			din4  => bus_res2_4,        -- tousb chan
			ack4  => brs2_ack4,
			din5  => bus_res2_5,        -- toaudio chan
			ack5  => brs2_ack5,
			din6  => pwr_res2_s,        -- bus_res2_6,
			ack6  => pwr_res2_ack_s,    -- brs2_ack6,
			dout  => bus_res2_o
		);

	per_upreq_arbiter : entity work.arbiter6_full(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => snp1_1,
			ack1  => snp1_ack1,
			din2  => snp1_2,
			ack2  => snp1_ack2,
			din3  => snp1_3,
			ack3  => snp1_ack3,
			din4  => snp1_4,
			ack4  => snp1_ack4,
			din5  => snp1_5,
			ack5  => snp1_ack5,
			din6  => snp1_6,
			ack6  => snp1_ack6,
			full => snp_req_full_i,
			dout  => up_snp_req_o
		);

	toproc0_res_arbiter : entity work.arbiter7(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => bus_res_mem_to_c0, -- from tomem_chan_p
			ack1  => brs1_ack1,
			din2  => bus_res_gfx_to_c0, -- from togfx_chan_p
			ack2  => brs1_ack2,
			din3  => bus_res1_3,        -- from touart_chan_p
			ack3  => brs1_ack3,
			din4  => bus_res1_4,        -- from tousb_chan_p
			ack4  => brs1_ack4,
			din5  => bus_res1_5,        -- from toaudio_chan_p
			ack5  => brs1_ack5,
			din6  => pwr_res1_s,        -- bus_res1_6, -- to cache 1
			ack6  => pwr_res1_ack_s,    -- brs1_ack6,
			din7  => ZERO_BMSG,         -- bus_res1_7, -- to cache 2 ?
			-- ack7  => brs1_ack7,
			dout  => bus_res1_o
		);

	gfx_upres_arbiter : entity work.arbiter6(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => gfx_upres1,
			ack1  => gfx_upres_ack1,
			din2  => gfx_upres2,
			ack2  => gfx_upres_ack2,
			din3  => gfx_upres3,
			ack3  => gfx_upres_ack3,
			din4  => gfx_upres4,
			ack4  => gfx_upres_ack4,
			din5  => gfx_upres5,
			ack5  => gfx_upres_ack5,
			din6  => gfx_upres6,
			ack6  => gfx_upres_ack6,
			dout  => gfx_upres_o
		);

	audio_upres_arbiter : entity work.arbiter6(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => audio_upres1,
			ack1  => audio_upres_ack1,
			din2  => audio_upres2,
			ack2  => audio_upres_ack2,
			din3  => audio_upres3,
			ack3  => audio_upres_ack3,
			din4  => audio_upres4,
			ack4  => audio_upres_ack4,
			din5  => audio_upres5,
			ack5  => audio_upres_ack5,
			din6  => audio_upres6,
			ack6  => audio_upres_ack6,
			dout  => audio_upres_o
		);

	usb_upres_arbiter : entity work.arbiter6(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => usb_upres1,
			ack1  => usb_upres_ack1,
			din2  => usb_upres2,
			ack2  => usb_upres_ack2,
			din3  => usb_upres3,
			ack3  => usb_upres_ack3,
			din4  => usb_upres4,
			ack4  => usb_upres_ack4,
			din5  => usb_upres5,
			ack5  => usb_upres_ack5,
			din6  => usb_upres6,
			ack6  => usb_upres_ack6,
			dout  => usb_upres_o
		);

	uart_upres_arbiter : entity work.arbiter6(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => uart_upres1,
			ack1  => uart_upres_ack1,
			din2  => uart_upres2,
			ack2  => uart_upres_ack2,
			din3  => uart_upres3,
			ack3  => uart_upres_ack3,
			din4  => uart_upres4,
			ack4  => uart_upres_ack4,
			din5  => uart_upres5,
			ack5  => uart_upres_ack5,
			din6  => uart_upres6,
			ack6  => uart_upres_ack6,
			dout  => uart_upres_o
		);

	mem_wb_arbiter : entity work.b_arbiter2(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => mem_wb1,
			ack1  => wb_ack1,
			din2  => mem_wb2,
			ack2  => wb_ack2,
			dout  => mem_wb
		);

	gfx_wb_arbiter : entity work.b_arbiter2(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => gfx_wb1,
			ack1  => gfx_wb_ack1,
			din2  => gfx_wb2,
			ack2  => gfx_wb_ack2,
			dout  => gfx_wb
		);

	audio_wb_arbiter : entity work.b_arbiter2(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => audio_wb1,
			ack1  => audio_wb_ack1,
			din2  => audio_wb2,
			ack2  => audio_wb_ack2,
			dout  => audio_wb
		);

	usb_wb_arbiter : entity work.b_arbiter2(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => usb_wb1,
			ack1  => usb_wb_ack1,
			din2  => usb_wb2,
			ack2  => usb_wb_ack2,
			dout  => usb_wb
		);

	uart_wb_arbiter : entity work.b_arbiter2(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => uart_wb1,
			ack1  => uart_wb_ack1,
			din2  => uart_wb2,
			ack2  => uart_wb_ack2,
			dout  => uart_wb
		);

	snp_res1_fifo_p : process(Clock)
	begin
		if rising_edge(Clock) then
			if reset = '1' then
                    we2 <= '0';
                elsif up_snp_res_i.val = '1' then
				--report "2 ic received";
				if up_snp_hit_i = '0' then
					in2 <= ('0', up_snp_res_i);
				else
					in2 <= ('1', up_snp_res_i);
				end if;
				we2 <= '1';
			else
				we2 <= '0';
			end if;

		end if;
	end process;

	snp_res1_p : process(Clock)
		variable state   : integer := 0;
		variable tmp_msg : MSG_T;
	begin
		if rising_edge(Clock) then
			if state = 0 then
			    report "snp_res state 0";
				if re2 = '0' and emp2 = '0' then
					re2   <= '1';
					state := 1;
				end if;
			elsif state = 1 then
				re2 <= '0';
				if out2.msg.val = '1' and out2.hit = '0' then
					--report "valie";
					report "3 ic using";
					-- -now we look at which components it want to go
					if out2.msg.adr(31 downto 31) = "1" then
						-- -this belongs to the memory	
						tmp_msg := out2.msg;
						tomem3  <= out2.msg;
						report "snoop )::::::::::::::::::::::::::::::tomem3 i's tag info: " & integer'image(to_integer(unsigned(out2.msg.tag)));
						state   := 5;
					elsif out2.msg.adr(30 downto 29) = "00" then
						togfx3 <= out2.msg;
						report "togfx3, snop response";	
						state  := 6;
					elsif out2.msg.adr(30 downto 29) = "01" then
						report "touart3, snop response";	
						touart3 <= out2.msg;
						state   := 7;
					elsif out2.msg.adr(30 downto 29) = "10" then
						report "tousb3, snop response";	
						tousb3 <= out2.msg;
						state  := 8;
					elsif out2.msg.adr(30 downto 29) = "11" then
						report "toaudio3, snop response";	
						toaudio3 <= out2.msg;
						state    := 14;
					end if;
				-- it's a hit, return to the source ip
				elsif out2.msg.val = '1' then
				report "else if";
					if dst_eq(out2.msg, GFX_TAG) then
						gfx_upres6 <= out2.msg;
						state      := 9;
					elsif dst_eq(out2.msg, UART_TAG) then
						uart_upres6 <= out2.msg;
						state       := 10;
					elsif dst_eq(out2.msg, USB_TAG) then
						usb_upres6 <= out2.msg;
						state      := 11;
					elsif dst_eq(out2.msg, AUDIO_TAG) then
						audio_upres6 <= out2.msg;
						state        := 12;
					end if;
				end if;
			elsif state = 5 then
				if mem_ack3 = '1' then
					report "3 ack";
					state  := 0;
					tomem3 <= ZERO_MSG;
				end if;
			elsif state = 6 then
				if gfx_ack3 = '1' then
					state  := 0;
					togfx3 <= ZERO_MSG;
				end if;
			elsif state = 7 then
				if uart_ack3 = '1' then
					state   := 0;
					touart3 <= ZERO_MSG;
				end if;
			elsif state = 8 then
				if audio_ack3 = '1' then
					state    := 0;
					toaudio3 <= ZERO_MSG;
				end if;
			elsif state = 14 then
				if usb_ack3 = '1' then
					state  := 0;
					tousb3 <= ZERO_MSG;
				end if;
			elsif state = 9 then
				if gfx_upres_ack6 = '1' then
					gfx_upres6 <= ZERO_MSG;
					state      := 0;
				end if;
			elsif state = 10 then
				if uart_upres_ack6 = '1' then
					uart_upres6 <= ZERO_MSG;
					state       := 0;
				end if;
			elsif state = 11 then
				if usb_upres_ack6 = '1' then
					usb_upres6 <= ZERO_MSG;
					state      := 0;
				end if;
			elsif state = 12 then
				if audio_upres_ack6 = '1' then
					audio_upres6 <= ZERO_MSG;
					state        := 0;
				end if;

			end if;

		end if;
	end process;

  c0_wbreq_fifo_p : entity work.bmsg_fifo_m(rtl)
    port map (
      clock => clock,
      reset => reset,
      data_i => wb_req1_i,
      tofifo_o => in6,
      we_o => we6
      );
  
  c1_wbreq_fifo_p : entity work.bmsg_fifo_m(rtl)
    port map (
      clock => clock,
      reset => reset,
      data_i => wb_req2_i,
      tofifo_o => in7,
      we_o => we7
      );

	pwr_req_arbiter : entity work.arbiter6(rtl)
		port map(
			clock => Clock,
			reset => reset,
			din1  => pwr_req1,
			ack1  => pwr_ack1,
			din2  => pwr_req2,
			ack2  => pwr_ack2,
			-- 3-6 are not used
			din3  => ZERO_MSG,
			din4  => ZERO_MSG,
			din5  => ZERO_MSG,
			din6  => ZERO_MSG,
			dout  => pwr_req_o
		);

	pwr_res_p : process(Clock)
		variable st  : natural;
		variable src : ADR_T;
		variable dst : DAT_T;
	begin
		if rising_edge(Clock) then
			if reset = '1' then
                    st := 0;
                elsif st = 0 then
				if pwr_res_i.val = '1' then
					dst := pwr_res_i.dat;

					if pwr_res_i.cmd = PWRDN_CMD then
						if dst = pad32(GFX_TAG) then
							gfxpoweron <= '0';
						elsif dst = pad32(AUDIO_TAG) then
							audiopoweron <= '0';
						elsif dst = pad32(USB_TAG) then
							usbpoweron <= '0';
						elsif dst = pad32(UART_TAG) then
							uartpoweron <= '0';
						end if;
					elsif pwr_res_i.cmd = PWRUP_CMD then
						-- --report "pu";
						if dst = pad32(GFX_TAG) then
							-- --report "dst:gfx";
							gfxpoweron <= '1';
						elsif dst = pad32(AUDIO_TAG) then
							audiopoweron <= '1';
						elsif dst = pad32(USB_TAG) then
							usbpoweron <= '1';
						elsif dst = pad32(UART_TAG) then
							uartpoweron <= '1';
						end if;
					end if;

					src := pwr_res_i.adr;
					if src = pad32(CPU0_TAG) then
						-- --report "src:cpu0";
						to_bmsg(pwr_res1_s, pwr_res_i);
					elsif src = pad32(CPU1_TAG) then
						to_bmsg(pwr_res2_s, pwr_res_i);
					end if;

					st := 1;
				end if;                 -- end if valid
			elsif st = 1 then
				if pwr_res1_ack_s = '1' then
					clr(pwr_res1_s);
					st := 0;
				end if;
				if pwr_res2_ack_s = '1' then
					clr(pwr_res2_s);
					st := 0;
				end if;
			end if;
		end if;
	end process;

	wb0_m : entity work.wb_m(rtl)
		port map(
			clock             => clock,
			reset             => reset,
			fifo_empty_i      => emp6,
			wb_o              => out6,
			mem_write_o       => mem_write2,
			gfx_write_o       => gfx_write2,
			uart_write_o      => uart_write2,
			usb_write_o       => usb_write2,
			audio_write_o     => audio_write2,
			mem_write_ack_i   => mem_write_ack2,
			gfx_write_ack_i   => gfx_write_ack2,
			uart_write_ack_i  => uart_write_ack2,
			usb_write_ack_i   => usb_write_ack2,
			audio_write_ack_i => audio_write_ack2,
			wready_gfx_i      => wready_gfx,
			wready_uart_i     => wready_uart,
			wready_usb_i      => wready_usb,
			wready_audio_i    => wready_audio,
			re_io             => re6
		);

	wb1_m : entity work.wb_m(rtl)
		port map(
			clock             => clock,
			reset             => reset,
			fifo_empty_i      => emp7,
			wb_o              => out7,
			mem_write_o       => mem_write3,
			gfx_write_o       => gfx_write3,
			uart_write_o      => uart_write3,
			usb_write_o       => usb_write3,
			audio_write_o     => audio_write3,
			mem_write_ack_i   => mem_write_ack3,
			gfx_write_ack_i   => gfx_write_ack3,
			uart_write_ack_i  => uart_write_ack3,
			usb_write_ack_i   => usb_write_ack3,
			audio_write_ack_i => audio_write_ack3,
			wready_gfx_i      => wready_gfx,
			wready_uart_i     => wready_uart,
			wready_usb_i      => wready_usb,
			wready_audio_i    => wready_audio,
			re_io             => re7
		);

	cache0_req_m : entity work.cache_req_m(rtl)
		port map(
			clock       => clock,
			reset       => reset,
			cache_req_i => out16,
			pwr_req_o   => pwr_req1,
			re =>re16,
			emp =>emp16,
			tomem_o     => tomem1,
			togfx_o     => togfx1,
			touart_o    => touart1,
			tousb_o     => tousb1,
			toaudio_o   => toaudio1,
			pwr_ack_i   => pwr_ack1,
			mem_ack_i   => mem_ack1,
			gfx_ack_i   => gfx_ack1,
			uart_ack_i  => uart_ack1,
			usb_ack_i   => usb_ack1,
			audio_ack_i => audio_ack1
		);

	cache1_req_m : entity work.cache_req_m(rtl)
		port map(
			clock       => clock,
			reset       => reset,
			cache_req_i => out17,
			re =>re17,
			emp =>emp17,
			pwr_req_o   => pwr_req2,
			tomem_o     => tomem2,
			togfx_o     => togfx2,
			touart_o    => touart2,
			tousb_o     => tousb2,
			toaudio_o   => toaudio2,
			pwr_ack_i   => pwr_ack2,
			mem_ack_i   => mem_ack2,
			gfx_ack_i   => gfx_ack2,
			uart_ack_i  => uart_ack2,
			usb_ack_i   => usb_ack2,
			audio_ack_i => audio_ack2
		);

end rtl;
