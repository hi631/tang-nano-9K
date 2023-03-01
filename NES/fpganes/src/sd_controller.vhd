-- VHDL SD card interface
-- Reads and writes a single block of data as a data stream

-- Adapted from design by Steven J. Merrifield, June 2008
-- Read states are derived from the Apple II emulator by Stephen Edwards

-- This version of the code contains modifications copyright by Grant Searle 2013
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

-- updated by Rienk Koolstra to accept SDHC cards. Note: this implementation does not slow down the 
-- interface during the init phase. The standard requires a maximum clock of 400 KHz during this
-- phase, to allow for "older" cards (read MMC) I have found this slowdown to be unnecessary for
-- all cards I tested. I am clocking this interface at 50 MHz (25 MHz SPI clock) with solid
-- results, YMMV!


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sd_controller is
port (
	sdCS : out std_logic;
	sdMOSI : out std_logic;
	sdMISO : in std_logic;
	sdSCLK : out std_logic;
	n_reset : in std_logic;
	n_rd : in std_logic;
	n_wr : in std_logic;
	dataIn : in std_logic_vector(7 downto 0);
	dataOut : out std_logic_vector(7 downto 0);
	status  : out std_logic_vector(7 downto 0);
	regAddr : in std_logic_vector(2 downto 0);
	clk : in std_logic;	-- twice the spi clk;
	driveLED : out std_logic := '1'
);

end sd_controller;

architecture rtl of sd_controller is
type states is (
	rst,
	init,
	cmd0,
	regreq,
	cmd55,
	acmd41,
	poll_cmd,
	cmd58,
	cardsel,
	stby,	-- wait for read or write pulse
	read_block_cmd,
	read_block_wait,
	read_block_data,
	send_cmd,
	send_regreq,
	receive_ocr_wait,
	receive_ocr,
	receive_byte_wait,
	receive_byte,
	write_block_cmd,
	write_block_init,		-- initialise write command
	write_block_data,		-- loop through all data bytes
	write_block_byte,		-- send one byte
	write_block_wait		-- wait until not busy
);


-- one start byte, plus 512 bytes of data, plus two FF end bytes (CRC)
constant write_data_size : integer := 515;


signal state, return_state : states;
signal sclk_sig : std_logic := '0';
signal cmd_out : std_logic_vector(55 downto 0);
signal recv_data : std_logic_vector(7 downto 0);
signal ocr_data : std_logic_vector(39 downto 0);

--signal status : std_logic_vector(7 downto 0) := x"00";

signal block_read : std_logic := '0';
signal block_write : std_logic := '0';
signal block_start_ack : std_logic := '0';

signal cmd_mode : std_logic := '1';
signal response_mode : std_logic := '1';
signal data_sig : std_logic_vector(7 downto 0) := x"00";
signal din_latched : std_logic_vector(7 downto 0) := x"00";
signal dout : std_logic_vector(7 downto 0) := x"00";

signal sdhc : std_logic := '0';

signal sd_read_flag : std_logic := '0';
signal host_read_flag : std_logic := '0';

signal sd_write_flag : std_logic := '0';
signal host_write_flag : std_logic := '0';

signal init_busy : std_logic := '0';
signal block_busy : std_logic := '0';

signal address: std_logic_vector(31 downto 0) :=x"00000000";

signal led_on_count : integer range 0 to 200;

