library verilog;
use verilog.vl_types.all;
entity convert_to_fp is
    generic(
        INPUT_WIDTH     : integer := 8;
        OUTPUT_WIDTH    : integer := 32;
        FBITS           : integer := 24
    );
    port(
        Data_In         : in     vl_logic_vector;
        Data_Out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of FBITS : constant is 1;
end convert_to_fp;
