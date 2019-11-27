LIBRARY  IEEE; 
USE  IEEE.STD_LOGIC_1164.ALL; 
USE  IEEE.STD_LOGIC_ARITH.ALL; 
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY color_rom_vhd  IS 
	PORT(
	    i_clk			: IN STD_LOGIC;
	    sw0,sw1,sw2,sw3 : IN STD_LOGIC;
	    sw9,sw8,sw7,sw6 : IN STD_LOGIC;
	    i_pixel_column  : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    i_pixel_row     : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    o_red           : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_green         : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_blue          : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
END color_rom_vhd; 

--entity 

ARCHITECTURE behavioral OF color_rom_vhd  IS 
type stateGame  is (START, ENDGAME);
signal state : stateGame := START;
SIGNAL LEFT_1   : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
SIGNAL RIGHT_1  : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
SIGNAL UP_1     : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
SIGNAL DOWN_1   : STD_LOGIC_VECTOR( 9 DOWNTO 0 );



SIGNAL LEFT_2   : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
SIGNAL RIGHT_2  : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
SIGNAL UP_2     : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
SIGNAL DOWN_2   : STD_LOGIC_VECTOR( 9 DOWNTO 0 );

SIGNAL M                :  STD_LOGIC := '0'; 
SIGNAL P				: STD_LOGIC := '0';
SIGNAL grid                 :  STD_LOGIC; 
SIGNAL speedbox			    :  integer := 1;
--SIGNAL speed9,speed8,speed7,speed6 : integer;
signal stop                 : STD_LOGIC := '0';
signal posBallx, posBally   : STD_LOGIC_VECTOR(9 downto 0);
signal boundYatas           : integer := 10;
signal boundYbawah          : integer := 600;
signal boundXkiri           : integer := 470;
signal boundXkanan          : integer := 10;
signal radBall              : integer := 10;
signal lastWin				 : STD_LOGIC := '1';
signal STARTSIG             : STD_LOGIC := '0'; 
signal signalStart          : STD_LOGIC := '1';
signal xOB, yOB				: STD_LOGIC_VECTOR(9 downto 0);
signal check_clk  : std_logic;
signal overshoot1			: integer;
signal pStart				: integer:=0;
signal iStart				: integer:=30;
signal winStart				: integer:=80;


signal signalEnd            : std_logic; --input for movebox and ball movement to start the game

signal ballSignal		       : std_logic; 

component moveBox is
    PORT(
		START	   : in STD_LOGIC;
	   --lastWin   : buffer STD_LOGIC;
        ATAS      : IN STD_LOGIC;
        BAWAH     : IN STD_LOGIC;
        i_clk     : IN STD_LOGIC;
        speed	   : IN INTEGER;

        --LEFT      : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        --RIGHT     : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        UP        : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        DOWN      : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 )
    );
end component;

component ballMovement is
   port(
        START  		 : in std_logic;
		lastWin		 : in std_logic;
		i_clk        : in std_logic;
        stop         : in std_logic;
        pos1X, pos2X : in std_logic_vector(9 downto 0);
        pos1Y, pos2Y : in std_logic_vector(9 downto 0);
        posBallX     : out std_logic_vector(9 downto 0);
        posBallY     : out std_logic_vector(9 downto 0);
        radBall      : out integer;
        boundYatas, boundYbawah, boundXkiri, boundXkanan : in integer
    );
end component;

component CLOCKDIV is
port(
	CLK     : IN STD_LOGIC;
	DIVOUT  : buffer STD_LOGIC;
	div 	: in integer
);
end component;
				  
BEGIN

