library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FPU_tb is
end FPU_tb;

architecture Behavioral of FPU_tb is
    component FPU_top
    Port (
        A       : in  STD_LOGIC_VECTOR(31 downto 0);
        B       : in  STD_LOGIC_VECTOR(31 downto 0);
        op      : in  STD_LOGIC_VECTOR(1 downto 0);
        clock   : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        result  : out STD_LOGIC_VECTOR(31 downto 0);
        valid   : out STD_LOGIC  
    );
    end component;

    signal A, B     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal op       : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal clock    : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal result   : STD_LOGIC_VECTOR(31 downto 0);
    signal valid    : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin
    uut: FPU_top port map (
        A => A,
        B => B,
        op => op,
        clock => clock,
        reset => reset,
        result => result,
        valid => valid
    );

    clock_process: process
    begin
        clock <= '0';
        wait for CLK_PERIOD/2;
        clock <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        -- Initialize and reset
        reset <= '1';
        wait for CLK_PERIOD*2;
        reset <= '0';
        wait for CLK_PERIOD*2;

        -- Test Case 1: Addition (1.0 + 2.0 = 3.0)
       op <= "00";
        A <= x"20000082";  -- 1.0
        B <= x"20000082";  -- 2.0
        wait until valid = '1' for 1000 ns;
        -- result = x"40400000"  -- 3.0

        wait for CLK_PERIOD*2;

--        -- Test Case 2: Subtraction (5.0 - 2.5 = 2.5)
--        report "Test 2: 5.0 - 2.5";
--        op <= "01";
--        A <= x"40a00000";  -- 5.0
--        B <= x"40200000";  -- 2.5
--        wait until valid = '1' for 1000 ns;
--        assert result = x"40200000"  -- 2.5
--            report "Subtraction failed" severity error;

--        wait for CLK_PERIOD*2;

--        -- Test Case 3: Multiplication (2.5 * 4.0 = 10.0)
--        report "Test 3: 2.5 * 4.0";
--        op <= "10";
--        A <= x"40200000";  -- 2.5
--        B <= x"40800000";  -- 4.0
--        wait until valid = '1' for 1000 ns;
--        assert result = x"41200000"  -- 10.0
--            report "Multiplication failed" severity error;

--        wait for CLK_PERIOD*2;

--        -- Test Case 4: Division (9.0 / 3.0 = 3.0)
--        report "Test 4: 9.0 / 3.0";
--        op <= "11";
--        A <= x"41100000";  -- 9.0
--        B <= x"40400000";  -- 3.0
--        wait until valid = '1' for 1000 ns;
--        assert result = x"40400000"  -- 3.0
--            report "Division failed" severity error;

--        wait for CLK_PERIOD*2;

--        -- Test Case 5: Add Zero (1.0 + 0.0 = 1.0)
--        report "Test 5: 1.0 + 0.0";
--        op <= "00";
--        A <= x"3f800000";  -- 1.0
--        B <= x"00000000";  -- 0.0
--        wait until valid = '1' for 1000 ns;
--        assert result = x"3f800000"
--            report "Zero addition failed" severity error;

--        wait for CLK_PERIOD*2;

--        -- Test Case 6: Division by Zero (5.0 / 0.0 = Inf)
--        report "Test 6: 5.0 / 0.0";
--        op <= "11";
--        A <= x"40a00000";  -- 5.0
--        B <= x"00000000";  -- 0.0
--        wait until valid = '1' for 1000 ns;
--        assert result(30 downto 23) = x"ff"  -- Check exponent for infinity
--            report "Division by zero failed" severity error;

--        wait for CLK_PERIOD*2;

--        -- Test Case 7: Invalid Input (NaN)
--        report "Test 7: NaN input";
--        op <= "00";
--        A <= x"7fc00000";  -- NaN
--        B <= x"3f800000";  -- 1.0
--        wait until valid = '1' for 1000 ns;
--        assert result(30 downto 0) /= x"00000000"  -- Check for NaN
--            report "NaN handling failed" severity error;

--        wait for CLK_PERIOD*2;

--        -- Test Case 8: Large Numbers (1e20 * 1e20 = 1e40)
--        report "Test 8: Large number multiplication";
--        op <= "10";
--        A <= x"5d5e0b6b";  -- ~1e20
--        B <= x"000";  -- ~1e20
--        wait until valid = '1' for 1000 ns;
--        assert result(31) = '0' and result(30 downto 23) = x"7f"  -- Check overflow
--            report "Large number handling failed" severity error;

        wait for CLK_PERIOD*2;

        report "All tests completed";
        wait;
    end process;

end Behavioral;