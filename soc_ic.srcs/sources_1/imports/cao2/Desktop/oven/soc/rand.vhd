library ieee;
use ieee.math_real.all; -- for uniform fun
use ieee.numeric_std.all; -- for int to std_logic_vect conversion
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; -- for conv_std_logic_vector fun
use std.textio.all;
use work.defs.all;

package rand is
  constant RND_INT_CNT: natural := 100000;
  constant RND_INT_MAX: natural := 9;
  
  --+ seeds
  constant SEED1: integer:= 844396720;
  constant SEED2: integer:= 821616997;

  constant sd1: positive := 844396720;
  constant sd2: positive := 821616997;
  
  type int_array_t is array(0 to RND_INT_CNT) of integer;

  impure function rand_init(fn : string) return int_array_t;

  --* Returns a number between 0 and RND_INT_MAX.
  function rand_nat(constant seed:in natural) return natural;

  function rnd_adr(constant seed:in natural) return std_logic_vector;
  
  --* Returns a std_logic_vector of size bits between 1 and num.
  function rand_vect_range(constant num:in integer;
                      constant size:in integer) return std_logic_vector;
end rand;

package body rand is

  impure function rand_init(fn : string) return int_array_t is
    file rnd_ints1_f : TEXT open read_mode is fn;
    variable l : line;
    variable n : integer;
    variable i : integer := 0;
    variable res : int_array_t := (others => 0);
  begin
    while (not endfile(rnd_ints1_f)) and i < RND_INT_CNT loop
      readline(rnd_ints1_f, l);
      read(l, n);
      res(i) := n;
      i := i+1;
    end loop;
    return res;
  end rand_init;

  constant a4b : int_array_t := rand_init("rand_ints4b.txt");
--  constant a10b : int_array_t := rand_init("rand_ints10b.txt");
--  constant a8b : int_array_t := rand_init("rand_ints8b.txt");
  constant a32b : int_array_t := rand_init("rand_ints32b.txt");
  
  function rand_nat(constant seed:in natural) return natural is
  begin
    --report "rnd[" & integer'image((seed + time'pos(now)) mod RND_INT_CNT) & "]:" & integer'image(a((seed + time'pos(now)) mod RND_INT_CNT));
    return a4b((seed + time'pos(now)) mod RND_INT_CNT);
  end rand_nat;

  function rnd_adr(constant seed:in natural) return std_logic_vector is
    variable tmp, tmp2 : std_logic_vector(31 downto 0);
  begin
    --report "rnd[" & integer'image((seed + time'pos(now)) mod RND_INT_CNT) & "]:" & integer'image(a((seed + time'pos(now)) mod RND_INT_CNT));
    return std_logic_vector(to_unsigned(a32b((seed + time'pos(now)) mod RND_INT_CNT), 32));
  end rnd_adr;
  
  function rand_vect_range(constant num:in integer;
                       constant size:in integer)
    return std_logic_vector is
    variable s1:integer := SEED1;
    variable s2:integer := SEED2;
    variable result:std_logic_vector(size-1 downto 0);
    variable tmp_real:real;
  begin
    uniform(s1,s2,tmp_real);
    result := conv_std_logic_vector(integer(trunc(
      tmp_real * real (num)))+1,size);
    return (result);
  end rand_vect_range;
end rand;
