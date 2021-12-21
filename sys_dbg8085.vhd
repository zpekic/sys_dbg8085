----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: zpekic@hotmail.com
-- 
-- Create Date: 08/29/2020 11:13:02 PM
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
use work.sys_dbg8085_package.all;

entity sys_dbg8085 is
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
				JB1: in std_logic;	-- GREEN S0
				JB2: in std_logic;	-- GREEN S1
				JB3: in std_logic;	-- GREEN IOM
				JB4: in std_logic;	-- GREEN ALE
				JB7: in std_logic;	-- YELLOW CLK
				JB8: in std_logic;	-- ORANGE RST -- reset out from CPU, high active
				JB9: in std_logic;	-- 
				JB10: in std_logic;	-- 
				JC1: in std_logic;	-- GRAY A8
				JC2: in std_logic;	-- GRAY A9
				JC3: in std_logic;	-- GRAY A10
				JC4: in std_logic;	-- GRAY A11
				JC7: in std_logic;	-- GRAY A12
				JC8: in std_logic;	-- GRAY A13
				JC9: in std_logic;	-- GRAY A14
				JC10: in std_logic;	-- GRAY A15
				-- breadboard signal connections
				BB1: inout std_logic;	-- WHITE AD0
				BB2: inout std_logic;	-- WHITE AD1
				BB3: inout std_logic;	-- WHITE AD2
				BB4: inout std_logic;	-- WHITE AD3
				BB5: inout std_logic;	-- WHITE AD4
				BB6: inout std_logic;	-- WHITE AD5
				BB7: inout std_logic;	-- WHITE AD6
				BB8: inout std_logic;	-- WHITE AD7
				BB9: out std_logic;		-- BLUE	RST7.5
				BB10: out std_logic;		-- PURPLE	READY
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
end sys_dbg8085;

architecture Structural of sys_dbg8085 is

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

component tracer is
	Generic (
			traceformat : rom32x8;
			flag2char:	rom16x8
			);
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           start : in  STD_LOGIC;
           continue : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (31 downto 0);
			  flags: in  STD_LOGIC_VECTOR (7 downto 0);
           tracechar : out  STD_LOGIC_VECTOR (7 downto 0);
           tracechar_send : out  STD_LOGIC;
			  trace_done: buffer STD_LOGIC);
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
constant switch_uart_rate: std_logic_vector(2 downto 0):= "111";-- is switch(5 downto 3);
constant switch_uart_mode: std_logic_vector(2 downto 0):= "000";-- is switch(2 downto 0);

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
signal led_debug, cpuclk_debug: std_logic_vector(31 downto 0);

--- frequency signals
signal freq_50M: std_logic_vector(11 downto 0);
alias debounce_clk: std_logic is freq_50M(9);
signal freq4096: std_logic;		
signal freq_2048: std_logic_vector(11 downto 0);
signal prescale_baud, prescale_power: integer range 0 to 65535;

-- input by switches and buttons
signal switch_old: std_logic_vector(7 downto 0);
signal switch, button: std_logic_vector(7 downto 0);

-- common 
signal baudrate_x1, baudrate_x2, baudrate_x4, baudrate_x8: std_logic;
signal hex_clk: std_logic; 
signal continue: std_logic;
signal tracechar: std_logic_vector(7 downto 0);
signal tracechar_send: std_logic;

-- UART output path
signal tx_ready: std_logic;

-- TTY output path
signal tty_sent: std_logic;
alias tty_clk: std_logic is freq_50M(2); --freq_2048(11);

-- 8085-like external bus (connected to physical pins)
alias S0: std_logic is JB1;
alias S1: std_logic is JB2;
alias IOM: std_logic is JB3;
alias ALE: std_logic is JB4;
alias CPUCLK: std_logic is JB7;
alias RST: std_logic is JB8;
alias nINTA: std_logic is JB9;
alias RST75: std_logic is BB9;
alias READY: std_logic is BB10;
signal ABUS: std_logic_vector(15 downto 0);
signal DBUS: std_logic_vector(7 downto 0);
--alias DOUT: std_logic_vector(7 downto 0) is switch;
signal SBUS: std_logic_vector(2 downto 0);

-- ready logic
signal rdy_ff, rdy_ff_clk, freeze, thaw: std_logic;

begin

-- no separate reset button
reset		<= '1' when (BTN = "1111") else RST;		-- pressing all btn will NOT reset 8085!
reset_sw	<= '0' when (switch = switch_old) else '1';

-- various clock signal generation
clockgen: sn74hc4040 port map (
			clock => CLK,	-- 100MHz crystal on Anvyl board
			reset => RESET,
			q => freq_50M
		);
		
prescale: process(CLK, baudrate_x8, freq4096)--, switch_uart_rate)
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
			switch_old <= switch;	-- watch for switches changing
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
      freq => CPUCLK,
		bcd => '1',
		add => X"00000001",
		cin => '1',
		cout => open,
      value => cpuclk_debug
	);

-- connect with external bus signals
ABUS(8) <= JC1;
ABUS(9) <= JC2;
ABUS(10) <= JC3;
ABUS(11) <= JC4;
ABUS(12) <= JC7;
ABUS(13) <= JC8;
ABUS(14) <= JC9;
ABUS(15) <= JC10;

