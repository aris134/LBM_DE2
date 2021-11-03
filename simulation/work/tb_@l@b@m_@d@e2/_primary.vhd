library verilog;
use verilog.vl_types.all;
entity tb_LBM_DE2 is
    generic(
        GRID_DIM        : integer := 256;
        DATA_WIDTH      : integer := 32;
        ADDRESS_WIDTH   : vl_notype;
        COUNT_WIDTH     : vl_notype;
        DATA_WIDTH_F    : vl_notype;
        FRACTIONAL_BITS : integer := 24;
        INTEGER_BITS    : vl_notype;
        CLK_PERIOD      : integer := 20
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of COUNT_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of DATA_WIDTH_F : constant is 3;
    attribute mti_svvh_generic_type of FRACTIONAL_BITS : constant is 1;
    attribute mti_svvh_generic_type of INTEGER_BITS : constant is 3;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end tb_LBM_DE2;
