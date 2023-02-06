library verilog;
use verilog.vl_types.all;
entity controller is
    port(
        opcode          : in     vl_logic_vector(6 downto 0);
        funct7          : in     vl_logic_vector(6 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        auipc           : out    vl_logic;
        lui             : out    vl_logic;
        ALUSrc          : out    vl_logic;
        ALUcontrol      : out    vl_logic_vector(4 downto 0);
        branch          : out    vl_logic;
        jal             : out    vl_logic;
        jalr            : out    vl_logic;
        MemtoReg        : out    vl_logic;
        MemWrite        : out    vl_logic;
        RegWrite        : out    vl_logic
    );
end controller;
