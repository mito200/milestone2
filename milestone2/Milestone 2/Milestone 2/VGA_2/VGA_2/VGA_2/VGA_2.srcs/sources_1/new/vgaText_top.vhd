----------------------------------------------------------------------------------
-- Company: Visual Pulse
-- Engineer: Eric (MLM)
-- 
-- Create Date:    09:33:28 07/11/2013 
-- Design Name: 
-- Module Name:    vgaText_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- note this line.The package is compiled to this directory by default.
-- so don't forget to include this directory. 
library work;
-- this line also is must.This includes the particular package into your program.
use work.commonPak.all;


entity vgaText_top is
	port(
		clk_100mhz: in std_logic;
		reset: in std_logic; -- SW0
		--Led: out std_logic_vector(7 downto 0);
		
		hsync: out std_logic;
		vsync: out std_logic;
		Red: out std_logic_vector(2 downto 0);
		Green: out std_logic_vector(2 downto 0);
		Blue: out std_logic_vector(2 downto 1)
	);
end vgaText_top;

architecture Behavioral of vgaText_top is

    constant fp_v : natural := 10; 
    constant pw_v : natural := 2; 
    constant bp_v : natural := 29; 
    constant disp_v : natural := 480;
    
    constant fp_h : natural := 16; 
    constant pw_h : natural := 96; 
    constant bp_h : natural := 48; 
    constant disp_h : natural := 640;
    
    signal counter_v : integer := 1;
    signal counter_h : integer := 1;
    
    signal V: std_logic:= '1'; 
    signal H: std_logic:= '1';
    signal V_flag: std_logic:='1';
    signal H_flag: std_logic:='1';
	
	-- Start out at the end of the display range, 
	-- so we give a sync pulse to kick things off
	signal hCount: integer := 640;
	signal vCount: integer := 480;
	
	signal nextHCount: integer := 641;
	signal nextVCount: integer := 480;
	
	
	constant NUM_TEXT_ELEMENTS: integer := 3;
	signal inArbiterPortArray: type_inArbiterPortArray(0 to NUM_TEXT_ELEMENTS-1) := (others => init_type_inArbiterPort);
	signal outArbiterPortArray: type_outArbiterPortArray(0 to NUM_TEXT_ELEMENTS-1) := (others => init_type_outArbiterPort);
	
	signal drawElementArray: type_drawElementArray(0 to NUM_TEXT_ELEMENTS-1) := (others => init_type_drawElement);
	signal led_reg: std_logic_vector(7 downto 0) := (others => '0');

    signal clk_25mhz :std_logic := '0';
    signal clk :std_logic := '0';
    component clk_wiz_0 
    port(
    clk_in1: in std_logic;
    clk_out1: out std_logic
    --clk_out2: out std_logic
    );
    end component;
begin
   
   hsync <= H;
   vsync <= V;
    clk_0: clk_wiz_0 
    port map(
    clk_in1 => clk_100mhz,
    clk_out1 => clk
    --clk_out2 => clk
    );
	--Led <= led_reg;
	
	
	fontLibraryArbiter: entity work.blockRamArbiter
	generic map(
		numPorts => NUM_TEXT_ELEMENTS
	)
	port map(
		clk => clk,
		reset => reset,
		inPortArray => inArbiterPortArray,
		outPortArray => outArbiterPortArray
	);


	textDrawElement: entity work.text_line
	generic map (
		textPassageLength => 11
	)
	port map(
		clk => clk,
		reset => reset,
		textPassage => "Hello World",
		position => (50, 50),
		colorMap => (10 downto 0 => "111" & "111" & "11"),
		inArbiterPort => inArbiterPortArray(0),
		outArbiterPort => outArbiterPortArray(0),
		hCount => counter_h,
		vCount => counter_v,
		drawElement => drawElementArray(0)
	);
	
	
	textDrawElement2: entity work.text_line
	generic map (
		textPassageLength => 5
	)
	port map(
		clk => clk,
		reset => reset,
		textPassage => SOH & " : " & STX,
		position => (50, 200),
		colorMap => (4 downto 0 => "111" & "111" & "11"),
		inArbiterPort => inArbiterPortArray(1),
		outArbiterPort => outArbiterPortArray(1),
		hCount => nextHCount,
		vCount => nextVCount,
		drawElement => drawElementArray(1)
	);
	
	textDrawElement3: entity work.text_line
	generic map (
		textPassageLength => 8
	)
	port map(
		clk => clk,
		reset => reset,
		textPassage => "I " & "<3" & " You",
		position => (70, 125),
		colorMap => (7 downto 4 => "111" & "111" & "11", 3 downto 2 => "111" & "000" & "00", 1 downto 0 => "111" & "111" & "11"),
		inArbiterPort => inArbiterPortArray(2),
		outArbiterPort => outArbiterPortArray(2),
		hCount => nextHCount,
		vCount => nextVCount,
		drawElement => drawElementArray(2)
	);
	
	
    vertical: process(clk) 
    begin
    if rising_edge(clk) then
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


    
    horizontal: process(clk) 
    begin
    if rising_edge(clk) then
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
        
	vgasignal: process(clk)
	   variable rgbDrawColor : std_logic_vector(7 downto 0) := (others => '0');
	begin
		
		if rising_edge(clk) then
            if (H_flag='1' and V_flag='1') then
                -- Draw stack:
                -- Default is black
                rgbDrawColor := "000" & "000" & "00";

                -- Draw bounding left line - 2px
                if counter_h >= 1 and counter_h < 3 then
                    rgbDrawColor := "111" & "111" & "00";
                -- Draw bounding right line - 2px
                elsif counter_h <= 640 and counter_h > 638 then
                    rgbDrawColor := "111" & "111" & "00";
                end if;

                -- Draw bounding top line - 2px
                if counter_v >= 1 and counter_v < 3 then
                    rgbDrawColor := "111" & "111" & "00";
                -- Draw bounding bottom line - 2px
                elsif counter_v <= 480 and counter_v > 478 then
                    rgbDrawColor := "111" & "111" & "00";
                end if;

                -- Text Draw Stack
                -----------------
                for i in drawElementArray'range loop
                    if drawElementArray(i).pixelOn then
                        rgbDrawColor := drawElementArray(i).rgb;
                    end if;
                end loop;

                -- Show your colors
       	        Red <= rgbDrawColor(7 downto 5);
			    Green <= rgbDrawColor(4 downto 2);
				Blue <= rgbDrawColor(1 downto 0);
                
                
            else
                Red <= "000";
                Green <= "000";
                Blue <= "00";
            end if;
		end if;
	end process;
end Behavioral;

