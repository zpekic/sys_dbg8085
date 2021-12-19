----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: zpekic@hotmail.com
-- 
-- Create Date: 11/29/2021 11:13:02 PM
-- Design Name: Test system for 8085 MiniMax board using microcoded components
-- Module Name: 
-- Project Name: 
-- Target Devices: https://store.digilentinc.com/anvyl-spartan-6-fpga-trainer-board/
-- Input devices: 
--
-- Tool Versions: ISE 14.7 (nt)
-- Description: https://hackaday.io/page/11558-in-circuit-testing-using-intel-hex-file-components
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.99 - Kinda works...
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sys_sbc8085 is
    Port ( 
	 			-- 100MHz on the Anvyl board
				CLK: in std_logic;
				-- Switches
				-- SW(2 downto 0) -- 
				-- SW(5 downto 3) -- 
				-- SW(7 downto 6) --  
				SW: in std_logic_vector(7 downto 0); 
				-- Push buttons 
				-- BTN0 - 
				-- BTN1 - 
				-- BTN2 - 
				-- BTN3 - 
				BTN: in std_logic_vector(3 downto 0); 
				-- 6 7seg LED digits
				SEG: out std_logic_vector(6 downto 0); 
				AN: out std_logic_vector(5 downto 0); 
				DP: out std_logic; 
				-- 8 single LEDs
				LED: out std_logic_vector(7 downto 0);
				--PMOD interface
				JA1: inout std_logic;	-- Connected to USB2UART
				JA2: inout std_logic;	-- Connected to USB2UART
				JA3: inout std_logic;	-- Connected to USB2UART
				JA4: inout std_logic;	-- Connected to USB2UART
				JB1: out std_logic;	-- GRAY 74F573.19 A0
				JB2: out std_logic;	-- GRAY 74F573.18 A1
				JB3: out std_logic;	-- GRAY 74F573.17 A2
				JB4: out std_logic;	-- GRAY 74F573.16 A3
				JB7: out std_logic;	-- GRAY 74F573.15 A4
				JB8: out std_logic;	-- GRAY 74F573.14 A5
				JB9: out std_logic;	-- GRAY 74F573.13 A6
				JB10: out std_logic;	-- GRAY 74F573.12 A7
				JC1: out std_logic;	-- WHITE 8085.21	A8
				JC2: out std_logic;	-- WHITE 8085.22	A9
				JC3: out std_logic;	-- WHITE 8085.23	A10
				JC4: out std_logic;	-- WHITE 8085.24	A11
				JC7: out std_logic;	-- WHITE 8085.25	A12
				JC8: out std_logic;	-- WHITE 8085.26	A13
				JC9: out std_logic;	-- WHITE 8085.27	A14
				JC10: out std_logic;	-- WHITE 8085.28	A15
				JD1: out std_logic;	-- PURPLE 8085.30 IO/M (low for memory access)
				-- breadboard signal connections
				BB1: inout std_logic;	-- BLUE 8085.12 AD0
				BB2: inout std_logic;	-- BLUE 8085.13 AD1
				BB3: inout std_logic;	-- BLUE 8085.14 AD2
				BB4: inout std_logic;	-- BLUE 8085.15 AD3
				BB5: inout std_logic;	-- BLUE 8085.16 AD4
				BB6: inout std_logic;	-- BLUE 8085.17 AD5
				BB7: inout std_logic;	-- BLUE 8085.18 AD6
				BB8: inout std_logic;	-- BLUE 8085.19 AD7
				BB9: out std_logic;		-- ORANGE	8085.31 nWR
				BB10: out std_logic;		-- YELLOW	8085.32 nRD
				--DIP switches
				DIP_B4, DIP_B3, DIP_B2, DIP_B1: in std_logic;
				DIP_A4, DIP_A3, DIP_A2, DIP_A1: in std_logic;
--				-- Hex keypad
				--KYPD_COL: out std_logic_vector(3 downto 0);
				--KYPD_ROW: in std_logic_vector(3 downto 0);
				-- SRAM --
				--SRAM_CS1: out std_logic;
				--SRAM_CS2: out std_logic;
				--SRAM_OE: out std_logic;
				--SRAM_WE: out std_logic;
				--SRAM_UPPER_B: out std_logic;
				--SRAM_LOWER_B: out std_logic;
				--Memory_address: out std_logic_vector(18 downto 0);
				--Memory_data: inout std_logic_vector(15 downto 0);
				-- Red / Yellow / Green LEDs
				LDT1G: out std_logic;
				LDT1Y: out std_logic;
				LDT1R: out std_logic;
				LDT2G: out std_logic;
				LDT2Y: out std_logic;
				LDT2R: out std_logic;
				-- VGA
				HSYNC_O: out std_logic;
				VSYNC_O: out std_logic;
				RED_O: out std_logic_vector(3 downto 0);
				GREEN_O: out std_logic_vector(3 downto 0);
				BLUE_O: out std_logic_vector(3 downto 0)
				-- TFT
--				TFT_R_O: out std_logic_vector(7 downto 0);
--				TFT_G_O: out std_logic_vector(7 downto 0);
--				TFT_B_O: out std_logic_vector(7 downto 0);
--				TFT_CLK_O: out std_logic;
--				TFT_DE_O: out std_logic;
--				TFT_DISP_O: out std_logic;
--				TFT_BKLT_O: out std_logic;
--				TFT_VDDEN_O: out std_logic;
          );
