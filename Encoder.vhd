library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Encoder is
	Port(ENC_1A: in std_logic;
		 ENC_1B: in std_logic;
		 ENC_2A: in std_logic;
		 ENC_2B: in std_logic;
		 nChipSel: in std_logic;
		 nRead: in std_logic;
		 nWrite: in std_logic;
		ADDRESS: in std_logic; -- 0 ENC1 / 1 ENC2
		DATA_BUS: out std_logic_vector(31 downto 0));
end Encoder;

architecture quad_enc of Encoder is
	signal COUNT_1 : std_logic_vector(31 downto 0);
	signal COUNT_2 : std_logic_vector(31 downto 0);
	begin
	--Counter
	process (ENC_1A, ENC_1B,ENC_2A, ENC_2B, nChipSel,nWrite,ADDRESS)
		begin
		--Async reset
			if(nChipSel='0' and nWrite='0' and ADDRESS ='0') then
				COUNT_1 <= (others=>'0');
			elsif (nChipSel='0' and nWrite='0' and ADDRESS ='1') then
				COUNT_2 <= (others=>'0');
			else
				if(ENC_1A'event and ENC_1A ='1') then
					if (ENC_1B ='0') then
						COUNT_1 <= COUNT_1+1;
					else 
						COUNT_1 <= COUNT_1-1;
					end if;
				end if;
				if(ENC_2A'event and ENC_2A ='1') then
					if (ENC_2B ='0') then
						COUNT_2 <= COUNT_2+1;
					else 
						COUNT_2 <= COUNT_2-1;
					end if;
				end if;
			end if;
			
			if ADDRESS = '0' then
				DATA_BUS<= COUNT_1; --when (nChipSel='0' and nRead='0' and ADDRESS='0');
			else 			
				DATA_BUS<= COUNT_2; --when (nChipSel='0' and nRead='0' and ADDRESS='0');
			end if;
	end process;
	

end quad_enc;
		 