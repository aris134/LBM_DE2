library verilog;
use verilog.vl_types.all;
entity tb_controller is
    generic(
        GRID_DIM        : integer := 256;
        DATA_WIDTH      : integer := 32;
        CLK_PERIOD      : integer := 20
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end tb_controller;
