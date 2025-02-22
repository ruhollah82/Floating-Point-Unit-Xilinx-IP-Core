library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FPU_top is
    Port (
        A       : in  STD_LOGIC_VECTOR(31 downto 0);
        B       : in  STD_LOGIC_VECTOR(31 downto 0);
        op      : in  STD_LOGIC_VECTOR(1 downto 0);
        clock   : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        result  : out STD_LOGIC_VECTOR(31 downto 0);
        valid   : out STD_LOGIC  
    );
end FPU_top;

architecture Behavioral of FPU_top is

    type state_type is (IDLE, SEND_OPERANDS, WAIT_RESULT);
    signal state : state_type := IDLE;
    
    signal latched_A, latched_B : STD_LOGIC_VECTOR(31 downto 0);
    signal latched_op : STD_LOGIC_VECTOR(1 downto 0);
    
    signal add_tvalid, sub_tvalid, mul_tvalid, div_tvalid : STD_LOGIC := '0';
    signal add_a_tready, add_b_tready : STD_LOGIC;
    signal sub_a_tready, sub_b_tready : STD_LOGIC;
    signal mul_a_tready, mul_b_tready : STD_LOGIC;
    signal div_a_tready, div_b_tready : STD_LOGIC;
    
    signal add_result, sub_result, mul_result, div_result : STD_LOGIC_VECTOR(31 downto 0);
    signal add_valid, sub_valid, mul_valid, div_valid : STD_LOGIC;
    
    signal result_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal valid_reg : STD_LOGIC := '0';

    COMPONENT add
    PORT (
        aclk                : IN STD_LOGIC;
        s_axis_a_tvalid     : IN STD_LOGIC;
        s_axis_a_tready     : OUT STD_LOGIC;
        s_axis_a_tdata      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_b_tvalid     : IN STD_LOGIC;
        s_axis_b_tready     : OUT STD_LOGIC;
        s_axis_b_tdata      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid: OUT STD_LOGIC;
        m_axis_result_tready: IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;
    
    COMPONENT sub
    PORT (
        aclk                : IN STD_LOGIC;
        s_axis_a_tvalid     : IN STD_LOGIC;
        s_axis_a_tready     : OUT STD_LOGIC;
        s_axis_a_tdata      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_b_tvalid     : IN STD_LOGIC;
        s_axis_b_tready     : OUT STD_LOGIC;
        s_axis_b_tdata      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid: OUT STD_LOGIC;
        m_axis_result_tready: IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;
    
    COMPONENT mul
    PORT (
        aclk                : IN STD_LOGIC;
        s_axis_a_tvalid     : IN STD_LOGIC;
        s_axis_a_tready     : OUT STD_LOGIC;
        s_axis_a_tdata      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_b_tvalid     : IN STD_LOGIC;
        s_axis_b_tready     : OUT STD_LOGIC;
        s_axis_b_tdata      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid: OUT STD_LOGIC;
        m_axis_result_tready: IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;
    
    COMPONENT div
    PORT (
        aclk                : IN STD_LOGIC;
        s_axis_a_tvalid     : IN STD_LOGIC;
        s_axis_a_tready     : OUT STD_LOGIC;
        s_axis_a_tdata      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_b_tvalid     : IN STD_LOGIC;
        s_axis_b_tready     : OUT STD_LOGIC;
        s_axis_b_tdata      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid: OUT STD_LOGIC;
        m_axis_result_tready: IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;

begin

    process(clock, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            valid_reg <= '0';
            add_tvalid <= '0';
            sub_tvalid <= '0';
            mul_tvalid <= '0';
            div_tvalid <= '0';
        elsif rising_edge(clock) then
            case state is
                when IDLE =>
                    valid_reg <= '0';
                    if op /= "UU" then
                        latched_A <= A;
                        latched_B <= B;
                        latched_op <= op;
                        case op is
                            when "00" => add_tvalid <= '1';
                            when "01" => sub_tvalid <= '1';
                            when "10" => mul_tvalid <= '1';
                            when "11" => div_tvalid <= '1';
                            when others => null;
                        end case;
                        state <= SEND_OPERANDS;
                    end if;

                when SEND_OPERANDS =>
                    case latched_op is
                        when "00" =>
                            if add_a_tready = '1' and add_b_tready = '1' then
                                add_tvalid <= '0';
                                state <= WAIT_RESULT;
                            end if;
                        when "01" =>
                            if sub_a_tready = '1' and sub_b_tready = '1' then
                                sub_tvalid <= '0';
                                state <= WAIT_RESULT;
                            end if;
                        when "10" =>
                            if mul_a_tready = '1' and mul_b_tready = '1' then
                                mul_tvalid <= '0';
                                state <= WAIT_RESULT;
                            end if;
                        when "11" =>
                            if div_a_tready = '1' and div_b_tready = '1' then
                                div_tvalid <= '0';
                                state <= WAIT_RESULT;
                            end if;
                        when others =>
                            state <= IDLE;
                    end case;

                when WAIT_RESULT =>
                    case latched_op is
                        when "00" =>
                            if add_valid = '1' then
                                result_reg <= add_result;
                                valid_reg <= '1';
                                state <= IDLE;
                            end if;
                        when "01" =>
                            if sub_valid = '1' then
                                result_reg <= sub_result;
                                valid_reg <= '1';
                                state <= IDLE;
                            end if;
                        when "10" =>
                            if mul_valid = '1' then
                                result_reg <= mul_result;
                                valid_reg <= '1';
                                state <= IDLE;
                            end if;
                        when "11" =>
                            if div_valid = '1' then
                                result_reg <= div_result;
                                valid_reg <= '1';
                                state <= IDLE;
                            end if;
                        when others =>
                            state <= IDLE;
                    end case;
            end case;
        end if;
    end process;

    FP_Add: add
    PORT MAP (
        aclk                => clock,
        s_axis_a_tvalid     => add_tvalid,
        s_axis_a_tready     => add_a_tready,
        s_axis_a_tdata      => latched_A,
        s_axis_b_tvalid     => add_tvalid,
        s_axis_b_tready     => add_b_tready,
        s_axis_b_tdata      => latched_B,
        m_axis_result_tvalid=> add_valid,
        m_axis_result_tready=> '1',
        m_axis_result_tdata => add_result
    );

    FP_Sub: sub
    PORT MAP (
        aclk                => clock,
        s_axis_a_tvalid     => sub_tvalid,
        s_axis_a_tready     => sub_a_tready,
        s_axis_a_tdata      => latched_A,
        s_axis_b_tvalid     => sub_tvalid,
        s_axis_b_tready     => sub_b_tready,
        s_axis_b_tdata      => latched_B,
        m_axis_result_tvalid=> sub_valid,
        m_axis_result_tready=> '1',
        m_axis_result_tdata => sub_result
    );

    FP_Mul: mul
    PORT MAP (
        aclk                => clock,
        s_axis_a_tvalid     => mul_tvalid,
        s_axis_a_tready     => mul_a_tready,
        s_axis_a_tdata      => latched_A,
        s_axis_b_tvalid     => mul_tvalid,
        s_axis_b_tready     => mul_b_tready,
        s_axis_b_tdata      => latched_B,
        m_axis_result_tvalid=> mul_valid,
        m_axis_result_tready=> '1',
        m_axis_result_tdata => mul_result
    );

    FP_Div: div
    PORT MAP (
        aclk                => clock,
        s_axis_a_tvalid     => div_tvalid,
        s_axis_a_tready     => div_a_tready,
        s_axis_a_tdata      => latched_A,
        s_axis_b_tvalid     => div_tvalid,
        s_axis_b_tready     => div_b_tready,
        s_axis_b_tdata      => latched_B,
        m_axis_result_tvalid=> div_valid,
        m_axis_result_tready=> '1',
        m_axis_result_tdata => div_result
    );

    result <= result_reg;
    valid <= valid_reg;

end Behavioral;