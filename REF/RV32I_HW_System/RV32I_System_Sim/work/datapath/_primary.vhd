library verilog;
use verilog.vl_types.all;
entity datapath is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        inst            : in     vl_logic_vector(31 downto 0);
        auipc           : in     vl_logic;
        lui             : in     vl_logic;
        RegWrite        : in     vl_logic;
        MemtoReg        : in     vl_logic;
        MemWrite        : in     vl_logic;
        ALUSrc          : in     vl_logic;
        ALUcontrol      : in     vl_logic_vector(4 downto 0);
        branch          : in     vl_logic;
        jal             : in     vl_logic;
        jalr            : in     vl_logic;
        pc              : out    vl_logic_vector(31 downto 0);
        aluout          : out    vl_logic_vector(31 downto 0);
        MemWData        : out    vl_logic_vector(31 downto 0);
        ByteEnable      : out    vl_logic_vector(3 downto 0);
        MemRData        : in     vl_logic_vector(31 downto 0)
    );
end datapath;