end sys_sbc8085;

architecture Structural of sys_sbc8085 is

-- Core components
component uart_ser2par is
    Port ( reset : in  STD_LOGIC;
           rxd_clk : in  STD_LOGIC;
           mode : in  STD_LOGIC_VECTOR (2 downto 0);
           char : out  STD_LOGIC_VECTOR (7 downto 0);
           ready : buffer  STD_LOGIC;
           valid : out  STD_LOGIC;
           rxd : in  STD_LOGIC);
end component;

component uart_par2ser is
    Port ( reset : in  STD_LOGIC;
			  txd_clk: in STD_LOGIC;
			  send: in STD_LOGIC;
			  mode: in STD_LOGIC_VECTOR(2 downto 0);
			  data: in STD_LOGIC_VECTOR(7 downto 0);
           ready : buffer STD_LOGIC;
           txd : out  STD_LOGIC);
end component;

component mem2hex is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  --
   		  debug: out STD_LOGIC_VECTOR(15 downto 0);
			  --
           nRD : out  STD_LOGIC;
           nBUSREQ : out  STD_LOGIC;
           nBUSACK : in  STD_LOGIC;
           nWAIT : in  STD_LOGIC;
           ABUS : out  STD_LOGIC_VECTOR (15 downto 0);
           DBUS : in  STD_LOGIC_VECTOR (7 downto 0);
           START : in  STD_LOGIC;
			  BUSY: out STD_LOGIC;
           PAGE : in  STD_LOGIC_VECTOR (7 downto 0);
           COUNTSEL : in  STD_LOGIC;
           TXDREADY : in  STD_LOGIC;
			  TXDSEND: out STD_LOGIC;
           CHAR : buffer  STD_LOGIC_VECTOR (7 downto 0));
end component;

component hex2mem is
    Port ( clk : in  STD_LOGIC;
           reset_in : in  STD_LOGIC;
			  reset_out: buffer STD_LOGIC;
			  reset_page: in STD_LOGIC_VECTOR(7 downto 0);
			  --
   		  debug: out STD_LOGIC_VECTOR(15 downto 0);
			  --
           nWR : out  STD_LOGIC;
           nBUSREQ : out  STD_LOGIC;
           nBUSACK : in  STD_LOGIC;
           nWAIT : in  STD_LOGIC;
           ABUS : out  STD_LOGIC_VECTOR (15 downto 0);
           DBUS : out  STD_LOGIC_VECTOR (7 downto 0);
			  BUSY: out STD_LOGIC;
			  --
			  HEXIN_READY: in STD_LOGIC;
			  HEXIN_CHAR: in STD_LOGIC_VECTOR (7 downto 0);
			  HEXIN_ZERO: buffer STD_LOGIC;
			  --
			  TRACE_ERROR: in STD_LOGIC;
			  TRACE_WRITE: in STD_LOGIC;
			  TRACE_CHAR: in STD_LOGIC;
           ERROR : buffer  STD_LOGIC;
           TXDREADY : in  STD_LOGIC;
			  TXDSEND: out STD_LOGIC;
           TXDCHAR : buffer  STD_LOGIC_VECTOR (7 downto 0));
end component;

