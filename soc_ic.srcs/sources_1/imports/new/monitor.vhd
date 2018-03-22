library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity monitor_axi_read is
	Port(
		clk           : in  STD_LOGIC;
		rst           : in  STD_LOGIC;
		----Configurations
		cmd_en : in  std_logic_vector (4 downto 0);
		tag_en : in  std_logic_vector (7 downto 0);
		id_en : in  std_logic_vector (7 downto 0);
		
		----AXI interface
		link_id: in std_logic_vector((monitor_width-1) downto 0);
		tag_i : in std_logic_vector(7 downto 0);
		id_i          : in  std_logic_vector(7 downto 0);
		---write address channel

		---read address channel
		raddr_i       : in  std_logic_vector(31 downto 0);
		rlen_i        : in  std_logic_vector(9 downto 0);
		rsize_i       : in  std_logic_vector(9 downto 0);
		rvalid_i      : in  std_logic;
		rready_i      : in  std_logic;
		---read data channel
		rdata_i       : in  std_logic_vector(31 downto 0);
		rstrb_i       : in  std_logic_vector(3 downto 0);
		rlast_i       : in  std_logic;
		rdvalid_i     : in  std_logic;
		rdready_i     : in  std_logic;
		rres_i        : in  std_logic_vector(1 downto 0);
		----output 
		id_o          :  out  std_logic_vector(7 downto 0);
		---read address channel
		raddr_o       : out std_logic_vector(31 downto 0);
		rlen_o        : out std_logic_vector(9 downto 0);
		rsize_o       : out std_logic_vector(9 downto 0);
		rvalid_o      : out std_logic;
		rready_o      : out std_logic;
		---read data channel
		rdata_o       : out std_logic_vector(31 downto 0);
		rstrb_o       : out std_logic_vector(3 downto 0);
		rlast_o       : out std_logic;
		rdvalid_o     : out std_logic;
		rdready_o     : out std_logic;
		rres_o        : out std_logic_vector(1 downto 0);
		transaction_o : out AXI_T;
		tst_t_o: out TST_T
	);
end monitor_axi_read;
architecture rtl of monitor_axi_read is
	--signal td1: std_logic_vector(31 downto 0);
	--signal td2: std_logic_vector(31 downto 0);
	type state is (one, two, three, four, five);
begin

	axi_wt_extractor_write : process(rst,clk)
		variable tmp_transaction : AXI_T;
		variable st              : state                         := one;
		variable adr             : std_logic_vector(31 downto 0) := (others => '0');
		variable id              : std_logic_vector(7 downto 0)  := (others => '0');
	begin
	    if (rst='1') then
	       transaction_o.val <='0';
	       tst_t_o.val<='0';
		elsif rising_edge(clk) then
			if st = one then
				transaction_o.val <= '0';
				tmp_transaction.val :='0';
				tst_t_o.val <='0';
				if rready_i = '1' then
					st := two;
				end if;
			elsif st = two then
				if rvalid_i = '1' then
				    tmp_transaction.val := '1';
					tmp_transaction.linkID   := link_id;
					tmp_transaction.cmd      := '0';
                    tmp_transaction.tag :=tag_i;
                    tmp_transaction.id:= id_i;
					if raddr_i = adr then
						tmp_transaction.adr := "00";
					elsif unsigned(raddr_i) - unsigned(adr) = 1 or unsigned(adr) - unsigned(raddr_i) = 1 then
						tmp_transaction.adr := "01";
					else
						tmp_transaction.adr := "10";
					end if;
					st                  := three;
					if (((tag_i and tag_en)=tag_i) and ((id_i and id_en)=id_i) and cmd_en(1)='1') then
					   transaction_o<= tmp_transaction;
					   tst_t_o <= (tmp_transaction.val, 
					   tmp_transaction.linkID, 
					   "00000001",
					   tmp_traNsaction.tag,
					   tmp_transaction.id, tmp_transaction.adr);
					 end if;
				end if;
			elsif st = three then
			transaction_o.val<='0';
			tst_t_o.val <='0';
				if rdready_i = '1' then
					---Note: the data is available here
					---, do we need to check that?
					if rdvalid_i = '1' and rlast_i = '1' then
						if rres_i = "00" then
							tmp_transaction.linkID   := link_id;
							tmp_transaction.cmd      := '1';
							if (((tag_i and tag_en)=tag_i) 
                                and ((id_i and id_en)=id_i) and cmd_en(1)='1') then
							transaction_o            <= tmp_transaction;
							tst_t_o <= (tmp_transaction.val, 
                                                tmp_transaction.linkID, 
                                                "00000010",
                                                 tmp_traNsaction.tag,
                                                 tmp_transaction.id, tmp_transaction.adr);
                            end if;
							st                       := one;
						end if;
						st            := one;
						---read response here is done
--						transaction_o <= tmp_transaction;
--						tst_t_o <= (tmp_transaction.val, 
--                                            tmp_transaction.sender, 
--                                            tmp_transaction.receiver, 
--                                            READ_CMD,
--                                             tmp_traNsaction.tag,
--                                             tmp_transaction.id, tmp_transaction.adr);
					end if;
				end if;
			end if;
		end if;
	end process;

	output : process(clk)
	begin
		if rising_edge(clk) then

			---------axi protocol
			id_o      <= id_i;
			---read address channel
			raddr_o   <= raddr_i;
			rlen_o    <= rlen_i;
			rsize_o   <= rsize_i;
			rvalid_o  <= rvalid_i;
			rready_o  <= rready_i;
			---read data channel
			rdata_o   <= rdata_i;
			rstrb_o   <= rstrb_i;
			rlast_o   <= rlast_i;
			rdvalid_o <= rdvalid_i;
			rdready_o <= rdready_i;
			rres_o    <= rres_i;
		end if;
	end process;
end rtl;

