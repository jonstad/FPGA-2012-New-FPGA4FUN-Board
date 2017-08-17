library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_std.all;

entity UartController is
	Port(Clock: in std_logic;
		UART1_Byte_received	: in std_logic;
		UART2_Byte_received	: in std_logic;
		Tx_Busy,Tx2_Busy	: in std_logic;
		RX_DATA_UART		: in std_logic_vector(7 downto 0);
		DATA_IN_TEMP		: in std_logic_vector(15 downto 0);
		DATA_IN_ENC			: in std_logic_vector(31 downto 0);
		RX_DATA_UART2		: in std_logic_vector(7 downto 0);
		WR_EN				: out std_logic;
		ENCODER_ADDRESS		: out std_logic;
		DATA_OUT			: out std_logic_vector(7 downto 0);
		CLK_DIV				: out std_logic_vector(15 downto 0);
		ENC_WRITE			: out std_logic;
		ENC_READ			: out std_logic;
		WR_EN2				: out std_logic;
		DATA_OUT2			: out std_logic_vector(7 downto 0));
end UartController;


architecture TransmittEncoder of UartController is
	constant  RECEIVEBUFFER_LENGTH : integer :=10;
	signal UART2ReceivedCounter : integer :=0;
	--signal  UART1buffer,UART2buffer : std_logic_vector( 0 to 79);
	signal  UART1buffer,UART2buffer : std_logic_vector(79 downto 0);
	signal uarttest : std_logic_vector(7 downto 0);
	signal  ENClatch : std_logic_vector(31 downto 0);
	constant  MAXCOUNT:  	integer	:= 15;
	constant  MAXCOUNTENC:  integer := 31;
	constant  MAXCOUNTINC:  integer := 79;
	signal DoneTemp,DoneENC1,DoneENC2,DoneINCLINO,DoneSendInclino,LoadENC1,LoadENC2: boolean := true;
	signal DoneUART :boolean := true;
	signal write_enc, read_enc : std_logic :='1';
	signal dout,dout2 : std_logic_vector(7 downto 0);
	signal wr_enint,wr_enint2,encaddress : std_logic :='1';
	signal packetnumber,packet: integer :=0;
		

	begin
		--Counter
		process (Clock,Tx_Busy,Tx2_Busy,UART1_Byte_received,UART2_Byte_received)
			begin	
				if rising_edge(Clock) then
					-- START UART2_Byte_received
					if Tx2_Busy ='0' or UART2_Byte_received ='0' then
						DoneUART <= false;
					end if;
					if Tx2_Busy = '1' and UART2_Byte_received = '1' and DoneUART = false then
						if UART2ReceivedCounter =0 then 
							--UART2buffer(0 to 7) <=RX_DATA_UART2;
							UART2buffer(7 downto 0) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;	
							DoneUART <= true;				
						elsif UART2ReceivedCounter =1 then 
							--UART2buffer(8 to 15 ) <=RX_DATA_UART2;
							UART2buffer(15 downto 8 ) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;	
							DoneUART <= true;	
						elsif UART2ReceivedCounter =2 then 
							--UART2buffer(16 to 23) <=RX_DATA_UART2;
							UART2buffer(23 downto 16) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;	
							DoneUART <= true;	
						elsif UART2ReceivedCounter =3 then 
							--UART2buffer( 24 to 31 ) <=RX_DATA_UART2;
							UART2buffer( 31 downto 24 ) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;	
							DoneUART <= true;	
						elsif UART2ReceivedCounter =4 then 
							--UART2buffer(32 to 39) <=RX_DATA_UART2;
							UART2buffer(39 downto 32) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;
							DoneUART <= true;		
						elsif UART2ReceivedCounter =5 then 
							--UART2buffer(40 to 47) <=RX_DATA_UART2;
							UART2buffer(47 downto 40) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;
							DoneUART <= true;		
						elsif UART2ReceivedCounter =6 then 
							--UART2buffer(48 to 55) <=RX_DATA_UART2;
							UART2buffer(55 downto 48) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;	
							DoneUART <= true;	
						elsif UART2ReceivedCounter =7 then 
							--UART2buffer(56 to 63) <=RX_DATA_UART2;
							UART2buffer(63 downto 56) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;	
							DoneUART <= true;	
						elsif UART2ReceivedCounter =8 then 
							--UART2buffer(64 to 71) <=RX_DATA_UART2;
							UART2buffer(71 downto 64) <=RX_DATA_UART2;
							UART2ReceivedCounter <=UART2ReceivedCounter +1;
							DoneUART <= true;		
						elsif UART2ReceivedCounter =9 then 
							--UART2buffer(72 to 79) <=RX_DATA_UART2;
							UART2buffer(79 downto 72) <=RX_DATA_UART2;
							UART2ReceivedCounter <=0;	
							DoneUART <= true;	
						end if;		
						--UART2buffer(8 to 15) <= "11111110";										
						--UART2buffer <="11111111111111101111111011111110111111101111111011111110111111101111111011111110";	
					end if;
					-- END UART2_Byte_received
					
					-- START UART1_Byte_received
					
					-- RETURN TEMPERATURE
					if UART1_Byte_received = '1' and RX_DATA_UART = "00110001" then
						DoneTemp <= false;
					-- RETURN ENCODER 1
					elsif UART1_Byte_received = '1' and RX_DATA_UART = "00110010" then
						DoneENC1 <= false;
					-- RETURN ENCODER 2
					elsif UART1_Byte_received = '1' and RX_DATA_UART = "00110011" then
						DoneENC2 <= false;					
					-- LOAD INCLINOMETER POSITION
					elsif UART1_Byte_received = '1' and RX_DATA_UART = "00110100" then
						wr_enint2<='0';
						DoneINCLINO <= false;
					-- RETURN INCLINOMETER POSITION
					elsif UART1_Byte_received = '1' and RX_DATA_UART = "00110101" then
						DoneSendInclino <= false;
					-- RETURN LOAD ENCODER 1 POSITION
					elsif UART1_Byte_received = '1' and RX_DATA_UART = "00110110" then
						LoadENC1 <= false;
					-- RETURN LOAD ENCODER 2 POSITION
					elsif UART1_Byte_received = '1' and RX_DATA_UART = "00110111" then
						LoadENC2 <= false;											
					
					
					-- TRANSMIT INCLINOMETER POSITION---------
