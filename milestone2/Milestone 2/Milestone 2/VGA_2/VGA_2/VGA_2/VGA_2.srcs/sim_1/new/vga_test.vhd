----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2024 10:24:15
-- Design Name: 
-- Module Name: vga_test - Behavioral
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

entity vga_test is
end vga_test;

architecture Behavioral of vga_test is

component vga_moving_image
Port ( 
    clk_100mhz : in std_logic;
    --S1: in std_logic;
    --S2: in std_logic;
    --S3: in std_logic;
    btnT       : in std_logic;
    btnB       : in std_logic;
    btnL       : in std_logic;
    btnR       : in std_logic;
    btnRST     : in std_logic;
    Hsync : out std_logic;
    Vsync : out std_logic;
    R : out std_logic_vector (3 downto 0);
    G : out std_logic_vector (3 downto 0);
    B : out std_logic_vector (3 downto 0)
);
end component;

signal clk_100mhz : std_logic;
signal    Hsync :  std_logic;
signal    Vsync :  std_logic;
signal    btnT:  std_logic;
signal    btnB:  std_logic := '0';
signal    btnR:  std_logic;
signal    btnL:  std_logic;
signal    btnRST:  std_logic;
signal    R :  std_logic_vector (3 downto 0);
signal    G :  std_logic_vector (3 downto 0);
signal    B :  std_logic_vector (3 downto 0);

constant CLK_PERIOD : time := 10 ns;

begin

UUT: vga_moving_image port map(clk_100mhz, btnT, btnB, btnL, btnR ,btnRST,Hsync,Vsync,R,G,B);

 clk_process: process
    begin
        clk_100mhz <= '0';
        wait for CLK_PERIOD / 2;
        clk_100mhz <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_process;


stim_proc: process
begin   
    wait for 500 ns;
    btnB <= '1';
    wait for 1000ns;
    btnB<= '0';
--s1<='1'; s2<='0';s3<='0';
wait;

end process;



end Behavioral;