begin
	process(n_wr)
	begin
	-- SDSC byte address 0..8 (first 9 bits) always zero because each sector is 512 bytes
		if rising_edge(n_wr) then
			if sdhc = '0' then					-- SDSC card
				if regAddr = "010" then
					address(16 downto 9) <= dataIn;
				elsif regAddr = "011" then
					address(24 downto 17) <= dataIn;
				elsif regAddr = "100" then
					address(31 downto 25) <= dataIn(6 downto 0);
				end if;
			else							-- SDHC card
	-- SDHC block address. starts at bit 0
				if regAddr = "010" then
					address(7 downto 0) <= dataIn;		-- 128 k
				elsif regAddr = "011" then
					address(15 downto 8) <= dataIn;		-- 32 M
				elsif regAddr = "100" then
					address(23 downto 16) <= dataIn;	-- addresses upto 8 G
				end if;
			end if;
		end if;
	end process;

	dataOut <=
		dout when regAddr = "000"
	else status when regAddr = "001"
	else "00000000";

	process(n_wr)
	begin
		if rising_edge(n_wr) then
			if (regAddr = "000") and (sd_write_flag = host_write_flag) then
				din_latched <= dataIn;
				host_write_flag <= not host_write_flag;
			end if;
		end if;
	end process;

	process(n_rd)
	begin
		if rising_edge(n_rd) then
			if (regAddr = "000") and (sd_read_flag /= host_read_flag) then
				host_read_flag <= not host_read_flag;
			end if;
		end if;
	end process;

	process(n_wr, block_start_ack,init_busy)
	begin
		if init_busy='1' then
			block_read <= '0';
		elsif block_start_ack='1' then
			block_read <= '0';
		elsif rising_edge(n_wr) then
			if regAddr = "001" and dataIn = "00000000" then
				block_read <= '1';
			end if;
		end if;
	end process;

	process(n_wr, block_start_ack,init_busy)
	begin
		if init_busy='1' then
			block_write <= '0';
		elsif block_start_ack='1' then
			block_write <= '0';
		elsif rising_edge(n_wr) then
			if regAddr = "001" and dataIn = "00000001" then
				block_write <= '1';
			end if;
		end if;
	end process;

	process(clk,n_reset)
		variable byte_counter : integer range 0 to write_data_size;
		variable bit_counter : integer range 0 to 160;
	begin
		if (n_reset='0') then
			state <= rst;
			sclk_sig <= '0';
			sdCS <= '1';
		elsif rising_edge(clk) then

			case state is

			when rst =>
				sd_read_flag <= host_read_flag;
				sd_write_flag <= host_write_flag;
				sclk_sig <= '0';
				cmd_out <= (others => '1');
				byte_counter := 0;
				cmd_mode <= '1'; -- 0=data, 1=command
				response_mode <= '1';	-- 0=data, 1=command
				bit_counter := 160;
				sdCS <= '1';
				state <= init;

			when init =>		-- cs=1, send 80 clocks, cs=0
				init_busy <= '1';
				if (bit_counter = 0) then
					sdCS <= '0';
					state <= cmd0;
				else
					bit_counter := bit_counter - 1;
					sclk_sig <= not sclk_sig;
				end if;

			when cmd0 =>
				cmd_out <= x"ff400000000095";	-- GO_IDLE_STATE here, Select SPI
				bit_counter := 55;
				return_state <= regreq;
				state <= send_cmd;

			when regreq =>
				cmd_out <= x"ff48000001aa87";	-- SEND_IF_COND, VHS=0001 (bit 16-19)
				bit_counter := 55;
				return_state <= cmd55;
				state <= send_regreq;

			when cmd55 =>
				cmd_out <= x"ff770000000001";	-- APP_CMD
				bit_counter := 55;
				return_state <= acmd41;
				state <= send_cmd;

			when acmd41 =>
				cmd_out <= x"ff694000000077";	-- SD_SEND_OP_COND, HCS=1 (bit 30)
				bit_counter := 55;
				return_state <= poll_cmd;
				state <= send_cmd;

			when poll_cmd =>
				if (recv_data(0) = '0') then
					state <= cmd58;
				else
					state <= cmd55;
				end if;

			when cmd58 =>
				cmd_out <= x"ff7a00000000fd";	-- READ_OCR
				bit_counter := 55;
				return_state <= cardsel;
				state <= send_regreq;

			when cardsel =>
				if (ocr_data(31) = '0' ) then	-- power up not completed
					state <= cmd58;				-- repeat command
				else
					if (ocr_data(30) = '1' ) then	-- CCS bit
						sdhc <= '1';
					else
						sdhc <= '0';
					end if;
					state <= stby;
				end if;

			when stby =>
				sd_read_flag <= host_read_flag;
				sd_write_flag <= host_write_flag;
				sclk_sig <= '0';
				cmd_out <= (others => '1');
				data_sig <= (others => '1');
				byte_counter := 0;
				cmd_mode <= '1';		-- 0=data, 1=command
				response_mode <= '1';	-- 0=data, 1=command

				block_busy <= '0';
				init_busy <= '0';
				dout <= (others => '0');

				if (block_read = '1') then
					state <= read_block_cmd;
					block_start_ack <= '1';
				elsif (block_write='1') then
					state <= write_block_cmd;
					block_start_ack <= '1';
				else
					state <= stby;
				end if;

			when read_block_cmd =>
				block_busy <= '1';
				block_start_ack <= '0';
				cmd_out <= x"ff" & x"51" & address & x"ff";
				bit_counter := 55;
				return_state <= read_block_wait;
				state <= send_cmd;

			-- wait until data token read (= 11111110)
			when read_block_wait =>
				if (sclk_sig='0' and sdMISO='0') then
					state <= receive_byte;
					byte_counter := 513;	-- data plus crc
					bit_counter := 8;		-- ???????????????????????????????
					return_state <= read_block_data;
				end if;
				sclk_sig <= not sclk_sig;

			when read_block_data =>
				if (byte_counter = 1) then		-- crc byte 1 - ignore
					byte_counter := byte_counter - 1;
					return_state <= read_block_data;
					bit_counter := 7;
					state <= receive_byte;
				elsif (byte_counter = 0) then	-- crc byte 2 - ignore
					bit_counter := 7;
					return_state <= stby;
					state <= receive_byte;
				elsif (sd_read_flag /= host_read_flag) then
					state <= read_block_data;	-- stay here until previous byte read
				else
					byte_counter := byte_counter - 1;
					return_state <= read_block_data;
					bit_counter := 7;
					state <= receive_byte;
				end if;

			when send_cmd =>
				if (sclk_sig = '1') then		-- sending command
					if (bit_counter = 0) then	-- command sent
						state <= receive_byte_wait;
					else
						bit_counter := bit_counter - 1;
						cmd_out <= cmd_out(54 downto 0) & '1';
					end if;
				end if;
				sclk_sig <= not sclk_sig;

			when send_regreq =>
				if (sclk_sig = '1') then		-- sending command
					if (bit_counter = 0) then	-- command sent
						state <= receive_ocr_wait;
					else
						bit_counter := bit_counter - 1;
						cmd_out <= cmd_out(54 downto 0) & '1';
					end if;
				end if;
				sclk_sig <= not sclk_sig;

			when receive_ocr_wait =>
				if (sclk_sig = '0') then
					if (sdMISO = '0') then		-- wait for zero bit
						ocr_data <= (others => '0');
						bit_counter := 38;		-- already read bit 39
						state <= receive_ocr;
					end if;
				end if;
				sclk_sig <= not sclk_sig;

			when receive_ocr =>
				if (sclk_sig = '0') then
					ocr_data <= ocr_data(38 downto 0) & sdMISO;	-- read next bit
					if (bit_counter = 0) then
						state <= return_state;
					else
						bit_counter := bit_counter - 1;
					end if;
				end if;
				sclk_sig <= not sclk_sig;


			when receive_byte_wait =>
				if (sclk_sig = '0') then
					if (sdMISO = '0') then			-- wait for start of frame
						recv_data <= (others => '0');
						if (response_mode='0') then	-- data mode
							bit_counter := 3;		-- already read bits 7..4
						else						-- command mode
							bit_counter := 6;		-- already read bit 7
						end if;
						state <= receive_byte;
					end if;
				end if;
				sclk_sig <= not sclk_sig;

			when receive_byte =>
				if (sclk_sig = '0') then
					recv_data <= recv_data(6 downto 0) & sdMISO;	-- read next bit
					if (bit_counter = 0) then
						state <= return_state;

						-- if real data received then flag it (byte counter = 0 for both crc bytes)
						if return_state= read_block_data and byte_counter > 0 then
							sd_read_flag <= not sd_read_flag;
							dout <= recv_data;
						end if;
					else
						bit_counter := bit_counter - 1;
					end if;
				end if;
				sclk_sig <= not sclk_sig;

			when write_block_cmd =>
				block_busy <= '1';
				block_start_ack <= '0';
				cmd_mode <= '1';
				cmd_out <= x"ff" & x"58" & address & x"ff";	-- single block
				bit_counter := 55;
				return_state <= write_block_init;
				state <= send_cmd;

			when write_block_init =>
				cmd_mode <= '0';
				byte_counter := write_data_size;
				state <= write_block_data;

			when write_block_data =>
				if byte_counter = 0 then
					state <= receive_byte_wait;
					return_state <= write_block_wait;
					response_mode <= '0';
				else
					if ((byte_counter = 2) or (byte_counter = 1)) then
						data_sig <= x"ff";		-- two crc bytes
						bit_counter := 7;
						state <= write_block_byte;
						byte_counter := byte_counter - 1;
					elsif byte_counter = write_data_size then
						data_sig <= x"fe";		-- start byte, single block
						bit_counter := 7;
						state <= write_block_byte;
						byte_counter := byte_counter - 1;
					elsif host_write_flag /= sd_write_flag then -- only send if flag set
						data_sig <= din_latched;
						bit_counter := 7;
						state <= write_block_byte;
						byte_counter := byte_counter - 1;
						sd_write_flag <= not sd_write_flag;
					end if;
				end if;

			when write_block_byte =>
			if (sclk_sig = '1') then
					if bit_counter=0 then
						state <= write_block_data;
					else
						data_sig <= data_sig(6 downto 0) & '1';
						bit_counter := bit_counter - 1;
					end if;
				end if;
				sclk_sig <= not sclk_sig;

			when write_block_wait =>
				cmd_mode <= '1';
				response_mode <= '1';
				if sclk_sig='0' then
					if sdMISO='1' then
						state <= stby;
					end if;
				end if;
				sclk_sig <= not sclk_sig;

			when others =>
				state <= stby;
		end case;
	end if;
	end process;

	sdSCLK <= sclk_sig;
	sdMOSI <= cmd_out(55) when cmd_mode='1' else data_sig(7);

	status(7) <= '1' when host_write_flag=sd_write_flag else '0'; -- tx byte empty when equal
	status(6) <= '0' when host_read_flag=sd_read_flag else '1'; -- rx byte ready when not equal
	status(5) <= block_busy;
	status(4) <= init_busy;
	status(3) <= '0'; status(2) <= '0'; status(1) <= '0'; status(0) <= '0'; ----

	-- Make sure the drive LED is on for a visible amount of time
	process (clk, block_busy,init_busy)
	begin
		if block_busy='1' or init_busy = '1' then
				led_on_count <= 200; -- ensure on for at least 200ms (assuming 1MHz clk)
				driveLED <= '0';
		elsif (rising_edge(clk)) then
			if led_on_count>0 then
				led_on_count <= led_on_count-1;
				driveLED <= '0';
			else
				driveLED <= '1';
			end if;
		end if;
	end process;

end rtl;
