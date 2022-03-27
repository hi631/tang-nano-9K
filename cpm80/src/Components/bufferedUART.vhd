-- 6850 ACIA COMPATIBLE UART WITH HARDWARE INPUT BUFFER AND HANDSHAKE

-- This file is copyright by Grant Searle 2013
-- You are free to use this file in your own projects but must never charge for it nor use it without
-- acknowledgement.
-- Please ask permission from Grant Searle before republishing elsewhere.
-- If you use this file or any part of it, please add an acknowledgement to myself and
-- a link back to my main web site http://searle.hostei.com/grant/    
-- and to the "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- Please check on the above web pages to see if there are any updates before using this file.
-- If for some reason the page is no longer available, please search for "Grant Searle"
-- on the internet to see if I have moved to another web hosting service.
--
-- Grant Searle
-- eMail address available on my main web page link above.

-- ADD reset UART

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;

entity bufferedUART is
	port (
		clk     : in std_logic;
		n_wr    : in  std_logic;
		n_rd    : in  std_logic;
		regSel  : in  std_logic;
		dataIn  : in  std_logic_vector(7 downto 0);
		dataOut : out std_logic_vector(7 downto 0);
		n_int   : out std_logic; 
		rxClock : in  std_logic; -- 16 x baud rate
		txClock : in  std_logic; -- 16 x baud rate
		rxd     : in  std_logic;
		txd     : out std_logic;
		n_rts   : out std_logic :='0';
		n_cts   : in  std_logic; 
		n_dcd   : in  std_logic
   );
end bufferedUART;

architecture rtl of bufferedUART is

signal n_int_internal   : std_logic := '1';
signal statusReg : std_logic_vector(7 downto 0) := (others => '0'); 
signal controlReg : std_logic_vector(7 downto 0) := "00000000";
 
signal rxBitCount: std_logic_vector(3 DOWNTO 0); 
signal txBitCount: std_logic_vector(3 DOWNTO 0); 

signal rxClockCount: std_logic_vector(5 DOWNTO 0); 
signal txClockCount: std_logic_vector(5 DOWNTO 0); 

signal rxCurrentByteBuffer: std_logic_vector(7 DOWNTO 0); 
signal txBuffer: std_logic_vector(7 DOWNTO 0); 

signal txByteLatch: std_logic_vector(7 DOWNTO 0); 

-- Use bit toggling to determine change of state
-- If byte sent over serial, change "txByteSent" flag from 0-->1, or from 1-->0
-- If byte written to tx buffer, change "txByteWritten" flag from 0-->1, or from 1-->0
-- So, if "txByteSent" = "txByteWritten" then no new data to be sent
-- otherwise (if "txByteSent" /= "txByteWritten") then new data available ready to be sent
signal txByteWritten : std_logic := '0';
signal txByteSent : std_logic := '0';

type serialStateType is ( idle, dataBit, stopBit );
signal rxState : serialStateType;
signal txState : serialStateType;

signal reset : std_logic := '0';

type rxBuffArray is array (0 to 15) of std_logic_vector(7 downto 0);
signal rxBuffer : rxBuffArray;

signal rxInPointer: integer range 0 to 63 :=0;
signal rxReadPointer: integer range 0 to 63 :=0;
signal rxBuffCount: integer range 0 to 63 :=0;

signal rxFilter : integer range 0 to 50; 

signal rxdFiltered : std_logic := '1';

begin
	-- minimal 6850 compatibility
	statusReg(0) <= '0' when rxInPointer=rxReadPointer else '1';
	statusReg(1) <= '1' when txByteWritten=txByteSent else '0';
	statusReg(2) <= n_dcd;
	statusReg(3) <= n_cts;
	statusReg(7) <= not(n_int_internal);
	  
	-- interrupt mask
	n_int <= n_int_internal;
	n_int_internal <= '0' when (rxInPointer /= rxReadPointer) and controlReg(7)='1'
	         else '0' when (txByteWritten=txByteSent) and controlReg(6)='0' and controlReg(5)='1'
				else '1';

-- raise (inhibit) n_rts when buffer over half-full
--	6850 implementatit = n_rts <= '1' when controlReg(6)='1' and controlReg(5)='0' else '0';

	rxBuffCount <= 0  when reset = '1'
		else 0 + rxInPointer - rxReadPointer when rxInPointer >= rxReadPointer
		else 16 + rxInPointer - rxReadPointer;

	-- RTS with hysteresis
	-- enable flow if less than 2 characters in buffer
	-- stop flow if greater that 8 chars in buffer (to allow 8 byte overflow)
	process (clk)
	begin
		if falling_edge(clk) then
			if rxBuffCount<2 then
				n_rts <= '0';
			end if;
			if rxBuffCount>8 then
				n_rts <= '1';
			end if;
		end if;
	end process;
		
