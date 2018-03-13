library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity monitor_axi_write is
	Port(
		clk           : in  STD_LOGIC;
		rst           : in  STD_LOGIC;
		----AXI interface
		master_id     : in  IP_T;
		slave_id      : in  IP_T;
		tag_i         : in  std_logic_vector(7 downto 0);
		id_i          : in  std_logic_vector(7 downto 0);
		---write address channel
		waddr_i       : in  ADR_T;
		wlen_i        : in  std_logic_vector(9 downto 0);
		wsize_i       : in  std_logic_vector(9 downto 0);
		wvalid_i      : in  std_logic;
		wready_i      : in  std_logic;
		---write data channel
		wdata_i       : in  std_logic_vector(31 downto 0);
		wtrb_i        : in  std_logic_vector(3 downto 0); --TODO not implemented
		wlast_i       : in  std_logic;
		wdvalid_i     : in  std_logic;
		wdataready_i  : in  std_logic;
		---write response channel
		wrready_i     : in  std_logic;
		wrvalid_i     : in  std_logic;
		wrsp_i        : in  std_logic_vector(1 downto 0);
		----output 
		id_o          : out std_logic_vector(7 downto 0);
		---write address channel
		waddr_o       : out ADR_T;
		wlen_o        : out std_logic_vector(9 downto 0);
		wsize_o       : out std_logic_vector(9 downto 0);
		wvalid_o      : out std_logic;
		wready_o      : out std_logic;
		---write data channel
		wdata_o       : out std_logic_vector(31 downto 0);
		wtrb_o        : out std_logic_vector(3 downto 0); --TODO not implemented
		wlast_o       : out std_logic;
		wdvalid_o     : out std_logic;
		wdataready_o  : out std_logic;
		---write response channel
		wrready_o     : out std_logic;
		wrvalid_o     : out std_logic;
		wrsp_o        : out std_logic_vector(1 downto 0);
		---read address channel

		transaction_o : out AXI_T;
		tst_t_o : out TST_T
	);
end monitor_axi_write;

architecture rtl of monitor_axi_write is
	--signal td1: std_logic_vector(31 downto 0);
	--signal td2: std_logic_vector(31 downto 0);
	type state is (one, two, three, four, five);
begin

	axi_wt_extractor_write : process(clk)
		variable tmp_transaction : AXI_T;
		variable st              : state                         := one;
		variable adr             : std_logic_vector(31 downto 0) := (others => '0');
		variable id              : std_logic_vector(7 downto 0)  := (others => '0');
	begin
		if rising_edge(clk) then

			if st = one then
				transaction_o.val <= '0';
				tst_t_o.val <='0';
				if wready_i = '1' then
					st := two;
				end if;
			elsif st = two then
				if wvalid_i = '1' then

					---------see what to do
					---tmp_transaction.adr      := "00";
					if waddr_i = adr then
						tmp_transaction.adr := "00";
					elsif unsigned(waddr_i) - unsigned(adr) = 1 or unsigned(adr) - unsigned(waddr_i) = 1 then
						tmp_transaction.adr := "01";
					else
						tmp_transaction.adr := "10";
					end if;

					--					if id_i = id then
					--						tmp_transaction.id := "00";
					--					elsif unsigned(id_i) - unsigned(id) = 1 or unsigned(id) - unsigned(id_i) = 1 then
					--						tmp_transaction.id := "01";
					--					else
					--						tmp_transaction.id := "10";
					--					end if;

					---Note: there are also size, and length, ignored here
					st := three;
				end if;
			elsif st = three then
				if wdataready_i = '1' then
					st := four;
				end if;
			elsif st = four then
				---Note: the data is available here
				---, do we need to check that?
				tmp_transaction.val      := '1';
				tmp_transaction.sender   := master_id;
				tmp_transaction.receiver := slave_id;
				tmp_transaction.cmd      := '0';
				tmp_transaction.tag      := tag_i;
				tmp_transaction.id       := id_i;
				if wdvalid_i = '1' and wlast_i = '1' then
					st            := five;
					transaction_o <= tmp_transaction;
					tst_t_o <= (tmp_transaction.val, 
                                        tmp_transaction.sender, 
                                        tmp_transaction.receiver, 
                                        WRITE_CMD,
                                         tmp_traNsaction.tag,
                                         tmp_transaction.id, tmp_transaction.adr);
				end if;

			elsif st = five then
				transaction_o.val <= '0';
				tst_t_o.val <='0';
				if wrvalid_i = '1' then
					if wrsp_i = "00" then
						tmp_transaction.sender   := slave_id;
						tmp_transaction.receiver := master_id;
						tmp_transaction.cmd      := '1';
						transaction_o            <= tmp_transaction;
						tst_t_o <= (tmp_transaction.val, 
                                            tmp_transaction.sender, 
                                            tmp_transaction.receiver, 
                                            WRITE_CMD,
                                             tmp_traNsaction.tag,
                                             tmp_transaction.id, tmp_transaction.adr);
						st                       := one;
					end if;
				end if;
			end if;
		end if;
	end process;

	output : process(clk)
	begin
		if rising_edge(clk) then

			---------axi protocol
			id_o         <= id_i;
			waddr_o      <= waddr_i;
			wlen_o       <= wlen_i;
			wsize_o      <= wsize_i;
			wvalid_o     <= wvalid_i;
			wready_o     <= wready_i;
			---write data channel
			wdata_o      <= wdata_i;
			wtrb_o       <= wtrb_i;
			wlast_o      <= wlast_i;
			wdvalid_o    <= wdvalid_i;
			wdataready_o <= wdataready_i;
			---write response channel
			wrready_o    <= wrready_i;
			wrvalid_o    <= wrvalid_i;
			wrsp_o       <= wrsp_i;

		end if;
	end process;
end rtl;
