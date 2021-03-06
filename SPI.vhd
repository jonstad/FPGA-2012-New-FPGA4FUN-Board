library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;

entity SPI is
  port (Clock: in STD_LOGIC;
		CS_OUTPUT : out STD_LOGIC;
		ENABLE: in STD_LOGIC;
		SPIDONE : out STD_LOGIC;
		Din: in STD_LOGIC;
		DATA: out std_logic_vector(15 downto 0);
        SclkOut: out STD_LOGIC;
		Dout: out STD_LOGIC);
end SPI;

architecture RTL of SPI is
    constant  MAXCOUNT:  	integer	:= 32;
	signal Dataregister:	std_logic_vector(15 downto 0);
	signal csout: std_logic :='1';
	signal Counter: 		Integer ;
	signal outclockcounter: Integer :=0;
	signal SclkInt : 		std_logic :='1';
	
begin
clockgen: process(Clock, ENABLE, Counter,Din)
begin
	if ENABLE='1' then
		csout<='0';
		Counter <= 15;
		SclkInt<='1';
		SPIDONE <='1';
		--Dataregister <=(others=>'0');
		
	elsif rising_edge(Clock) then
		if ENABLE='0' then
					csout<='0';
					SPIDONE <= '0';
					if outclockcounter = 0 then
						SclkInt<='1';
						outclockcounter <= outclockcounter+1;
					elsif outclockcounter = MAXCOUNT/2 then
						if Counter >= 0 then 
							SclkInt <= '0';
						end if;
						outclockcounter <= outclockcounter+1;
					
					elsif outclockcounter = 3*(MAXCOUNT/4) then
						if Counter >= 0 then 
							SclkInt <= '0';
							Dataregister <= Din & Dataregister(15 downto 1) ;
							--Dataregister <= '0' & Dataregister(15 downto 1) ;
							Counter <= Counter - 1;
						end if;
						outclockcounter <= outclockcounter+1;
						
					elsif outclockcounter = MAXCOUNT then
						outclockcounter <= 0;
						SclkInt<='1';
						csout<='0';
					else 	
						outclockcounter<=outclockcounter+1;
					end if;	
			end if;
			DATA<=Dataregister;
  	end if;
end process clockgen;
--DATA<=Dataregister;
--DATA<="1100110010101111";
CS_OUTPUT<=csout;
SclkOut<=SclkInt;
end;

