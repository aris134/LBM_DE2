library verilog;
use verilog.vl_types.all;
entity sign_extend is
    generic(
        INPUT_WIDTH     : integer := 8;
        OUTPUT_WIDTH    : integer := 9
    );
    port(
        Data_In         : in     vl_logic_vector;
        Data_Out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_WIDTH : constant is 1;
end sign_extend;