LEFT_1 <=  conv_std_logic_vector(114, LEFT_2'length);
RIGHT_1 <= conv_std_logic_vector(130, LEFT_2'length);
LEFT_2 <= conv_std_logic_vector(510, LEFT_2'length);
RIGHT_2 <= conv_std_logic_vector(526, RIGHT_2'length);

realClock :CLOCKDIV port map (CLK => i_clk, DIVOUT => check_clk, div => 500);


box1 : moveBox port map (
        START  	=> signalStart,
	     ATAS      => sw0,
        BAWAH     => sw1,
        i_clk     => i_clk,
	     speed	   => speedbox,
        UP        => UP_1,
        DOWN      => DOWN_1);

box2 : moveBox port map (
		START	 => signalStart,
        ATAS    => sw2,
        BAWAH   => sw3,
        i_clk   => i_clk,
        speed	 => speedbox,
        UP      => UP_2,
        DOWN    => DOWN_2
);

ball : ballMovement port map(
   START    => signalStart,
   i_clk    => i_clk,
   lastWin  => lastWin,
   stop     => stop,
   pos1X    =>LEFT_1,
   pos1Y    =>UP_1,
   pos2X    =>LEFT_2,
   pos2Y    =>UP_2,
   posBallx =>posBallx,
   posBally =>posBally,
   radBall  =>radBall,
   boundYatas   => boundYatas,
   boundYbawah  => boundYbawah,
   boundXkiri   => boundXkiri,
   boundXkanan  => boundXkanan
);


process(signalStart, lastWin, sw0, sw1, sw2, sw3, i_clk, posBallx, sw9, check_clk)
begin
   if (rising_edge(check_clk)) then
       state <= START;
       if (signalStart = '1') and ((posBallx <= 16))  then
			signalStart <= '0';
			lastWin <= '0';			
			state <= ENDGAME;
	   end if;   
	   if (signalStart = '1') and ((posBallx >= 536))  then
		  signalStart <= '0';
		  lastWin <= '1';
		  state <= ENDGAME;
	   end if;
	   if signalStart = '0' then
		  if ((lastWin = '1') and (sw0 ='1') and (sw1 = '1')) or ((lastWin = '0') and (sw2= '1') and (sw3 = '1')) then
			 signalStart <= '1';
			 state <= START;
		  else 
			 signalStart <= '0';
			 state <= ENDGAME;
		  end if;
	   end if;
	   if (sw9 = '1') then
			signalStart <= '0';
			lastWin     <= '1';
			state <= ENDGAME;
	   end if;
   end if;
end process;

PROCESS(i_pixel_row,i_pixel_column, LEFT_1, RIGHT_1, UP_1, DOWN_1,LEFT_2, RIGHT_2, UP_2, DOWN_2, M, ballSignal, posBallx, radBAll, posBAlly, lastWin, STATE)
BEGIN
  IF ((i_pixel_column >= LEFT_1)  AND (i_pixel_column <= RIGHT_1) AND (i_pixel_row >= UP_1)  AND (i_pixel_row <= DOWN_1)) or ((i_pixel_column >= LEFT_2)  AND (i_pixel_column <= RIGHT_2) AND (i_pixel_row >= UP_2)  AND (i_pixel_row <= DOWN_2))  THEN
	M <= '0';
  ELSE 
    M <= '1';
  END IF;
  
  
  ---change last night
  --IF ((i_pixel_column <= posBallx + radBall) and (i_pixel_column >= posBallx - radBall) and (i_pixel_row <= posBally + radBall) and (i_pixel_row >= posBally - radBall)) then 
  if i_pixel_column >= posBallx then
	 xOB <= i_pixel_column - posBallx;
  else
	 xOB <= posBallx - i_pixel_column;
  end if;
	 
  if i_pixel_row >= posBally then
	 yOB <= i_pixel_row - posBally;
  else
	 yOB <= posBally - i_pixel_row;
  end if;
  
  --IF ((i_pixel_column <= posBallx + radBall) and (i_pixel_column >= posBallx - radBall) and (i_pixel_row <= posBally + radBall) and (i_pixel_row >= posBally - radBall)) then 
  IF (xOB + yOB <= radBall) then
	 -- and (i_pixel_row <= posBally + 11) and (i_pixel_row >= posBally - 11) and (i_pixel_column >= posBallx - 11) and (i_pixel_column <= posBallx + 11) then
	 ballSignal <= '1';
  ELSE
	 ballSignal <= '0';
  END IF;  
  ---end change
  case STATE is
	when START =>
	  IF (ballSignal = '1' ) THEN 
		 o_red <= X"40"; o_green <= X"00"; o_blue <= X"23";
	  ELSIF (M = '0' ) THEN 
		 o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00";
	  ELSE
		 o_red <= X"FE"; o_green <= X"48"; o_blue <= X"AA";
	  END IF;
   when OTHERS =>
	  
	  if lastWin = '0' then
		if (i_pixel_column >= 160 and i_pixel_column <= 180 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 180 and i_pixel_column <= 220 and i_pixel_row >= 160 and i_pixel_row <= 170) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 180 and i_pixel_column <= 220 and i_pixel_row >= 190 and i_pixel_row <= 200) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 210 and i_pixel_column <= 220 and i_pixel_row >= 160 and i_pixel_row <= 200) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		--end P

		elsif (i_pixel_column >= 230 and i_pixel_column <= 250 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
	    -- end 1

		elsif (i_pixel_column >= 270 and i_pixel_column <= 290 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 310 and i_pixel_column <= 330 and i_pixel_row >= 160 and i_pixel_row <= 240) then		
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 350 and i_pixel_column <= 370 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 270 and i_pixel_column <= 370 and i_pixel_row >= 220 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		--end W

		elsif (i_pixel_column >= 380 and i_pixel_column <= 400 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		-- end I
		
		elsif (i_pixel_column >= 410 and i_pixel_column <= 430 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 450 and i_pixel_column <= 470 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 410 and i_pixel_column <= 480 and i_pixel_row >= 160 and i_pixel_row <= 180) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		-- end N
		else
			o_red <= X"FE"; o_green <= X"70"; o_blue <= X"BD";
		end if;
		
	  else
	  	if (i_pixel_column >= 160 and i_pixel_column <= 180 and i_pixel_row >= 160 and i_pixel_row <= 240) then
		o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 180 and i_pixel_column <= 220 and i_pixel_row >= 160 and i_pixel_row <= 170) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 180 and i_pixel_column <= 220 and i_pixel_row >= 190 and i_pixel_row <= 200) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 210 and i_pixel_column <= 220 and i_pixel_row >= 160 and i_pixel_row <= 200) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		--end P

		elsif (i_pixel_column >= 230 and i_pixel_column <= 240 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 250 and i_pixel_column <= 260 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		-- end 1

		elsif (i_pixel_column >= 270 and i_pixel_column <= 290 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 310 and i_pixel_column <= 330 and i_pixel_row >= 160 and i_pixel_row <= 240) then		
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 350 and i_pixel_column <= 370 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 270 and i_pixel_column <= 370 and i_pixel_row >= 220 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		--end W

		elsif (i_pixel_column >= 380 and i_pixel_column <= 400 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		-- end I
		
		elsif (i_pixel_column >= 410 and i_pixel_column <= 430 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 450 and i_pixel_column <= 470 and i_pixel_row >= 160 and i_pixel_row <= 240) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		elsif (i_pixel_column >= 410 and i_pixel_column <= 480 and i_pixel_row >= 160 and i_pixel_row <= 180) then
			o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
		-- end N
		else
			o_red <= X"FE"; o_green <= X"70"; o_blue <= X"BD";
		end if;
		
	  end if;   
	
  end case;
  
END PROCESS;



END behavioral; 