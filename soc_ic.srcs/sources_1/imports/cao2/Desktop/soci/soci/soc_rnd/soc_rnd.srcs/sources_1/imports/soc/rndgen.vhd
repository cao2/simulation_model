library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity rndgen is
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    en           : in  std_logic;
    
    seed_i       : in  integer;
    rnd_o        : out std_logic_vector(31 downto 0)
    );

end rndgen;

architecture rtl of rndgen is
  signal sim_end : std_logic := '0';
begin
  rnd_p : process(clk)
    constant SEED : integer := 844396720;
    -- constant SEED1 : integer := 821616997;
    -- constant SEED2 : integer := 338311761;
    -- constant SEED3 : integer := 63851964;
    -- constant SEED4 : integer := 506390813;
    -- constant SEED5 : integer := 915501798;
    -- constant SEED6 : integer := 1760570549;
    -- constant SEED7 : integer := 8069022;
    -- constant SEED8 : integer := 2133271959;
    -- constant SEED9 : integer := 1833238054;

    variable st : unsigned(31 downto 0) := to_unsigned(SEED, 32);
  begin
   if (rising_edge(clk)) then
    if en = '1' then
        if rst = '1' then
          st :=  to_unsigned(SEED + seed_i, 32);
        else
        st := st xor shift_left(st, 13);
        st := st xor shift_right(st, 17);
        st := st xor shift_left(st, 5);
        rnd_o <= std_logic_vector(st);
      -- dbg(std_logic_vector(st));
      end if;
      end if;
    end if;
  end process;
end architecture rtl;

