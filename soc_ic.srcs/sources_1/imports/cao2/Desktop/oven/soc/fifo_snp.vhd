library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity fifo_snp is
  Generic (
    constant FIFO_DEPTH	: positive := 32
	);
  Port ( 
    CLK		: in  STD_LOGIC;
    RST		: in  STD_LOGIC;
    WriteEn	: in  STD_LOGIC;
    DataIn	: in  SNP_RES_T;
    ReadEn	: in  STD_LOGIC;
    DataOut	: out SNP_RES_T;
    Empty	: out STD_LOGIC;
    Full	: out STD_LOGIC := '0'
	);
end fifo_snp;

architecture rtl of fifo_snp is

begin
  -- Memory Pointer Process
  fifo_proc : process (clk)
    type FIFO_Memory is
      array (0 to FIFO_DEPTH - 1) of SNP_RES_T;
    variable Memory : FIFO_Memory;
    
    variable Head : natural range 0 to FIFO_DEPTH - 1;
    variable Tail : natural range 0 to FIFO_DEPTH - 1;
    
    variable Looped : boolean;
  begin
    if rising_edge(CLK) then
      if RST = '1' then
        Head := 0;
        Tail := 0;
        Looped := false;
        Full  <= '0';
        Empty <= '1';
      else
        if (WriteEn = '1') then
          if ((Looped = false) or (Head /= Tail)) then
            -- Write Data to Memory
            Memory(Head) := DataIn;
            -- Increment Head pointer as needed
            if (Head = FIFO_DEPTH - 1) then
              Head := 0;
              Looped := true;
            else
              Head := Head + 1;
            end if;
          end if;
        end if;
        
        if (ReadEn = '1') then
          if ((Looped = true) or (Head /= Tail)) then
            -- Update data output
            DataOut <= Memory(Tail);
            -- Update Tail pointer as needed
            if (Tail = FIFO_DEPTH - 1) then
              Tail := 0;
              Looped := false;
            else
              Tail := Tail + 1;
            end if;
          end if;
        else 
          DataOut <= ('0', ZERO_MSG);
        end if;
        
        -- Update Empty and Full flags
        if (Head = Tail) then
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

