-- Two processes for accepting an address from a 
-- pocketscan and transforming it to an address for up to 4 * 64 ch UT ring

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;

entity FSM is
  port (Clock, ResetIn,Din,Topbit: in STD_LOGIC;
        Dout,SclkOut,ResetOut: out STD_LOGIC);
end;

architecture RTL of FSM is
    
constant  MAXCOUNT:  integer:= 32;
constant  CLOCKPULSES:  integer:= 33;

signal shiftregister, dataregister: std_logic_vector(159 downto 0) :=(others=>'0');
signal zeroes: std_logic_vector(39 downto 0) :=(others=>'0');
signal ones: std_logic_vector(39 downto 0) :=(others=>'1');
signal count: Integer  ;
signal countout: Integer  ;
signal incounter: Integer ;
signal outclockcounter: Integer ;
signal testdata,SclkInt : std_logic;
signal done, clockedin: boolean;
begin

-- Reset data on reset signal
-- Clock in 256 values of data
clockin: process(ResetIn,Clock,dataregister,done,incounter)
begin
	if ResetIn ='0' then 
		dataregister <=(others=>'0');
		shiftregister <= dataregister;
		incounter<=0;
		clockedin<= false;
		
	--Is the clockout process done?
	
	elsif rising_edge(Clock) then
		if done= true then
			dataregister <=(others=>'0');
			shiftregister <= dataregister;
		
		elsif clockedin=false then
			incounter<=incounter+1;
			dataregister <= Din & dataregister(159 downto 1); -- Shift inn one new value per clock, shift out first element in array
			
			
			--When the entire signal has arrived, process it and reshuffle the numbers before clocking it out
			if incounter=160 then	
				clockedin <=true;
				
				if  dataregister(122)='1' or dataregister(123)='1' or dataregister(124)='1'  then --Check to see if first bit is high or low. Must check several due to oversampling
					if Topbit ='1' then
						shiftregister<=   dataregister(159 downto 120)  & zeroes & zeroes & zeroes;	
					else
						shiftregister<=   zeroes & zeroes & dataregister(159 downto 130) & "1111111111" & zeroes ;	
					end if;
				
				elsif  dataregister(82)='1' or dataregister(83)='1' or dataregister(84)='1' then
					if Topbit ='1' then 
						shiftregister<= dataregister(119 downto 95) & "111110000011111"  & zeroes & zeroes & zeroes;
					else
						shiftregister<= zeroes & zeroes &  dataregister(119 downto 95) & "111110000011111"  & zeroes ;
					end if;
				
				elsif dataregister(42)='1' or dataregister(43)='1' or dataregister(44)='1'  then
					if Topbit ='1' then
						shiftregister<=  zeroes & dataregister(79 downto 40)  & zeroes & zeroes;
					else
						shiftregister<=  zeroes & zeroes &  zeroes & dataregister(79 downto 40) ;
					end if;
				else
					if Topbit ='1' then 
						shiftregister<=  zeroes & dataregister(39 downto 15) & "111110000011111"   & zeroes & zeroes;
					else
						shiftregister<=  zeroes & zeroes &  zeroes(39 downto 0) & dataregister(39 downto 15) & "111110000011111"  ;
					end if;
				end if;
			end if;
		end if;
  	end if;
end process clockin;


clockout: process(ResetIn,Clock,done,outclockcounter)
begin

	if rising_edge(clock) then
	if ResetIn ='0' then 
		ResetOut<='0';
		SclkInt<='1';
		count <= 0;
		countout<=0;
		done <=false;
		outclockcounter<=0;
	end if;


	if done = false  and clockedin = true then
					
					if outclockcounter = 0 then
						SclkInt<='0';
						outclockcounter<=outclockcounter+1;
						
					elsif outclockcounter = MAXCOUNT/2 and done=false  then				
						SclkInt<='1';
						outclockcounter<=outclockcounter+1;
						ResetOut<='1';
						count<=count+1;
						testdata<=shiftregister(count*5-3);				
						
					elsif  outclockcounter = 3*(MAXCOUNT/4) and done=false  then
							testdata<=shiftregister(count*5-3);
							outclockcounter<=outclockcounter+1;
										
					elsif outclockcounter = MAXCOUNT then
						
						outclockcounter<=0;
						SclkInt<='0';
						testdata<=shiftregister(count*5-3);
					else 	
							if count = CLOCKPULSES then
								done <= true;
								SclkInt<='1';
							end if;
							outclockcounter<=outclockcounter+1;
					end if;	
					
					
 		end if;
  	end if;
end process clockout;
SclkOut<=SclkInt;
Dout<=testdata;

end;