-- Misc components
component sn74hc4040 is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           q : out  STD_LOGIC_VECTOR(11 downto 0));
end component;

component freqcounter is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           freq : in  STD_LOGIC;
           bcd : in  STD_LOGIC;
			  add: in STD_LOGIC_VECTOR(31 downto 0);
			  cin: in STD_LOGIC;
			  cout: out STD_LOGIC;
           value : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component debouncer8channel is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           signal_raw : in STD_LOGIC_VECTOR (7 downto 0);
           signal_debounced : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component sixdigitsevensegled is
    Port ( -- inputs
			  hexdata : in  STD_LOGIC_VECTOR (23 downto 0);
           digsel : in  STD_LOGIC_VECTOR (2 downto 0);
           showdigit : in  STD_LOGIC_VECTOR (5 downto 0);
           showdot : in  STD_LOGIC_VECTOR (5 downto 0);
           showsegments : in  STD_LOGIC;
			  -- outputs
           anode : out  STD_LOGIC_VECTOR (5 downto 0);
           segment : out  STD_LOGIC_VECTOR (7 downto 0)
			 );
end component;

component tty2vga is
    Port ( reset : in  STD_LOGIC;
           tty_clk : in  STD_LOGIC;
           ascii : in  STD_LOGIC_VECTOR (7 downto 0);
			  ascii_send: in STD_LOGIC;
			  ascii_sent: out STD_LOGIC;
			  cur_clk : in  STD_LOGIC;
           vga_clk : in  STD_LOGIC;
           vga_hsync : out  STD_LOGIC;
           vga_vsync : out  STD_LOGIC;
           vga_r : out  STD_LOGIC_VECTOR (3 downto 0);
           vga_g : out  STD_LOGIC_VECTOR (3 downto 0);
           vga_b : out  STD_LOGIC_VECTOR (3 downto 0);
			  -- debug only --
			  debug : out STD_LOGIC_VECTOR(31 downto 0)
			  );
end component;
	
type table_8x16 is array (0 to 7) of std_logic_vector(15 downto 0);
constant uartmode_debug: table_8x16 := (
	X"8001",	-- 8N1
	X"8001",
	X"8001",
	X"8001",
	X"8111",	-- 8, parity space, 1 stop
	X"8002",	-- 8, parity mark, 1 == 8, no parity, 2 stop
	X"8101",	-- 8, parity even, 1 stop
	X"8011"	-- 8, parity odd, 1 stop
);

constant clk_board: integer := 100000000;

constant sel_hexout: std_logic_vector(1 downto 0) := "00";
constant sel_hexin: std_logic_vector(1 downto 0) := "01";
constant sel_loopback0: std_logic_vector(1 downto 0) := "10";
constant sel_loopback1: std_logic_vector(1 downto 0) := "11";

type prescale_lookup is array (0 to 7) of integer range 0 to 65535;
constant prescale_value: prescale_lookup := (
		(clk_board / (16 * 600)),
		(clk_board / (16 * 1200)),
		(clk_board / (16 * 2400)),
		(clk_board / (16 * 4800)),
		(clk_board / (16 * 9600)),
		(clk_board / (16 * 19200)),
		(clk_board / (16 * 38400)),
		(clk_board / (16 * 57600))
	);

-- Connect to PmodUSBUART 
-- https://digilent.com/reference/pmod/pmodusbuart/reference-manual
alias PMOD_RTS: std_logic is JA1;	
alias PMOD_RXD: std_logic is JA2;
alias PMOD_TXD: std_logic is JA3;
alias PMOD_CTS: std_logic is JA4;	

-- 
signal reset, reset_btn, reset_sw: std_logic;

-- debug
signal showdigit, showdot: std_logic_vector(3 downto 0);
signal led_debug, led_sys, hexin_debug, hexout_debug, baudrate_debug, tty_debug: std_logic_vector(31 downto 0);
signal loopback_char, loopback_src: std_logic_vector(7 downto 0);
signal loopback_send: std_logic;

--- frequency signals
signal freq_50M: std_logic_vector(11 downto 0);
alias debounce_clk: std_logic is freq_50M(9);
signal freq4096: std_logic;		
signal freq_2048: std_logic_vector(11 downto 0);
signal prescale_baud, prescale_power: integer range 0 to 65535;