--					elsif Tx_Busy='1' and DoneSendInclino = false then
--						if packetnumber = 0 then
--							wr_enint<='0';
--							dout <= std_logic_vector(UART2buffer(0 to 7));
--							packetnumber<=packetnumber+1;
--						elsif packetnumber = 1 then
--							dout<=std_logic_vector(UART2buffer(8 to 15));
--							packetnumber<=packetnumber+1;
--						elsif packetnumber = 2 then
--							dout<=std_logic_vector(UART2buffer(16 to 23));
--							packetnumber<=packetnumber+1;
--						elsif packetnumber = 3 then
--							dout<=std_logic_vector(UART2buffer(24 to 31));
--							packetnumber<=packetnumber+1;
--						elsif packetnumber = 4 then
--							dout<=std_logic_vector(UART2buffer(32 to 39));
--							packetnumber<=packetnumber+1;							
--						elsif packetnumber = 5 then
--							dout<=std_logic_vector(UART2buffer(40 to 47));
--							packetnumber<=packetnumber+1;							
--						elsif packetnumber = 6 then
--							dout<=std_logic_vector(UART2buffer(48 to 55));
--							packetnumber<=packetnumber+1;
--						elsif packetnumber = 7 then
--							dout<=std_logic_vector(UART2buffer(56 to 63));
--							packetnumber<=packetnumber+1;							
--						elsif packetnumber = 8 then
--							dout<=std_logic_vector(UART2buffer(64 to 71));
--							packetnumber<=packetnumber+1;							
--						elsif packetnumber = 9 then
--							dout<=std_logic_vector(UART2buffer(72 to 79));
--							packetnumber<=packetnumber+1;																													
--						elsif packetnumber = 80 then
--							dout<=std_logic_vector(TO_UNSIGNED(69,8));
--							packetnumber<=packetnumber+1;		
--						elsif packetnumber = 81 then
--							dout<=std_logic_vector(TO_UNSIGNED(69,8));
--							packetnumber<=packetnumber+1;
--						elsif packetnumber = 10 then	
--							packetnumber<=0;
--							DoneSendInclino <= true;
--							wr_enint<='1';																		
--						end if;		-- END if packetnumber <= MAXCOUNT then														
						
		
					-- TRANSMIT INCLINOMETER POSITION---------
					elsif Tx_Busy='1' and DoneSendInclino = false then
						if packetnumber <= 79 then
							wr_enint<='0';
								if UART2buffer(packetnumber) = '1' then
									dout<=std_logic_vector(TO_UNSIGNED(49,8));
								else 
									dout<=std_logic_vector(TO_UNSIGNED(48,8));
								end if;
							packetnumber<=packetnumber+1;
						elsif packetnumber = 80 then
							dout<=std_logic_vector(TO_UNSIGNED(69,8));
							packetnumber<=packetnumber+1;		
						elsif packetnumber = 81 then
							dout<=std_logic_vector(TO_UNSIGNED(69,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = 82 then	
							packetnumber<=0;
							DoneSendInclino <= true;
							wr_enint<='1';																		
						end if;		-- END if packetnumber <= MAXCOUNT then								
						
						
						
						
					-- TRANSMIT TEMPERATURE	
					elsif Tx_Busy='1' and DoneTemp = false then
						if packetnumber <= MAXCOUNT then
							wr_enint<='0';
							if packetnumber >= 0 then
								if DATA_IN_TEMP(packetnumber) = '1' then
									dout<=std_logic_vector(TO_UNSIGNED(49,8));
								else 
									dout<=std_logic_vector(TO_UNSIGNED(48,8));
								end if;
							end if;
							packetnumber<=packetnumber+1;	
						else 
							packetnumber<=0;
							DoneTemp <= true;
							wr_enint<='1';															
						end if;		-- END if packetnumber <= MAXCOUNT then
						
					-- TRANSMIT ENCODER 1
					elsif Tx_Busy='1' and DoneENC1 = false then	
						--TRANSMIT ENCODER 1
						if packetnumber <= MAXCOUNTENC then
							wr_enint<='0';
								if ENClatch(packetnumber) = '1' then
									dout<=std_logic_vector(TO_UNSIGNED(49,8));
								else 
									dout<=std_logic_vector(TO_UNSIGNED(48,8));
								end if;
							packetnumber<=packetnumber+1;
						
						elsif packetnumber = MAXCOUNTENC+1 then
							--dout<=std_logic_vector(TO_UNSIGNED(69,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = MAXCOUNTENC+2 then
							--dout<=std_logic_vector(TO_UNSIGNED(78,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;						
						elsif packetnumber = MAXCOUNTENC+3 then
							--dout<=std_logic_vector(TO_UNSIGNED(67,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;						
						elsif packetnumber = MAXCOUNTENC+4 then
							--dout<=std_logic_vector(TO_UNSIGNED(49,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = MAXCOUNTENC+5 then
							--dout<=std_logic_vector(TO_UNSIGNED(10,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;							
						elsif packetnumber = MAXCOUNTENC+6 then
							--dout<=std_logic_vector(TO_UNSIGNED(13,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = MAXCOUNTENC+7 then
							DoneENC1 <= true;
							wr_enint<='1';
							packetnumber<=0;
						end if; --END packetnumber <= MAXCOUNTENC then
					
					elsif Tx_Busy='1' and DoneENC2 = false then	
						--TRANSMIT ENCODER 2
						encaddress <= '1';
						read_enc   <= '0';	
						if packetnumber <= MAXCOUNTENC then
							wr_enint<='0';
								if ENClatch(packetnumber) = '1' then
									dout<=std_logic_vector(TO_UNSIGNED(49,8));
								else 
									dout<=std_logic_vector(TO_UNSIGNED(48,8));
								end if;
							packetnumber<=packetnumber+1;
						
						elsif packetnumber = MAXCOUNTENC+1 then
							--dout<=std_logic_vector(TO_UNSIGNED(69,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = MAXCOUNTENC+2 then
							--dout<=std_logic_vector(TO_UNSIGNED(78,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;						
						elsif packetnumber = MAXCOUNTENC+3 then
							--dout<=std_logic_vector(TO_UNSIGNED(67,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;						
						elsif packetnumber = MAXCOUNTENC+4 then
							--dout<=std_logic_vector(TO_UNSIGNED(49,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = MAXCOUNTENC+5 then
							--dout<=std_logic_vector(TO_UNSIGNED(10,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;							
						elsif packetnumber = MAXCOUNTENC+6 then
							--dout<=std_logic_vector(TO_UNSIGNED(13,8));
							dout<=std_logic_vector(TO_UNSIGNED(48,8));
							packetnumber<=packetnumber+1;
						elsif packetnumber = MAXCOUNTENC+7 then
							DoneENC2 <= true;
							wr_enint<='1';
							packetnumber <= 0;							
						end if;		-- END if packetnumber <= MAXCOUNTENC then		
					
					
					
					-- Transmit 0x01 to Inclinometer 
					elsif Tx_Busy='1' and DoneINCLINO = false then	
							--TRANSMIT INCLINO
							UART2ReceivedCounter<=0;
							if packet <= 1 then
								dout2<=X"01";
								--dout2<="00000001";
								packet <= 2;
								wr_enint2<='1';	
							else	
									DoneINCLINO <= true;
									packet <= 0;
							end if;	-- END if packet <= 1 then
						

					
					-- LOAD ENCODER 1 
					elsif Tx_Busy='1' and LoadENC1 = false then	
						if packet =0 then	
							encaddress <= '0';
							read_enc   <= '0';
							packet <= packet +1;
						elsif packet = 1 then
							ENClatch <= DATA_IN_ENC;
							packet <= packet +1;
							read_enc   <= '1';	
						elsif packet = 2 then
							write_enc <='0';
							packet <= packet +1;
						else
							write_enc<='1';
							LoadENC1 <= true;
							packet <= 0;
						end if;
						-- END if packet <= 1 then					


					-- LOAD ENCODER 2 
					elsif Tx_Busy='1' and LoadENC2 = false then	
						if packet =0 then	
							encaddress <= '1';
							read_enc   <= '0';
							packet <= packet +1;
						elsif packet = 1 then
							ENClatch <= DATA_IN_ENC;
							packet <= packet +1;
							read_enc   <= '1';	
						elsif packet = 2 then
							write_enc <='0';
							packet <= packet +1;
						else
							write_enc<='1';
							LoadENC2 <= true;
							packet <= 0;
						end if;
						-- END if packet <= 1 then	

					
					end if;
					-- END UART1_Byte_received					
					
					
				
			end if;  --END RISING EDGE CLOCK
		end process;
	
	ENCODER_ADDRESS<= encaddress;
	WR_EN		<=	wr_enint;
	WR_EN2		<=	wr_enint2;
	DATA_OUT	<=	dout;
	DATA_OUT2	<=	dout2;
	--ENC_WRITE   <=  read_enc; 
	ENC_READ 	<=  read_enc;
	ENC_WRITE	<=  write_enc;
	--CLK_DIV<="0000010000000000";
	--CLK_DIV<="0000111010011110";
	--CLK_DIV<="0000110110010000";
	CLK_DIV<="0000001101100100";	-- -- baud_rate = F(clk) / (ck_div * 3)		
end architecture;
				