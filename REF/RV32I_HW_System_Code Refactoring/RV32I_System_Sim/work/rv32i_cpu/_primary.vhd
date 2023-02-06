library verilog;
use verilog.vl_types.all;
entity rv32i_cpu is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        pc              : out    vl_logic_vector(31 downto 0);
        inst            : in     vl_logic_vector(31 downto 0);
        MemWrite        : out    vl_logic;
        MemAddr         : out    vl_logic_vector(31 downto 0);
        MemWData        : out    vl_logic_vector(31 downto 0);
        ByteEnable      : out    vl_logic_vector(3 downto 0);
        MemRData        : in     vl_logic_vector(31 downto 0)
    );
end rv32i_cpu;