-- input by switches and buttons
signal switch_old: std_logic_vector(7 downto 0);
signal switch, button: std_logic_vector(7 downto 0);
alias switch_sel:	std_logic_vector(1 downto 0) is switch(7 downto 6);
alias switch_uart_rate: std_logic_vector(2 downto 0) is switch(5 downto 3);
alias switch_uart_mode: std_logic_vector(2 downto 0) is switch(2 downto 0);
signal btn_command, btn_window: std_logic_vector(3 downto 0);
signal page_sel: std_logic_vector(7 downto 0);
alias dip_iom: std_logic is DIP_B4; 
alias dip_traceerror: std_logic is DIP_B3; 
alias dip_tracewrite: std_logic is DIP_B2; 
alias dip_tracechar: std_logic is DIP_B1; 
alias dip_page16k3: std_logic is DIP_A4; 
alias dip_page16k2: std_logic is DIP_A3; 
alias dip_page16k1: std_logic is DIP_A2; 
alias dip_page16k0: std_logic is DIP_A1;

-- HEX common 
signal baudrate_x1, baudrate_x2, baudrate_x4, baudrate_x8: std_logic;
signal hex_clk: std_logic; 

-- HEX output path
signal tx_send, tx_ready: std_logic;
signal tx_char: std_logic_vector(7 downto 0);
signal hexout_char: std_logic_vector(7 downto 0);
signal hexout_busreq, hexout_busack: std_logic;
signal hexout_ready, hexout_send: std_logic;

-- HEX input path
signal rx_ready, rx_valid: std_logic; 
signal rx_char: std_logic_vector(7 downto 0);
signal hexin_ready, hexin_busy: std_logic;
signal hexin_char: std_logic_vector(7 downto 0);
signal hexin_debug_ready, hexin_debug_send: std_logic;
signal hexin_debug_char: std_logic_vector(7 downto 0);
signal hexin_busreq, hexin_busack: std_logic;

-- 8080-like external bus (connected to physical pins)
signal nRead, nWrite, nAccess: std_logic; 
signal ABUS: std_logic_vector(15 downto 0);
signal DIN, DOUT: std_logic_vector(7 downto 0);
-- Wait
signal nWait, wait_clk, wait_ena, wait_dis: std_logic;

-- TTY
signal tty_sent, tty_send: std_logic;
signal tty_char: std_logic_vector(7 downto 0);
alias tty_clk: std_logic is freq_50M(2); --freq_2048(11);


begin

-- no separate reset button
reset		<= '1' when (BTN = "1111") else '0';
reset_sw	<= '0' when (switch = switch_old) else '1';

on_freq4096: process(freq4096, switch)
begin
	if (rising_edge(freq4096)) then
		switch_old <= switch;
	end if;
end process;

-- various clock signal generation
clockgen: sn74hc4040 port map (
			clock => CLK,	-- 100MHz crystal on Anvyl board
			reset => RESET,
			q => freq_50M
		);
		
prescale: process(CLK, baudrate_x8, freq4096, switch_uart_rate)
begin
	if (rising_edge(CLK)) then
		if (prescale_baud = 0) then
			baudrate_x8 <= not baudrate_x8;
			prescale_baud <= prescale_value(to_integer(unsigned(switch_uart_rate)));
		else
			prescale_baud <= prescale_baud - 1;
		end if;
		if (prescale_power = 0) then
			freq4096 <= not freq4096;
			prescale_power <= (clk_board / (2 * 4096));
		else
			prescale_power <= prescale_power - 1;
		end if;
	end if;
end process;

powergen: sn74hc4040 port map (
			clock => freq4096,
			reset => RESET,
			q => freq_2048
		);
	
baudgen: sn74hc4040 port map (
			clock => baudrate_x8,
			reset => RESET,
			q(0) => baudrate_x4, 
			q(1) => baudrate_x2,
			q(2) => baudrate_x1,
			q(11 downto 3) => open		
		);	

	debounce_sw: debouncer8channel Port map ( 
		clock => debounce_clk, 
		reset => RESET,
		signal_raw => SW,
		signal_debounced => switch
	);

	debounce_btn: debouncer8channel Port map ( 
		clock => debounce_clk, 
		reset => RESET,
		signal_raw(7 downto 4) => "0000",
		signal_raw(3 downto 0) => BTN,
		signal_debounced => button
	);
	
