----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:37:53 12/12/2021 
-- Design Name: 
-- Module Name:    tracer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use work.sys_dbg8085_package.all;

entity tracer is	 
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
end tracer;

architecture Behavioral of tracer is


signal charcnt, charcnt1, charcnt2: integer range 0 to 31;
signal tr: std_logic_vector(7 downto 0);
signal hex, flag: std_logic_vector(3 downto 0);
signal charclk: std_logic;

begin

tr <= traceformat(charcnt);
trace_done <= '1' when (tr = X"00") else '0'; -- hit the end of the record

with tr(7 downto 6) select tracechar <= 
	hex2char(to_integer(unsigned(hex))) when "10",
	flag2char(to_integer(unsigned(flag))) when "11",
	tr when others;

-- select hex digit based on data input
with tr(2 downto 0) select hex <=
	data(3 downto 0) when O"0",
	data(7 downto 4) when O"1",
	data(11 downto 8) when O"2",
	data(15 downto 12) when O"3",
	data(19 downto 16) when O"4",
	data(23 downto 20) when O"5",
	data(27 downto 24) when O"6",
	data(31 downto 28) when others;

-- select flag char based on data input
flag <= flags(to_integer(unsigned(tr(2 downto 0)))) & tr(2 downto 0);
	
-- trace output
charclk <= start when (trace_done = '1') else continue;

on_charclk: process(charclk, reset)
begin
	if (reset = '1') then
		charcnt <= 31;
	else
		if (rising_edge(charclk) and (trace_done = '0')) then
--			if (tr = X"00") then
--				charcnt <= 31; -- start again from first char in the record
--				trace_done <= '1';
--			else
				charcnt <= charcnt + 1;
--				trace_done <= '0';
--			end if;
		end if;
	end if;
end process;

-- 
tracechar_send <= '0' when (charcnt1 = charcnt2) else (not trace_done);

on_clk: process(clk, reset)
begin
	if (reset = '1') then
		charcnt1 <= 31;
		charcnt2 <= 31;
	else
		if (rising_edge(clk)) then
			charcnt1 <= charcnt;
			charcnt2 <= charcnt1;
		end if;
	end if;
end process;

end Behavioral;

