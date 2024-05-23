----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2024 06:21:22 PM
-- Design Name: 
-- Module Name: uart_top_multiplayer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.uart_constants.ALL;
use work.constants.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_top_multiplayer is
Port (
   clk                 :        in  std_logic;
   reset               :        in  std_logic;
   rx_in               :        in  std_logic;
   ascii_new           :        in  std_logic; -- from keyboard
   ascii_code          :        in  std_logic_vector(6 downto 0);-- from keyboard  
   data_received       :        out std_logic_vector(6 downto 0);-- from keyboard
   data_received_flag  :        out std_logic;
   tx_out              :        out std_logic
 );
end uart_top_multiplayer;

architecture Behavioral of uart_top_multiplayer is

signal count : integer range 0 to BIT_TIME-1;
signal uart_clk : std_logic; -- 1 when count is 0 and 0 otherwise

-- Tx Signals
signal prev_ascii_new,data_new,prev_data_new : std_logic;
signal data_to_transmit : std_logic_vector(6 downto 0);


component uart_rx is
  Port (
    clk,uart_clk,rst : in std_logic;
    rx_in : in std_logic;
    data : out std_logic_vector(6 downto 0);
    data_new : out std_logic    
    );
end component;

component uart_tx is 
    Port (
    clk,uart_clk : in std_logic;
    rst : in std_logic;
    data : in std_logic_vector(6 downto 0);
    data_new : in std_logic;
    tx_out : out std_logic 
    );
end component;

begin

uart_rx_0: uart_rx  
port map(
    clk=>clk,
    uart_clk=>uart_clk,
    rst=>reset,
    rx_in=>rx_in,
    data=>data_received,
    data_new=>data_received_flag
);

 uart_tx_0: uart_tx 
 port map(
    clk=>clk,
    uart_clk=>uart_clk,
    rst=>reset,
    data=>data_to_transmit,
    data_new=>data_new,
    tx_out=>tx_out
 ); 
 
process(clk) 
begin
    if(uart_clk = '1') then
        if(prev_ascii_new ='0' and ascii_new='1') then
            data_new <= '1';
            data_to_transmit <= ascii_code;
        else 
            data_new <= '0';
        end if;
    end if;
end process; 
 
 
 process(clk)    -- handling count and uart clk
    begin
        if(rising_edge(clk)) then
            if(count = 0) then
                count <= BIT_TIME - 1;
                uart_clk <= '1';
            else 
                count <= count-1;
                uart_clk <= '0';
            end if;
        end if;
    end process;
end Behavioral;
