library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.util.all;
--use work.rand.all;
use work.test.all;

entity per_write_m is
	Port(
	clock : in  std_logic;
	reset : in  std_logic;
    write_ack1_o : out std_logic;
    write_ack2_o : out std_logic;
    write_ack3_o : out std_logic;

    write1_i : in MSG_T;
    write2_i : in BMSG_T;
    write3_i : in BMSG_T;

    wready_i : in std_logic;
    wvalid_o : out std_logic;
    waddr_o : out ADR_T;
    wlen_o : out std_logic_vector(9 downto 0);
	wsize_o : out std_logic_vector(9 downto 0);

    wdataready_i : in std_logic;
	wdvalid_o : out std_logic;
	wtrb_o : out std_logic_vector(3 downto 0);
	wdata_o : out DAT_T;
	wlast_o : out std_logic;

	wrready_o : out std_logic;
	wrvalid_i : in std_logic;
	wrsp_i : in std_logic_vector(1 downto 0);
    mem_wb_i : in BMSG_T
    
    );
end per_write_m;

architecture rtl of per_write_m is

begin
	per_write_p : process(Clock)
		variable state     : integer := 0;
		variable tep_gfx   : MSG_T;
		variable tep_gfx_l : BMSG_T;
		variable flag      : natural;
		variable tdata     : std_logic_vector(511 downto 0);
		variable lp        : integer := 0;
		variable prev_st   : integer := -1;
	begin
		if rising_edge(Clock) then
			-- dbg_chg("gfx_write_p", state, prev_st);
			if reset = '1' then
                flag := 0;
            elsif state = 0 then
				lp             := 0;
				write_ack1_o <= '0';
				write_ack2_o <= '0';
				write_ack3_o <= '0';
				if write1_i.val = '1' then
					state          := 1;
					tep_gfx     := write1_i;
					flag :=  1;
					---write_ack1_o <= '1';
				elsif write2_i.val = '1' then
					state          := 4;
					tep_gfx_l      := write2_i;
					flag := 2;
					---write_ack2_o <= '1';
				elsif write3_i.val = '1' then
					state          := 4;
					tep_gfx_l      := write3_i;
					flag := 3;
					---write_ack3_o <= '1';
				end if;
			elsif state = 1 then
				--write_ack1_o <= '0';
				if wready_i = '1' then
					wvalid_o <= '1';
					waddr_o  <= tep_gfx.adr;
					wlen_o   <= "00000" & "00001"; -- MERGE durw: [10000/00001]
					wsize_o  <= "00001" & "00000";
					-- wdata_audio := tep_gfx.dat;
					state := 2;
				end if;
			elsif state = 2 then
				wvalid_o <= '0';
				if wdataready_i = '1' then
					wdvalid_o <= '1';
					wtrb_o    <= "1111";
					wdata_o   <= tep_gfx.dat;
					wlast_o   <= '1';
					state       := 6;
				end if;

			elsif state = 3 then
--				wdvalid_o <= '0';
--				wrready_o <= '1';
--				if wrvalid_i = '1' then
--					if wrsp_i = "00" then

--					-- -this is a successful write back, yayyy
--					end if;
--					wrready_o <= '0';
					state       := 0;

--				end if;
			elsif state = 4 then
				--write_ack2_o <= '0';
				--write_ack3_o <= '0';
				if wready_i = '1' then
					wvalid_o <= '1';
					waddr_o  <= tep_gfx_l.adr;
					wlen_o   <= "00000" & "10000";
					wsize_o  <= "00001" & "00000";
					tdata      := tep_gfx_l.dat;
					state      := 5;
				end if;
			elsif state = 5 then
				if wdataready_i = '1' then
					wdvalid_o <= '1';
					wtrb_o    <= "1111";
					wdata_o   <= tdata(lp + 31 downto lp);
					lp          := lp + 32;
					if lp = 512 then
						wlast_o <= '1';
						state     := 6;
						lp        := 0;
					end if;
				end if;
			elsif state = 6 then
				wdvalid_o <= '0';
				wrready_o <= '1';
				if wrvalid_i = '1' then
				    state := 3;
                    if (flag = 1) then
                        write_ack1_o <= '1';
                    elsif (flag = 2) then
                        write_ack2_o <= '1';
                    elsif (flag = 3) then
                        write_ack3_o <= '1';
                    end if;					
					if wrsp_i = "00" then
					-- -this is a successful write back, yayyy               
					end if;
					wrready_o <= '0';
				end if;
			end if;
		end if;
	end process;

end rtl;
