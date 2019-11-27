library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ballMovement is 
    port(
		START		 : in std_logic;
		lastWin		 : in std_logic;  -- 1 for player 1, 0 for player 2
		i_clk        : in std_logic;
        stop         : in std_logic;
        pos1X, pos2X : in std_logic_vector(9 downto 0);
        pos1Y, pos2Y : in std_logic_vector(9 downto 0);
        posBallX     : out std_logic_vector(9 downto 0);
        posBallY     : out std_logic_vector(9 downto 0);
        radBall      : out integer;
        boundYatas, boundYbawah, boundXkiri, boundXkanan : in integer
    );
end ballMovement;
 
architecture behavioural of ballMovement is
    signal  posX, posY : integer := 0;
    signal speedX , speedY : integer := 1;
    signal ballRadius : integer := 20;
    signal wid : integer := 8;
    signal hei : integer := 40;
    signal r_clk : std_logic;
    signal speed_clk : std_logic;
    component CLOCKDIV is
        port(
            CLK     : IN STD_LOGIC;
            DIVOUT  : buffer STD_LOGIC;
            div     : in integer
        );
    end component;
    begin
		real_clock : CLOCKDIV port map(
			CLK    => i_clk,
			DIVOUT => r_clk,
			div	   => 250000
		);
		realClock2 : CLOCKDIV port map(
		    CLK    => i_clk,
			DIVOUT => speed_clk,
			div	   => 500
		);
        -- pos1X and pos1Y is racket Player 1
        -- pos2X and pos2Y is racket Player 2
        -- posX and posY is ball position
        -- posBallX and posBallY is output to draw in color_rom
        
        process(stop, posX, posY, pos1X, pos1Y, pos2X, pos2Y, speedX, speedY, wid, hei, r_clk, START, lastWin, speed_clk)
        begin
			if rising_edge(speed_clk) then
				if ((((posX + ballRadius >= pos2X) and (posY >= pos2Y) and (posY <= pos2Y + hei) )) ) and (speedX > 0) then
						speedX <= -1;
				elsif ((((posX - ballRadius <= pos1X + 16) and (posY >= pos1Y) and (posY <= pos1Y + hei)))) and (speedX < 0) then
						speedX <= 1;
				else speedX <= speedX;
				end if;
			end if;
            if (rising_edge(r_clk)) then
                
                if (posY - ballRadius <= 0) and (speedY < 0) then
                    speedY <= 1;
				elsif (posY + ballRadius >= 480) and (speedY > 0) then
                    speedY <= -1;
                end if;
                ---change last night
                if (start = '1') then
					posX <= posX + speedX;
					posY <= posY + speedY;
				elsif (lastWin = '1') then
					posX <= conv_integer(pos1X) + ballRadius + 16;
					posY <= conv_integer(pos1Y) + 20;
				elsif (lastWin = '0') then
					posX <= conv_integer(pos2X) - ballRadius;
					posY <= conv_integer(pos2Y) + 20;
				end if;
				---endchange
				
            end if;
        end process;

		posBallX <= conv_std_logic_vector(posX, posBallX'length);
        posBallY <= conv_std_logic_vector(posY, posBallY'length);
        radBall <= ballRadius;
end behavioural ; -- behavioural
