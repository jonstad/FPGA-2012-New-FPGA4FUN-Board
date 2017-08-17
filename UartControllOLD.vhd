library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;

entity UartController is
	Port(Clock: in std_logic;
		Transmit: in std_logic;
		Tx_Busy: in std_logic;
		RX_DATA_UART		: in std_logic_vector(7 downto 0);
		DATA_IN_TEMP		: in std_logic_vector(15 downto 0);
		DATA_IN_ENC1		: in std_logic_vector(31 downto 0);
		DATA_IN_ENC2		: in std_logic_vector(31 downto 0);
		WR_EN				: out std_logic;
		ENCODER_ADDRESS		: out std_logic;
		DATA_OUT			: out std_logic_vector(7 downto 0);
		CLK_DIV				: out std_logic_vector(15 downto 0);
		ENC_WRITE			: out std_logic;
		ENC_READ			: out std_logic);
end UartController;


architecture TransmittEncoder of UartController is
	constant  MAXCOUNT:  	integer	:= 12;
	constant  MAXCOUNTENC:  integer := 32;
	signal DoneTemp,DoneENC1,DoneENC2: boolean := false;
	signal write_enc, read_enc : std_logic :='1';
	signal dout : std_logic_vector(7 downto 0);
	signal wr_enint,encaddress : std_logic;
	signal packetnumber: integer :=0;
		begin
		--Counter
		process (Clock,Tx_Busy,Transmit)
			begin
				if Transmit = '1' and RX_DATA_UART = "00110001" then
					DoneTemp <= false;
				elsif Transmit = '1' and RX_DATA_UART = "00110010" then
					DoneENC1 <= false;
				elsif Transmit = '1' and RX_DATA_UART = "00110011" then
					DoneENC2 <= false;					
					
				elsif rising_edge(Clock) then
					
					
					-- TRANSMIT TEMPERATURE	
					if Tx_Busy='1' and DoneTemp = false then
						wr_enint<='0';
						if packetnumber <= MAXCOUNT then
							if packetnumber > 1 then
								if DATA_IN_TEMP(packetnumber) = '1' then
									dout<=std_logic_vector(TO_UNSIGNED(49,8));
								else 
									dout<=std_logic_vector(TO_UNSIGNED(48,8));
								end if;
							end if;
							packetnumber<=packetnumber+1;
						
						elsif packetnumber = MAXCOUNT+1 then
							dout<=std_logic_vector(TO_UNSIGNED(64,8));
							packetnumber<=packetnumber+1;
						
						elsif packetnumber = MAXCOUNT+2 then
							dout<=std_logic_vector(TO_UNSIGNED(10,8));
							packetnumber<=packetnumber+1;							
						
						elsif packetnumber = MAXCOUNT+3 then
							dout<=std_logic_vector(TO_UNSIGNED(13,8));
							packetnumber<=0;
							DoneTemp <= true;								
						end if;
						
					elsif Tx_Busy='1' and DoneENC1 = false then	
						--TRANSMIT ENCODER 1
							encaddress <= '0';
							read_enc   <= '0';
						if packetnumber <= MAXCOUNTENC then
								if DATA_IN_ENC1(packetnumber) = '1' then
									dout<=std_logic_vector(TO_UNSIGNED(49,8));
								else 
									dout<=std_logic_vector(TO_UNSIGNED(48,8));
								end if;
							packetnumber<=packetnumber+1;
						
						elsif packetnumber = MAXCOUNTENC+1 then
							dout<=std_logic_vector(TO_UNSIGNED(69,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = MAXCOUNTENC+2 then
							dout<=std_logic_vector(TO_UNSIGNED(78,8));
							packetnumber<=packetnumber+1;						
						elsif packetnumber = MAXCOUNTENC+3 then
							dout<=std_logic_vector(TO_UNSIGNED(67,8));
							packetnumber<=packetnumber+1;						
						elsif packetnumber = MAXCOUNTENC+4 then
							dout<=std_logic_vector(TO_UNSIGNED(49,8));
							packetnumber<=packetnumber+1;
						
						elsif packetnumber = MAXCOUNTENC+5 then
							dout<=std_logic_vector(TO_UNSIGNED(10,8));
							packetnumber<=packetnumber+1;							
						elsif packetnumber = MAXCOUNTENC+6 then
							dout<=std_logic_vector(TO_UNSIGNED(13,8));
							packetnumber<=0;
							DoneENC1 <= true;
							read_enc   <= '1';								
						end if;
					
				elsif Tx_Busy='1' and DoneENC2 = false then	
						--TRANSMIT ENCODER 2
						encaddress <= '1';
						read_enc   <= '0';	
						if packetnumber <= MAXCOUNTENC then
								if DATA_IN_ENC1(packetnumber) = '1' then
									dout<=std_logic_vector(TO_UNSIGNED(49,8));
								else 
									dout<=std_logic_vector(TO_UNSIGNED(48,8));
								end if;
							packetnumber<=packetnumber+1;
						
						elsif packetnumber = MAXCOUNTENC+1 then
							dout<=std_logic_vector(TO_UNSIGNED(69,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = MAXCOUNTENC+2 then
							dout<=std_logic_vector(TO_UNSIGNED(78,8));
							packetnumber<=packetnumber+1;						
						elsif packetnumber = MAXCOUNTENC+3 then
							dout<=std_logic_vector(TO_UNSIGNED(67,8));
							packetnumber<=packetnumber+1;						
						elsif packetnumber = MAXCOUNTENC+4 then
							dout<=std_logic_vector(TO_UNSIGNED(50,8));
							packetnumber<=packetnumber+1;
						
						elsif packetnumber = MAXCOUNTENC+5 then
							dout<=std_logic_vector(TO_UNSIGNED(10,8));
							packetnumber<=packetnumber+1;							
						elsif packetnumber = MAXCOUNTENC+6 then
							dout<=std_logic_vector(TO_UNSIGNED(13,8));
							packetnumber<=0;
							DoneENC2 <= true;	
							read_enc   <= '1';							
						end if;			
					
					
					
					elsif Tx_Busy='0' then
						--wr_enint<='1';
						
					end if;	
				end if;
		end process;
		ENCODER_ADDRESS<= encaddress;
	WR_EN		<=	wr_enint;
	DATA_OUT	<=	dout;
	--ENC_WRITE   <=  read_enc; 
	ENC_READ 	<=  read_enc;
	--CLK_DIV<="0000010000000000";
	--CLK_DIV<="0000111010011110";
	--CLK_DIV<="0000110110010000";
	CLK_DIV<="0000001101100100";	-- -- baud_rate = F(clk) / (ck_div * 3)		
end architecture;
				