counter: freqcounter Port map ( 
		reset => RESET,
      clk => freq_2048(11),
      freq => baudrate_x1,
		bcd => '1',
		add => X"00000001",
		cin => '1',
		cout => open,
      value => baudrate_debug
	);
		
---------------------------------------------------------------------------------------------			
-- 	SW7	SW6	Mode				TTY (VGA)			UART TX				7seg LED	
---------------------------------------------------------------------------------------------
--		0		0		sel_hexout		-				 		Generated HEX		mem2hex debug port (or bus if nWait = 0)
--		0		1		sel_hexin		Microcode trace	Echo UART RX		hex2mem debug port (or bus if nWait = 0)
--		1		0		sel_loopback0	Echo UART RX		Echo UART RX		Baudrate (decimal)
--		1		1		sel_loopback1	Echo UART RX		Echo UART RX		UART mode	
---------------------------------------------------------------------------------------------
nAccess <= hexin_busack and hexout_busack;

-- external memory
JB1 <= ABUS(0);
JB2 <= ABUS(1);
JB3 <= ABUS(2);
JB4 <= ABUS(3);
JB7 <= ABUS(4);
JB8 <= ABUS(5);
JB9 <= ABUS(6);
JB10 <= ABUS(7);
JC1 <= ABUS(8);
JC2 <= ABUS(9);
JC3 <= ABUS(10);
JC4 <= ABUS(11);
JC7 <= ABUS(12);
JC8 <= ABUS(13);
JC9 <= ABUS(14);
JC10 <= ABUS(15);
JD1 <= dip_iom;

BB1 <= DOUT(0) when (nWrite = '0') else 'Z';
DIN(0) <= BB1;
BB2 <= DOUT(1) when (nWrite = '0') else 'Z';
DIN(1) <= BB2;
BB3 <= DOUT(2) when (nWrite = '0') else 'Z';
DIN(2) <= BB3;
BB4 <= DOUT(3) when (nWrite = '0') else 'Z';
DIN(3) <= BB4;
BB5 <= DOUT(4) when (nWrite = '0') else 'Z';
DIN(4) <= BB5;
BB6 <= DOUT(5) when (nWrite = '0') else 'Z';
DIN(5) <= BB6;
BB7 <= DOUT(6) when (nWrite = '0') else 'Z';
DIN(6) <= BB7;
BB8 <= DOUT(7) when (nWrite = '0') else 'Z';
DIN(7) <= BB8;
				
BB9 	<= nWrite;	-- ORANGE	8085.31 nWR
BB10	<= nRead;	-- YELLOW	8085.32 nRD

-- HEX common	
page_sel <= dip_page16k3 & dip_page16k3 & dip_page16k2 & dip_page16k2 & dip_page16k1 & dip_page16k1 & dip_page16k0 & dip_page16k0;
hex_clk <= freq_50M(2);-- when (dip_hexclk = '1') else freq_50M(3); -- 6.25MHz or 12.5MHz

-- Wait signal
wait_ena <= not (reset or reset_sw or button(2) or wait_dis);
wait_dis <= not (button(1) or wait_ena);

wait_clk <= (not nAccess) when (nWait = '1') else button(3);
on_wait_clk: process(reset, wait_clk)
begin
	if (wait_dis = '1') then
		nWait <= '1';
	else
		if (rising_edge(wait_clk)) then 
			nWait <= not nWait; 
		end if;
	end if;
end process;

-- HEX output path
hexout_busack <= hexout_busreq when (switch_sel = sel_hexout) else '1';
LDT1G <= not (nRead);
LDT1R <= (not rx_valid) or reset;

hexout: mem2hex port map (
			clk => hex_clk,
			reset => reset,
			--
			debug => hexout_debug(15 downto 0),
			--
			nRD => nRead,
			nBUSREQ => hexout_busreq,
			nBUSACK => hexout_busack,
			nWAIT => nWait,
			ABUS => ABUS,
			DBUS => DIN,
			START => button(0),		
			BUSY => LDT1Y,			-- yellow LED when busy
			PAGE => page_sel,		-- select any 8k block using micro DIP switches
			COUNTSEL => '0',		-- 16 bytes per record
			TXDREADY => tx_ready,
			TXDSEND => hexout_send,
			CHAR => hexout_char
		);

