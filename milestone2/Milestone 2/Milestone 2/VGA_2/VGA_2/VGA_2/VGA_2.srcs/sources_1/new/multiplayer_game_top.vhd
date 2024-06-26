----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.04.2024 19:49:23
-- Design Name: 
-- Module Name: game_top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplayer_game_top is
  Port ( 
    clk        : in  std_logic;
    reset      : in  std_logic;
    ps2_clk    : in  std_logic;                   
    ps2_data   : in  std_logic; 
    rx_in      : in  std_logic;
    Hsync      : out std_logic;
    Vsync      : out std_logic;
    tx_out     : out std_logic;
    R          : out std_logic_vector (3 downto 0);
    G          : out std_logic_vector (3 downto 0);
    B          : out std_logic_vector (3 downto 0)
  );
end multiplayer_game_top;

architecture Behavioral of multiplayer_game_top is


signal ascii_new    : std_logic;

signal data_received_flag : std_logic; 
signal data_received: std_logic_vector (6 downto 0);
signal keyboard_char: std_logic_vector (6 downto 0);
 

component vga_multiplayer is
Port (
    clk_100mhz : in std_logic;
    data_received_flag : in std_logic;
    data_received : in std_logic_vector (6 downto 0);
    keyboard_char: in std_logic_vector (6 downto 0);
    Hsync      : out std_logic;
    Vsync      : out std_logic;
    R          : out std_logic_vector (3 downto 0);
    G          : out std_logic_vector (3 downto 0);
    B          : out std_logic_vector (3 downto 0));
end component; 

component ps2_keyboard_to_ascii is
  GENERIC(
      clk_freq                  : INTEGER := 50_000_000; 
      ps2_debounce_counter_size : INTEGER := 8);         
  PORT(
      clk        : IN  STD_LOGIC;                   
      ps2_clk    : IN  STD_LOGIC;                    
      ps2_data   : IN  STD_LOGIC;                     
      ascii_new  : OUT STD_LOGIC;                     
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
end component; 

component uart_top_multiplayer is
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
end component;

begin


  game:  vga_multiplayer
    PORT MAP(
    clk_100mhz => clk, 
    data_received_flag => data_received_flag,
    data_received => data_received,
    keyboard_char => keyboard_char,
    Hsync => Hsync,
    Vsync => Vsync,
    R => R,
    G => G,
    B => B
    );
    

  ps2_keyboard:  ps2_keyboard_to_ascii
    GENERIC MAP(
    clk_freq => 50_000_000, 
    ps2_debounce_counter_size => 8)
    PORT MAP(
    clk => clk, 
    ps2_clk => ps2_clk, 
    ps2_data => ps2_data, 
    ascii_new => ascii_new, 
    ascii_code => keyboard_char);
  
 uart:  uart_top_multiplayer
    PORT MAP(
       clk                 => clk,
       reset               => reset,
       rx_in               => rx_in,
       ascii_new           => ascii_new,
       ascii_code          => keyboard_char,
       data_received       => data_received,
       data_received_flag  => data_received_flag,
       tx_out              => tx_out
    );
 
  

end Behavioral;
