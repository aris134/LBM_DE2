library verilog;
use verilog.vl_types.all;
entity cy_reg is
    generic(
        WIDTH           : integer := 576
    );
    port(
        Reset           : in     vl_logic;
        Data_Out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end cy_reg;
