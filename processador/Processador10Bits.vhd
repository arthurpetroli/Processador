library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Processador10Bits is
    port(
        numeros  : in std_logic_vector(9 downto 0); -- Entrada dos dados (numeros e operacoes)
        clock    : in std_logic; -- clock (botão)
        clock2   : in std_logic; -- clock2 (botão)
        led      : out std_logic_vector(9 downto 0); -- saída dos LEDs para os números
        display  : out std_logic_vector(0 to 6); -- saída do display para os resultados de maior/menor/igual
        display2 : out std_logic_vector(0 to 6) -- saída do display para os resultados de maior/menor/igual
    );
end entity Processador10Bits;

architecture Processador of Processador10Bits is

    signal num        : std_logic_vector(4 downto 0); -- sinal dos números
    signal op         : std_logic_vector(4 downto 0); -- sinal das operações
    signal numero1    : std_logic_vector(9 downto 0); -- sinal do primeiro número
    signal numero2    : std_logic_vector(9 downto 0); -- sinal do segundo número
    signal resultado  : std_logic_vector(9 downto 0); -- resultado para operações soma, sub, mult e divisão
    signal resultado2 : boolean; -- resultado para operações igual, diferente, maior e menor

    type MEMORIA is array(0 to 255) of std_logic_vector(9 downto 0);
	signal MEM : MEMORIA := (
		 "0000000000", "0000000001", "0000000010", "0000000011", "0000000100", "0000000101", "0000000110", "0000000111",
		 "0000001000", "0000001001", "0000001010", "0000001011", "0000001100", "0000001101", "0000001110", "0000001111",
		 "0000010000", "0000010001", "0000010010", "0000010011", "0000010100", "0000010101", "0000010110", "0000010111",
		 "0000011000", "0000011001", "0000011010", "0000011011", "0000011100", "0000011101", "0000011110", "0000011111",
		 "0000100000", "0000100001", "0000100010", "0000100011", "0000100100", "0000100101", "0000100110", "0000100111",
		 "0000101000", "0000101001", "0000101010", "0000101011", "0000101100", "0000101101", "0000101110", "0000101111",
		 "0000110000", "0000110001", "0000110010", "0000110011", "0000110100", "0000110101", "0000110110", "0000110111",
		 "0000111000", "0000111001", "0000111010", "0000111011", "0000111100", "0000111101", "0000111110", "0000111111",
		 "0001000000", "0001000001", "0001000010", "0001000011", "0001000100", "0001000101", "0001000110", "0001000111",
		 "0001001000", "0001001001", "0001001010", "0001001011", "0001001100", "0001001101", "0001001110", "0001001111",
		 "0001010000", "0001010001", "0001010010", "0001010011", "0001010100", "0001010101", "0001010110", "0001010111",
		 "0001011000", "0001011001", "0001011010", "0001011011", "0001011100", "0001011101", "0001011110", "0001011111",
		 "0001100000", "0001100001", "0001100010", "0001100011", "0001100100", "0001100101", "0001100110", "0001100111",
		 "0001101000", "0001101001", "0001101010", "0001101011", "0001101100", "0001101101", "0001101110", "0001101111",
		 "0001110000", "0001110001", "0001110010", "0001110011", "0001110100", "0001110101", "0001110110", "0001110111",
		 "0001111000", "0001111001", "0001111010", "0001111011", "0001111100", "0001111101", "0001111110", "0001111111",
		 "0010000000", "0010000001", "0010000010", "0010000011", "0010000100", "0010000101", "0010000110", "0010000111",
		 "0010001000", "0010001001", "0010001010", "0010001011", "0010001100", "0010001101", "0010001110", "0010001111",
		 "0010010000", "0010010001", "0010010010", "0010010011", "0010010100", "0010010101", "0010010110", "0010010111",
		 "0010011000", "0010011001", "0010011010", "0010011011", "0010011100", "0010011101", "0010011110", "0010011111",
		 "0010100000", "0010100001", "0010100010", "0010100011", "0010100100", "0010100101", "0010100110", "0010100111",
		 "0010101000", "0010101001", "0010101010", "0010101011", "0010101100", "0010101101", "0010101110", "0010101111",
		 "0010110000", "0010110001", "0010110010", "0010110011", "0010110100", "0010110101", "0010110110", "0010110111",
		 "0010111000", "0010111001", "0010111010", "0010111011", "0010111100", "0010111101", "0010111110", "0010111111",
		 "0011000000", "0011000001", "0011000010", "0011000011", "0011000100", "0011000101", "0011000110", "0011000111",
		 "0011001000", "0011001001", "0011001010", "0011001011", "0011001100", "0011001101", "0011001110", "0011001111",
		 "0011010000", "0011010001", "0011010010", "0011010011", "0011010100", "0011010101", "0011010110", "0011010111",
		 "0011011000", "0011011001", "0011011010", "0011011011", "0011011100", "0011011101", "0011011110", "0011011111",
		 "0011100000", "0011100001", "0011100010", "0011100011", "0011100100", "0011100101", "0011100110", "0011100111",
		 "0011101000", "0011101001", "0011101010", "0011101011", "0011101100", "0011101101", "0011101110", "0011101111",
		 "0011110000", "0011110001", "0011110010", "0011110011", "0011110100", "0011110101", "0011110110", "0011110111",
		 "0011111000", "0011111001", "0011111010", "0011111011", "0011111100", "0011111101", "0011111110", "0011111111"
	);



