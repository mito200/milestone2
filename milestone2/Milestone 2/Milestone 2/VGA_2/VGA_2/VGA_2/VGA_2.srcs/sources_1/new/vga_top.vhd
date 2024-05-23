----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2024 09:16:24
-- Design Name: 
-- Module Name: vga_top - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_top is
Port ( 
    clk_100mhz : in std_logic;
    S1: in std_logic;
    S2: in std_logic;
    S3: in std_logic;
    Hsync : out std_logic;
    Vsync : out std_logic;
    R : out std_logic_vector (3 downto 0);
    G : out std_logic_vector (3 downto 0);
    B : out std_logic_vector (3 downto 0)
);
end vga_top;

architecture Behavioral of vga_top is

constant fp_v : natural := 10; 
constant pw_v : natural := 2; 
constant bp_v : natural := 29; 
constant disp_v : natural := 480;

constant fp_h : natural := 16; 
constant pw_h : natural := 96; 
constant bp_h : natural := 48; 
constant disp_h : natural := 640;

signal V: std_logic:= '1'; 
signal H: std_logic:= '1';
signal loopnum: integer:=0;
signal V_flag: std_logic:='1';
signal H_flag: std_logic:='1';
signal clk_25mhz :std_logic := '0';

signal counter_v : integer := 1;
signal counter_h : integer := 1;

component clk_wiz_0 
port(
clk_in1: in std_logic;
clk_out1: out std_logic
);
end component;

begin

clk: clk_wiz_0 
port map(
clk_in1 => clk_100mhz,
clk_out1 =>  clk_25mhz
);

R <= S1 & S1 & S1 & S1 when V_flag = '1' and H_flag = '1' else "0000";
B <= S2 & S2 & S2 & S2 when V_flag = '1' and H_flag = '1' else "0000";
G <= S3 & S3 & S3 & S3 when V_flag = '1' and H_flag = '1' else "0000";
Vsync<=V;
Hsync<=H;

vertical: process(clk_25mhz) 
--variable counter_v: integer :=0;
begin
if rising_edge(clk_25mhz) then
    if(counter_v = disp_v ) then
        V_flag <= '0';
    end if;
    
    if(counter_v = fp_v + disp_v) then
        V<='0'; 
    end if;
    
    if(counter_v = fp_v + pw_v + disp_v ) then
         V<='1';
    end if;
    
    if(counter_v = fp_v + pw_v + bp_v + disp_v) then
        V_flag <= '1';
    end if;
    
end if;
end process;


horizontal: process(clk_25mhz) 
begin
if rising_edge(clk_25mhz) then
    counter_h<=counter_h+1;

    if(counter_h = disp_h ) then
        H_flag <= '0';
    end if;
    
    if(counter_h = fp_h + disp_h) then
        H<='0'; 
    end if;
    
    if(counter_h = fp_h + pw_h + disp_h ) then
         H<='1';
    end if;
    
    if(counter_h = fp_h + pw_h + bp_h + disp_h) then
        counter_h<=1;
        H_flag <= '1';
        if(counter_v = fp_v + pw_v + bp_v + disp_v) then
            counter_v <= 1;
        else 
            counter_v<=counter_v+1;
        end if;
    end if;
    
end if;
end process;

end Behavioral;