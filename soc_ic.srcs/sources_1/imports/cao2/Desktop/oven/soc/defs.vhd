library ieee;
use ieee.std_logic_1164.all;

package defs is
  constant MSG_WIDTH : positive := 73;
  constant WMSG_WIDTH : positive := 76;
  constant BMSG_WIDTH : positive := 553;
  constant Monitor_width: positive := 5;
  constant CMD_WIDTH : positive := 8;
  constant ADR_WIDTH : positive := 32;
  constant DAT_WIDTH : positive := 32;
  constant IP_CT: positive := 4;
 
  
  
  type rank_list is array (0 to 31) of natural range 0 to 31;
 subtype IP_VECT_T is std_logic_vector(19 downto 0);
   type IP_T is (CPU0, CPU1, CACHE0, CACHE1,
                 SA, MEM, GFX, PMU,
                 AUDIO, USB, UART,CACHE0M,
                  CACHE1M,SAM,
                 GFXM, AUDIOM, USBM, UARTM,
                 NONE);
   type STATE is (one, two, three, four, five, six,seven, eight);
   type IP_VECT_ARRAY_T is array(IP_T) of IP_VECT_T;
   constant ip_enc : IP_VECT_ARRAY_T := (x"00001", x"00002", x"00004", x"00008",
                                         x"00010", x"00020", x"00040", x"00080",
                                         x"00100", x"00200", x"00400", x"00800", x"01000",x"02000",
                                         x"04000", x"08000", x"10000",x"20000",
                                         x"00000");
  
  type MSG_T is record
   val       : std_logic;                     -- valid bit;
   cmd       : std_logic_vector(7 downto 0);
   tag       : std_logic_vector(7 downto 0);  -- src
   id        : std_logic_vector(7 downto 0);  --sequence id
   adr       : std_logic_vector(31 downto 0);
   dat       : std_logic_vector(31 downto 0);
end record MSG_T;

type TST_T is record
   val       : std_logic;                     -- valid bit;
   linkID : std_logic_vector((monitor_width-1) downto 0);
   cmd       : std_logic_vector(7 downto 0);
   tag       : std_logic_vector(7 downto 0);  -- src
   id        : std_logic_vector(7 downto 0);  --sequence id
   adr       : std_logic_vector(2 downto 0);
end record TST_T;


type ALL_T is
     array (0 to 31) of TST_T;
     
     
     
type TST_TTS is record
    val       : std_logic;                     -- valid bit;
   linkID : std_logic_vector((monitor_width-1) downto 0);
   cmd       : std_logic_vector(7 downto 0);
   tag       : std_logic_vector(7 downto 0);  -- src
   id        : std_logic_vector(7 downto 0);  --sequence id
   adr       : std_logic_vector(2 downto 0);
   tim      : INTEGER;
   channel: integer;
end record TST_TTS;
type TST_TO is record
   val       : std_logic;                     -- valid bit;
  linkID : std_logic_vector((monitor_width-1) downto 0);
   cmd       : std_logic_vector(7 downto 0);
   tag       : std_logic_vector(7 downto 0);  -- src
   id        : std_logic_vector(7 downto 0);  --sequence id
   adr       : std_logic_vector(1 downto 0);
   tim      : std_logic;
end record TST_TO;
type AXI_T is record
   val       : std_logic;                     -- valid bit;
   linkID : std_logic_vector((monitor_width-1) downto 0);
   cmd       : std_logic;
   tag       : std_logic_vector(7 downto 0);  -- src
   id        : std_logic_vector(7 downto 0);  --sequence id
   adr       : std_logic_vector(2 downto 0);
end record AXI_T;

type cacheline is record
	val       : std_logic;                     -- valid bit;
   cmd       : std_logic_vector(7 downto 0);
   tag       : std_logic_vector(7 downto 0);  -- src
   id        : std_logic_vector(7 downto 0);  --sequence id
   adr       : std_logic_vector(31 downto 0);
   dat       : std_logic_vector(511 downto 0);
   frontinfo : std_logic_vector(35 downto 0);
