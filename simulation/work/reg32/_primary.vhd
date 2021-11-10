library verilog;
use verilog.vl_types.all;
entity reg32 is
    generic(
        WIDTH           : integer := 64
    );
    port(
        Clk             : in     vl_logic;
        Reset           : in     vl_logic;
        LD_EN           : in     vl_logic;
        Data_In         : in     vl_logic_vector;
        Data_Out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end reg32;