--BB1 <= DOUT(0) when (nRD = '0') else 'Z';
DBUS(0) <= BB1;
--BB2 <= DOUT(1) when (nRD = '0') else 'Z';
DBUS(1) <= BB2;
--BB3 <= DOUT(2) when (nRD = '0') else 'Z';
DBUS(2) <= BB3;
--BB4 <= DOUT(3) when (nRD = '0') else 'Z';
DBUS(3) <= BB4;
--BB5 <= DOUT(4) when (nRD = '0') else 'Z';
DBUS(4) <= BB5;
--BB6 <= DOUT(5) when (nRD = '0') else 'Z';
DBUS(5) <= BB6;
--BB7 <= DOUT(6) when (nRD = '0') else 'Z';
DBUS(6) <= BB7;
--BB8 <= DOUT(7) when (nRD = '0') else 'Z';
DBUS(7) <= BB8;

-- capture low address bus as ALE goes low
on_ALE: process(ALE, DBUS)
begin
	if (falling_edge(ALE)) then
		ABUS(7 downto 0) <= DBUS;
--		"SBUS" is handy 3-bit indicator of the access;
		SBUS <= IOM & S1 & S0;
	end if;
end process;

on_CPUCLK: process(CPUCLK, SBUS, reset)
begin
	if (reset = '1') then 
		rdy_ff <= '1';
	else
		if (falling_edge(CPUCLK)) then
			if ((thaw and button(0)) = '1') then
				rdy_ff <= '1';
			else
				rdy_ff <= not switch(to_integer(unsigned(SBUS)));
			end if;
		end if;
	end if;
end process;
 
RST75 <= button(3);
READY <= rdy_ff;

--continue <= tx_ready when (DIP_B4 = '0') else tty_sent;
tr: tracer 
		Generic map (
			traceformat => (
				std_logic_vector(to_unsigned(natural(character'pos('>')), 8)), 	
				X"C0",	
				X"C1",	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)), 	
				X"C2",	
				X"C3",	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				X"C4",
				X"C5",	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				X"C6",
				X"C7",	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('A')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('=')), 8)), 	
				X"83",	
				X"82",	
				X"81",	
				X"80",	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),
				std_logic_vector(to_unsigned(natural(character'pos('D')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('=')), 8)),	
				X"85",	
				X"84",	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				X"0A",	-- LF	
				X"0D",	-- CR	
				X"00",	-- done
				--X"00",	-- done
				--X"00",	-- done
				--X"00",	-- done
				--X"00",	-- done
				--X"00",	-- done
				X"00",	-- done
				X"00",	-- done
				X"00",	-- done
				X"20"		-- last entry must be !=0
				),
			flag2char => (
				-- 0
				std_logic_vector(to_unsigned(natural(character'pos('M')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)), 	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('I')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('A')), 8)), 	
				-- 1
				std_logic_vector(to_unsigned(natural(character'pos('I')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('O')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('S')), 8)), 	
				std_logic_vector(to_unsigned(natural(character'pos('1')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('S')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos('0')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8)),	
				std_logic_vector(to_unsigned(natural(character'pos(' ')), 8))	
				)
		)
		Port map ( 
			reset => rdy_ff,
			clk => baudrate_x1,
			start => freq_2048(6),
			continue => not freq_2048(6),
			data(15 downto 0) => ABUS,
			data(23 downto 16) => DBUS,
--			data(16) => BB1,
--			data(17) => BB2,
--			data(18) => BB3,
--			data(19) => BB4,
--			data(20) => BB5,
--			data(21) => BB6,
--			data(22) => BB7,
--			data(23) => BB8,
			data(31 downto 24) => X"00", -- not used
			flags(7) => nINTA,	-- trick to display 2 characters per 1 flag
			flags(6) => nINTA,
			flags(5) => S0,
			flags(4) => S0,
			flags(3) => S1,
			flags(2) => S1,
			flags(1) => IOM,	
			flags(0) => IOM,	
			tracechar => tracechar,
			tracechar_send => tracechar_send,
			trace_done => thaw
		);

-- blinkenlights
LDT1G <= S1;
LDT1Y <= IOM;
LDT1R <= not rdy_ff;
LDT2G <= S0;
LDT2Y <= not IOM;
LDT2R <= not rdy_ff;

-----------------------------------------
-- UART output
-----------------------------------------
uart_tx: uart_par2ser Port map (
		reset => reset,
		txd_clk => baudrate_x1,
		send => tracechar_send,
		mode => switch_uart_mode,
		data => tracechar,
		ready => tx_ready,
		txd => PMOD_RXD
		);
		
-- echo to VGA	
tty: tty2vga Port map(
		reset => reset,
		tty_clk => tty_clk,
		ascii => tracechar,
		ascii_send => tracechar_send,		
		ascii_sent => tty_sent,
		cur_clk => freq_2048(10),	-- 2Hz
		vga_clk => freq_50M(1),		-- 25MHz
		vga_hsync => HSYNC_O,
		vga_vsync => VSYNC_O,
		vga_r => RED_O,
		vga_g => GREEN_O,
		vga_b => BLUE_O,
		-- debug
		debug => open
		);

-- 8 single LEDs
LED <= tracechar;

-- 7 seg LED debug display		

led_debug <= ("00000101" & ABUS & DBUS) when (rdy_ff = '0') else ("000000010000" & cpuclk_debug(31 downto 12)); 
	
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
