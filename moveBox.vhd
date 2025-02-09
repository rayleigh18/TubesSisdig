LIBRARY  IEEE; 
USE  IEEE.STD_LOGIC_1164.ALL; 
USE  IEEE.STD_LOGIC_ARITH.ALL; 
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY moveBox is
    PORT(
		START	  : IN STD_LOGIC;
        ATAS      : IN STD_LOGIC;
        BAWAH     : IN STD_LOGIC;
        i_clk     : IN STD_LOGIC;
        speed	  : in INTEGER;

        --LEFT   : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        --RIGHT  : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        UP     : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        DOWN   : OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 )

    );
end moveBox;

architecture behavioral of moveBox is
    signal r_clk : STD_LOGIC;
    signal pos_x , pos_y : integer := 240;
    type state is(A,B,Kr,Kn, S);
    signal p_state, n_state :state := S;
    constant wid, hei : integer := 49;
    --signal speed : integer := 1;
    constant speed0 : integer := 0;


    component CLOCKDIV is
    port(
        CLK     : IN STD_LOGIC;
        DIVOUT  : buffer STD_LOGIC;
        div 	: in integer
    );
    end component;

begin
	
    realClock :CLOCKDIV port map (CLK => i_clk, DIVOUT => r_clk, div => 50000 );
	
    process(r_clk, ATAS, BAWAH, pos_y, pos_x)
    begin
        if r_clk'event and r_clk = '1' then
            case p_state is
                when S =>
                    if ((ATAS = '0') and (BAWAH = '0')) or ((ATAS = '1') and (BAWAH = '1'))THEN
                        p_state <= S;
                        if pos_y <= 0 then
							pos_y <= 0;
						elsif pos_y + hei >= 479 then
							pos_y <= 479-hei;
						end if;
						if pos_x + wid >= 479 then
							pos_x <= 479 - wid;
						elsif pos_x < 0 then
							pos_x <= 0;
						end if;
						
                    elsif (ATAS = '1') then
                        p_state <= A;
                    elsif (BAWAH = '1') then
                        p_state <= B;
                    end if;
                when A =>
                    if pos_y <= 0 then
                        pos_y <= 0;
                    else 
                        pos_y <= pos_y - speed;
                    end if; 
                    p_state <= S;
                when B =>
                    if pos_y + hei >= 479 then
                        pos_y <= 479-hei;
                    else 
                        pos_y <= pos_y + speed;
                    end if;
                    p_state <= S;
                when Kn =>
                    if pos_x + wid >= 479 then
                        pos_x <= 479;
                    else 
                        pos_x <= pos_x + speed;
                    end if;
                    p_state <= S;
                when Kr =>
                    if pos_x < 0 then
                        pos_x <= 0;
                    else 
                        pos_x <= pos_x - speed;
                    end if;
                    p_state <= S;
            end case;
        end if;
    end process;                     

    --LEFT <= conv_std_logic_vector(pos_x, LEFT'length);
    --RIGHT <= conv_std_logic_vector(pos_x+wid, RIGHT'length);
    UP <= conv_std_logic_vector(pos_y, UP'length);
    DOWN <= conv_std_logic_vector(pos_y+hei, DOWN'length);
end behavioral;