end record cacheline;

  type BMSG_T is record
   val       : std_logic;                     -- valid bit;
   cmd       : std_logic_vector(7 downto 0);
   tag       : std_logic_vector(7 downto 0);  -- src
   id        : std_logic_vector(7 downto 0);  --sequence id
   adr       : std_logic_vector(31 downto 0);
   dat       : std_logic_vector(511 downto 0);
  end record BMSG_T;

  type SNP_RES_T is record
    hit     : std_logic;
    msg     : MSG_T;
  end record SNP_RES_T;
  
  constant ZERO_MSG : MSG_T := ('0',
                                (others => '0'),
                                (others => '0'),
                                (others => '0'),
                                (others => '0'),
                                (others => '0'));

  constant ZERO_BMSG : BMSG_T := ('0',
                                  (others => '0'),
                                  (others => '0'),
                                  (others => '0'),
                                  (others => '0'),
                                  (others => '0'));
constant ZERO_c : cacheline := ('0',
                                                                    (others => '0'),
                                                                    (others => '0'),
                                                                    (others => '0'),
                                                                    (others => '0'),
                                                                    (others => '0'),
                                                                    (others => '0'));
  
--  subtype MSG_T is std_logic_vector(MSG_WIDTH-1 downto 0);
  subtype CMD_T is std_logic_vector(CMD_WIDTH-1 downto 0);
  subtype ADR_T is std_logic_vector(ADR_WIDTH-1 downto 0);
  subtype DAT_T is std_logic_vector(DAT_WIDTH-1 downto 0);

--  subtype WMSG_T is std_logic_vector(WMSG_WIDTH-1 downto 0);
--  subtype BMSG_T is std_logic_vector(BMSG_WIDTH-1 downto 0); -- bus message
  subtype DEST_T is std_logic_vector(2 downto 0);

--  constant ZERO_MSG : MSG_T := (others => '0');
--  constant ZERO_BMSG : BMSG_T := (others => '0');
  
  
  constant READ_CMD  : CMD_T := "01000000"; --x"40";
  constant WRITE_CMD : CMD_T := "10000000"; --x"80";
  constant PWRUP_CMD : CMD_T := "00100000"; --x"20";
  constant PWRDN_CMD : CMD_T := "00010000"; --x"10";
  constant ZEROS_CMD : CMD_T := x"00";
  constant ONES_CMD : CMD_T  := x"ff";

  constant ZERO_480 : std_logic_vector(479 downto 0) := (others => '0');

  constant ZERO_TAG, ZERO_ID : std_logic_vector(7 downto 0) := x"00";
  constant ZEROS32, ZERO_ADR, ZERO_DAT : std_logic_vector(31 downto 0) := (others => '0');
  constant ONES32 : std_logic_vector(31 downto 0) := (others => '1');

  -- constant VAL_MASK : MSG_T := "1" & ZEROS_CMD & ZEROS32 & ZEROS32;
  -- constant CMD_MASK : MSG_T := "0" & ONES_CMD & ZEROS32 & ZEROS32;
  -- constant ADR_MASK : MSG_T := "0" & ZEROS_CMD & ONES32 & ZEROS32;
  -- constant DAT_MASK : MSG_T := "0" & ZEROS_CMD & ZEROS32 & ONES32;

  subtype IPTAG_T is std_logic_vector(7 downto 0);
  constant CPU0_TAG  : IPTAG_T := x"00";
  constant CPU1_TAG  : IPTAG_T := x"01";
  constant GFX_TAG   : IPTAG_T := x"02";
  constant UART_TAG  : IPTAG_T := x"03";
  constant USB_TAG   : IPTAG_T := x"04";
  constant AUDIO_TAG : IPTAG_T := x"05";
  
  -- TODO ips should b in order but b careful changing as it may break stg else!

 

  --constant TOMEM_ADR : ADR_T := x"80"; --1XXX...
  --constant TOGFX_ADR : ADR_T := x"00"; --X00X...
  --constant TOUART_ADR : ADR_T := x"20"; --X01X...
  --constant TOUSB_ADR : ADR_T := x"40"; --X10X...
  --constant TOAUDIO_ADR : ADR_T := x"60"; --X11X...  

  
  -- indices
  --constant MEM_FOUND_IDX : positive := 56;
  constant MSG_VAL_IDX : natural := 72;
  constant MSG_CMD_IDX : natural := 64;
  constant MSG_ADR_IDX : natural := 32;  
  constant MSG_DAT_IDX : natural := 0;

  constant seed_set: positive := 13;
  -- PWRCMD is:
  --  a total of 73 bits:
  --     valid_bit & cmd[8] & src[8] & dst[8] & unused[24] 
  
end defs;
