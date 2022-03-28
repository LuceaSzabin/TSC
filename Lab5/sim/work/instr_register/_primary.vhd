library verilog;
use verilog.vl_types.all;
library work;
entity instr_register is
    port(
        clk             : in     vl_logic;
        load_en         : in     vl_logic;
        reset_n         : in     vl_logic;
        operand_a       : in     vl_logic_vector(31 downto 0);
        operand_b       : in     vl_logic_vector(31 downto 0);
        opcode          : in     work.instr_register_pkg.opcode_t;
        write_pointer   : in     vl_logic_vector(4 downto 0);
        read_pointer    : in     vl_logic_vector(4 downto 0);
        instruction_word: out    work.instr_register_pkg.instruction_t
    );
end instr_register;
