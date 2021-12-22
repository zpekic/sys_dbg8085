--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package sys_dbg8085_package is

subtype byte is std_logic_vector(7 downto 0);
type rom32x8 is array(0 to 31) of byte;
type rom16x8 is array(0 to 15) of byte;

impure function get_byte(char: in character) return byte;

--
constant hex2char: rom16x8 := (
	get_byte('0'),	
	get_byte('1'),
	get_byte('2'), 	
	get_byte('3'),	
	get_byte('4'),	
	get_byte('5'),	
	get_byte('6'),	
	get_byte('7'),
	get_byte('8'),	
	get_byte('9'),	
	get_byte('A'),	
	get_byte('B'),	
	get_byte('C'),	
	get_byte('D'),	
	get_byte('E'),	
	get_byte('F')
);

end sys_dbg8085_package;

package body sys_dbg8085_package is

impure function get_byte(char: in character) return byte is
begin
	return std_logic_vector(to_unsigned(natural(character'pos(char)), 8));
end get_byte;
 
end sys_dbg8085_package;
