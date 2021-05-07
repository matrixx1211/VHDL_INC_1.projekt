-- uart.vhd: UART controller - receiving part
-- Author(s): 
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

-------------------------------------------------
ENTITY UART_RX IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		DIN : IN STD_LOGIC;
		DOUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
		DOUT_VLD : OUT STD_LOGIC := '0'
	);
END UART_RX;

-------------------------------------------------
ARCHITECTURE behavioral OF UART_RX IS
	SIGNAL ctr_c : STD_LOGIC_VECTOR (4 DOWNTO 0) := (OTHERS => '0');
	SIGNAL ctr_b : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL rx_en : STD_LOGIC;
	SIGNAL ctr_en : STD_LOGIC;
	SIGNAL valid : STD_LOGIC;
BEGIN
	--namapování
	FSM : ENTITY work.UART_FSM(behavioral)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			DIN => DIN,
			CTR_C => ctr_c,
			CTR_B => ctr_b,
			RX_EN => rx_en,
			CTR_EN => ctr_en,
			VALID => valid
		);
	DOUT_VLD <= valid;
	PROCESS (CLK) BEGIN
		IF rising_edge(CLK) THEN
			--pokud příjde reset signál
			IF RST = '1' THEN
				ctr_c <= "00000";
			END IF;

			--pokud je ve stavu, kdy se používá počítadlo
			IF ctr_en = '1' THEN
				ctr_c <= ctr_c + 1;
			ELSE
				ctr_c <= "00000";
			END IF;

			--pokud je recieve enable
			IF rx_en = '1' THEN
				IF ctr_c(4) = '1' OR ctr_c = "01111" THEN
					ctr_c <= "00000";
					CASE(ctr_b) IS
						WHEN "0000" => DOUT(0) <= DIN;
						WHEN "0001" => DOUT(1) <= DIN;
						WHEN "0010" => DOUT(2) <= DIN;
						WHEN "0011" => DOUT(3) <= DIN;
						WHEN "0100" => DOUT(4) <= DIN;
						WHEN "0101" => DOUT(5) <= DIN;
						WHEN "0110" => DOUT(6) <= DIN;
						WHEN "0111" => DOUT(7) <= DIN;
						WHEN OTHERS => NULL;
					END CASE;
					ctr_b <= ctr_b + 1;
				END IF;
			END IF;

			--pokud je data valid
			IF valid = '1' THEN
				ctr_b <= "0000";
			END IF;
		END IF;
	END PROCESS;
END behavioral;