-- HEX input path
hexin_busack <= hexin_busreq when (switch_sel = sel_hexin) else '1';
LDT2G <= not (nWrite);
LDT2Y <= hexin_busy;
--PMOD_CTS <= not hexin_busy;
hexin_ready <= rx_ready when (switch_sel = sel_hexin) else '0';
hexin_char <= rx_char when (switch_sel = sel_hexin) else X"00";
--hexin_debug_ready <= vga_sent when (switch_sel = sel_hexin) else '1';

hexin: hex2mem Port map (
			clk => hex_clk,
			reset_in => reset,
			reset_out => open,
			reset_page => page_sel, -- not really used but i8080-like system would reset at lowest 8k updated
			--
			debug => hexin_debug(15 downto 0),
			--
			nWR => nWrite,
			nBUSREQ => hexin_busreq,
			nBUSACK => hexin_busack,
			nWAIT => nWait,
			ABUS => ABUS,
			DBUS => DOUT,
			BUSY => hexin_busy,	-- yellow LED when busy
			--
			HEXIN_READY => hexin_ready,
			HEXIN_CHAR	=> hexin_char,
			HEXIN_ZERO => open,
			--
			TRACE_ERROR => dip_traceerror, 
			TRACE_WRITE => dip_tracewrite, 
			TRACE_CHAR	=> dip_tracechar, 
			ERROR => LDT2R,	-- red LED when error detected
			TXDREADY => tty_sent,
			TXDSEND => hexin_debug_send,
			TXDCHAR => hexin_debug_char
		);

----------------------------------------
-- UART input
----------------------------------------
uart_rx: uart_ser2par Port map ( 
		reset => reset, 
		rxd_clk => baudrate_x4,
		mode => switch_uart_mode,
		char => rx_char,
		ready => rx_ready,
		valid => rx_valid,
		rxd => PMOD_TXD
		);

-----------------------------------------
-- UART output
-----------------------------------------
with switch_sel select tx_send <=
	hexout_send when sel_hexout,
	rx_ready when others;
	
with switch_sel select tx_char <=
	hexout_char when sel_hexout,
	rx_char when others;
	
uart_tx: uart_par2ser Port map (
		reset => reset,
		txd_clk => baudrate_x1,
		send => tx_send,
		mode => switch_uart_mode,
		data => tx_char,
		ready => tx_ready,
		txd => PMOD_RXD
		);
		
-- echo to VGA
with switch_sel select tty_char <=
	hexin_debug_char when sel_hexin,	
	X"00" when sel_hexout,		-- not used
	rx_char when others;			-- echo incoming char

with switch_sel select tty_send <=
	hexin_debug_send when sel_hexin,	
	'0' when sel_hexout,			-- not used
	rx_ready when others;		-- echo incoming char
	
tty: tty2vga Port map(
		reset => reset,
		tty_clk => tty_clk,
		ascii => tty_char,
		ascii_send => tty_send,
		ascii_sent => tty_sent,
		cur_clk => freq_2048(10),	-- 2Hz
		vga_clk => freq_50M(1),		-- 25MHz
		vga_hsync => HSYNC_O,
		vga_vsync => VSYNC_O,
		vga_r => RED_O,
		vga_g => GREEN_O,
		vga_b => BLUE_O,
		-- debug
		debug => tty_debug
		);

-- 8 single LEDs
with switch_sel select LED <= 
	tx_char when sel_hexout,
	rx_char when others;

-- 7 seg LED debug display		
with switch_sel select led_sys <= 
	baudrate_debug when sel_loopback0,
	X"0000" & uartmode_debug(to_integer(unsigned(switch_uart_mode))) when sel_loopback1,
	hexout_debug when sel_hexout,
	hexin_debug when sel_hexin;

led_debug <= ("00000101" & ABUS & BB8 & BB7 & BB6 & BB5 & BB4 & BB3 & BB2 & BB1) when (nWait = '0') else led_sys; 
	
led6: sixdigitsevensegled Port map ( 
		-- inputs
		hexdata => led_debug(23 downto 0),
		digsel => freq_2048(3 downto 1),
		showdigit => "111111",
		showdot => led_debug(29 downto 24),
		showsegments => '1',
		-- outputs
		anode => AN,
		segment(6 downto 0) => SEG,
		segment(7) => DP
		);

end;
