library verilog;
use verilog.vl_types.all;
entity tb_wall_detector is
    generic(
        GRID_DIM        : integer := 256;
        INIT_COUNT_WIDTH: vl_notype;
        COUNT_WIDTH     : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of INIT_COUNT_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of COUNT_WIDTH : constant is 3;
end tb_wall_detector;
