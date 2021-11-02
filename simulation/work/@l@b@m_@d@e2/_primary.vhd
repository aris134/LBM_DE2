library verilog;
use verilog.vl_types.all;
entity LBM_DE2 is
    generic(
        GRID_DIM        : integer := 256;
        DATA_WIDTH      : integer := 32;
        ADDRESS_WIDTH   : vl_notype;
        DATA_WIDTH_F    : vl_notype;
        FRACTIONAL_BITS : integer := 24;
        INTEGER_BITS    : vl_notype
    );
    port(
        CLOCK_50        : in     vl_logic;
        RESET           : in     vl_logic;
        p_mem_data_out  : out    vl_logic_vector;
        ux_mem_data_out : out    vl_logic_vector;
        uy_mem_data_out : out    vl_logic_vector;
        fin_mem_data_out: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of DATA_WIDTH_F : constant is 3;
    attribute mti_svvh_generic_type of FRACTIONAL_BITS : constant is 1;
    attribute mti_svvh_generic_type of INTEGER_BITS : constant is 3;
end LBM_DE2;