begin
    process(numeros, clock, clock2)
    begin
        num <= numeros(4 downto 0);  
        op  <= numeros(9 downto 5); 

        if (clock = '0') then
            numero1 <= MEM(to_integer(unsigned(num)));
        end if;

        if (clock2 = '0') then
            numero2 <= MEM(to_integer(unsigned(num)));
        end if;

        if (clock = '0' and clock2 = '0') then
            numero1 <= (others => '0');
            numero2 <= (others => '0');
        end if;
    end process;

    process(op, numero1, numero2)
    begin
        case op is
            when "00001" => resultado <= std_logic_vector(unsigned(numero1) + unsigned(numero2)); -- adicao
            when "00010" => resultado <= std_logic_vector(unsigned(numero1) - unsigned(numero2)); -- subtracao
            when "00011" => resultado <= std_logic_vector(to_unsigned(to_integer(unsigned(numero1)) * to_integer(unsigned(numero2)), 10)); -- multiplicacao
            when "00100" => resultado <= std_logic_vector(to_unsigned(to_integer(unsigned(numero1)) / to_integer(unsigned(numero2)), 10)); -- divisao
            when "00101" => resultado2 <= (numero1 > numero2); -- maior que
            when "00110" => resultado2 <= (numero1 < numero2); -- menor que
            when "00111" => resultado2 <= (numero1 >= numero2); -- maior ou igual
            when "01000" => resultado2 <= (numero1 <= numero2); -- menor ou igual
            when "01001" => resultado2 <= (numero1 /= numero2); -- diferente
            when "01010" => resultado  <= numero1; -- move o numero1
            when others  => resultado  <= (others => '0');
        end case;

        display <= "1110111";
        if (resultado2) then
            case op is
                when "00101" => display <= "1100110"; -- maior que
                when "00110" => display <= "1110010"; -- menor que
                when "00111" => display <= "0100110"; -- maior ou igual
                when "01000" => display <= "0110010"; -- menor ou igual
                when "01001" => display <= "0000111"; -- diferente
                when others => display <= "1110111";
            end case;
        end if;
    end process;

    process(resultado)
    begin
        led <= resultado;
    end process;
	 
	 process(num)
    begin
        display2 <= "1111111";
        case num is
            when "00001" => display2 <= "1001111";  -- display2 '1'
				  when "00010" => display2 <= "0010010";  -- display2 '2'
				  when "00011" => display2 <= "0000110";  -- display2 '3'
				  when "00100" => display2 <= "1001100";  -- display2 '4'
				  when "00101" => display2 <= "0100100";  -- display2 '5'
				  when "00110" => display2 <= "0100000";  -- display2 '6'
				  when "00111" => display2 <= "0001111";  -- display2 '7'
				  when "01000" => display2 <= "0000000";  -- display2 '8'
				  when "01001" => display2 <= "0000100";  -- display2 '9'
				  when "01010" => display2 <= "0000010";  -- display2 '10'
				  when "01011" => display2 <= "1100000";  -- display2 '11'
				  when "01100" => display2 <= "0110001";  -- display2 '12'
				  when "01101" => display2 <= "1000010";  -- display2 '13'
				  when "01110" => display2 <= "0110000";  -- display2 '14'
				  when "01111" => display2 <= "0111000";  -- display2 '15'
				  when others  => display2 <= "1111111";  -- Default: All segments off (blank)
		end case;
	end process;
	

end architecture;