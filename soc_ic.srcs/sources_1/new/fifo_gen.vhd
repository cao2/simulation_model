library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity fifo_gen is
  Generic (
    constant B	: positive := 32;
    constant W: positive := 32
	);
  Port ( 
    clk		: in  STD_LOGIC;
    reset		: in  STD_LOGIC;
    wr	: in  STD_LOGIC;
    w_data	: in  std_logic_vector(B-1 downto 0);
    rd	: in  STD_LOGIC;
    r_data	: out std_logic_vector(B-1 downto 0);
    Empty	: out STD_LOGIC;
    Full	: out STD_LOGIC := '0'
	);
end fifo_gen;

architecture rtl of fifo_gen is
 --signal td1: std_logic_vector(31 downto 0);
 --signal td2: std_logic_vector(31 downto 0);
begin
	
  -- Memory Pointer Process
  fifo_proc : process (clk)
    type FIFO_Memory is
      array (0 to 2**W - 1) of std_logic_vector(B-1 downto 0);
    variable Memory : FIFO_Memory;
    
    variable Head : natural range 0 to 2**W - 1;
    variable Tail : natural range 0 to 2**W - 1;
    
    variable Looped : boolean;
  begin
  	if rising_edge(CLK) then
  		--td2<=Memory(Tail).dat;
  		--td1<=DataIn.dat;
      if reset = '1' then
        Head := 0;
        Tail := 0;
        Looped := false;
        Full  <= '0';
        Empty <= '1';
        r_data<= (others=>'0');
    else
    	
        if (wr = '1') then
          if ((Looped = false) or (Head /= Tail)) then
            -- Write Data to Memory
            Memory(Head) := w_data;
            
            -- Increment Head pointer as needed
            if (Head = 2**W - 1) then
              Head := 0;
              
              Looped := true;
            else
              Head := Head + 1;
            end if;
          end if;
        end if;
        
        if (rd = '1') then
          if ((Looped = true) or (Head /= Tail)) then
            -- Update data output
            r_data <= Memory(Tail);
            
            -- Update Tail pointer as needed
            if (Tail = 2**W - 1) then
              Tail := 0;
              
              Looped := false;
            else
              Tail := Tail + 1;
            end if;
          end if;
        else 
          r_data <= (others=>'0');
        end if;
        
        -- Update Empty and Full flags
        if (Head = Tail+1) then
          if Looped then
            Full <= '1';
          else
            Empty <= '1';
          end if;
        else
          Empty	<= '0';
          Full	<= '0';
        end if;
      end if;
    end if;
  end process;
  
end rtl;