--	n_rts <= '1' when rxBuffCount > 24 else '0';
	
	-- control reg
	--     7               6                     5              4          3        2         1         0
	-- Rx int en | Tx control (INT/RTS) | Tx control (RTS) | ignored | ignored | ignored | reset A | reset B
	--             [        0                   1         ] = RTS LOW
	--                                                                             RESET = [  1         1  ]

	-- status reg
	--     7              6                5         4          3        2         1         0
	--    irq   |   parity error      | overrun | frame err | n_cts  | n_dcd |  tx empty | rx full
   --            always 0 (no parity)    n/a        n/a
	
	-- write of xxxxxx11 to control reg will reset
	reset <= '1' when n_wr = '0' and dataIn(1 downto 0) = "11" and regSel = '0' else '0';


	-- RX de-glitcher - important because the FPGA is very sensistive
	-- Filtered RX will not switch low to high until there is 50 more high samples than lows
	-- hysteresis will then not switch high to low until there is 50 more low samples than highs.
	-- Introduces a minor (1uS) delay with 50MHz clock
	-- However, then makes serial comms 100% reliable
	process (clk)
	begin
		if falling_edge(clk) then
			if rxd = '1' and rxFilter=50 then
				rxdFiltered <= '1';
			end if;
			if rxd = '1' and rxFilter /= 50 then
				rxFilter <= rxFilter+1;
			end if;
			if rxd = '0' and rxFilter=0 then
				rxdFiltered <= '0';
			end if;
			if rxd = '0' and rxFilter/=0 then
				rxFilter <= rxFilter-1;
			end if;
		end if;
	end process;
	
	process( n_rd )
	begin
		if falling_edge(n_rd) then -- Standard CPU - present data on leading edge of rd
			if regSel='1' then
				dataOut <= rxBuffer(rxReadPointer);
				if rxInPointer /= rxReadPointer then
					if rxReadPointer < 15 then
						rxReadPointer <= rxReadPointer+1;
					else
						rxReadPointer <= 0;
					end if;
				end if;
			else
				dataOut <= statusReg;
			end if;
		end if;
	end process;

	process( n_wr )
	begin
		if rising_edge(n_wr) then -- Standard CPU - capture data on trailing edge of wr
			if regSel='1' then
				if txByteWritten=txByteSent then
					txByteWritten <= not txByteWritten;
				end if;
				txByteLatch <= dataIn;
			else
				controlReg <= dataIn;
			end if;
		end if;
	end process;

	process( rxClock , reset )
	begin
		if reset='1' then
			rxState <= idle;
			rxBitCount<=(others=>'0');
			rxClockCount<=(others=>'0');

			rxInPointer<=0;
			rxInPointer<=0;

		elsif falling_edge(rxClock) then
			case rxState is
			when idle =>
				if rxdFiltered='1' then -- high so idle
					rxBitCount<=(others=>'0');
					rxClockCount<=(others=>'0');
				else -- low so in start bit
					if rxClockCount= 7 then -- wait to half way through bit
						rxClockCount<=(others=>'0');
						rxState <=dataBit;
					else
						rxClockCount<=rxClockCount+1;
					end if;
				end if;
			when dataBit =>
				if rxClockCount= 15 then -- 1 bit later - sample
					rxClockCount<=(others=>'0');
					rxBitCount <=rxBitCount+1;
					rxCurrentByteBuffer <= rxdFiltered & rxCurrentByteBuffer(7 downto 1);
					if rxBitCount= 7 then -- 8 bits read - handle stop bit
						rxState<=stopBit;
				end if;
				else
					rxClockCount<=rxClockCount+1;
				end if;
			when stopBit =>
				if rxClockCount= 15 then
					rxBuffer(rxInPointer) <= rxCurrentByteBuffer;
					if rxInPointer < 15 then
						rxInPointer <= rxInPointer+1;
					else
						rxInPointer <= 0;
					end if;
					rxClockCount<=(others=>'0');
					rxState <=idle;
				else
					rxClockCount<=rxClockCount+1;
				end if;
			end case;
		end if;              
	end process;

	process( txClock , reset )
	begin
		if reset='1' then
			txState <= idle;
			txBitCount<=(others=>'0');
			txClockCount<=(others=>'0');
			txByteSent <= '0';

		elsif falling_edge(txClock) then
			case txState is
			when idle =>
				txd <= '1';
				if (txByteWritten /= txByteSent) and n_cts='0' and n_dcd='0' then
					txBuffer <= txByteLatch;
					txByteSent <= not txByteSent;
					txState <=dataBit;
					txd <= '0'; -- start bit
					txBitCount<=(others=>'0');
					txClockCount<=(others=>'0');
				end if;
			when dataBit =>
				if txClockCount= 15 then -- 1 bit later
					txClockCount<=(others=>'0');
					if txBitCount= 8 then -- 8 bits read - handle stop bit
						txd <= '1';
						txState<=stopBit;
					else
						txd <= txBuffer(0);
						txBuffer <= '0' & txBuffer(7 downto 1); 
						txBitCount <=txBitCount+1;
					end if;
				else
					txClockCount<=txClockCount+1;
				end if;
			when stopBit =>
				if txClockCount= 15 then
					txState <=idle;
				else
					txClockCount<=txClockCount+1;
				end if;
			end case;
		end if;              
	end process;
 end rtl;
