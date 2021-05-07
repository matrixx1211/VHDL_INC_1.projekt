-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): 
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------
ENTITY UART_FSM IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		DIN : IN STD_LOGIC;
		CTR_C : IN STD_LOGIC_VECTOR(4 DOWNTO 0) := (others => '0');
		CTR_B : IN STD_LOGIC_VECTOR (3 DOWNTO 0) := (others => '0');
		RX_EN : OUT STD_LOGIC;
		CTR_EN : OUT STD_LOGIC;
		VALID : OUT STD_LOGIC
	);
END ENTITY UART_FSM;

-------------------------------------------------
ARCHITECTURE behavioral OF UART_FSM IS
	TYPE STATE_T IS (WAIT_START_BIT, WAIT_FIRST_BIT, RECIEVE_DATA, WAIT_STOP_BIT, VALID_DATA);
	SIGNAL state : STATE_T := WAIT_START_BIT;
BEGIN
	RX_EN <= '1' WHEN state = RECIEVE_DATA ELSE
		'0';
	CTR_EN <= '1' WHEN state = WAIT_FIRST_BIT OR state = RECIEVE_DATA ELSE
		'0';
	VALID <= '1' WHEN state = VALID_DATA ELSE
		'0';
	PROCESS (CLK, RST, CTR_C, CTR_B) BEGIN
		IF rising_edge(CLK) THEN
			IF RST = '1' THEN --pokud je reset tak nastaví state na WAIT_START_BIT
				state <= WAIT_START_BIT;
			ELSE
				CASE (state) IS --změny stavů

					WHEN WAIT_START_BIT =>
					IF DIN = '0' THEN
						state <= WAIT_FIRST_BIT;
					END IF;

					WHEN WAIT_FIRST_BIT =>
					IF CTR_C = "11000" THEN
						state <= RECIEVE_DATA;
					END IF;

					WHEN RECIEVE_DATA =>
					IF CTR_B = "1000" THEN
						state <= WAIT_STOP_BIT;
					END IF;

					WHEN WAIT_STOP_BIT =>
					IF DIN = '1' THEN
						state <= VALID_DATA;
					END IF;

					WHEN VALID_DATA =>
					state <= WAIT_START_BIT;

					WHEN OTHERS => NULL;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
END behavioral;