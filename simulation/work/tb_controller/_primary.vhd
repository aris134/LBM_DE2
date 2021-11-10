library verilog;
use verilog.vl_types.all;
entity tb_controller is
    generic(
        DATA_WIDTH      : integer := 64;
        GRID_DIM        : integer := 256;
        ADDRESS_WIDTH   : vl_notype;
        ADDRESS_WIDTH2  : vl_notype;
        MAX_TIME        : integer := 100;
        TIME_COUNT_WIDTH: vl_notype;
        CLK_PERIOD      : integer := 20
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH2 : constant is 3;
    attribute mti_svvh_generic_type of MAX_TIME : constant is 1;
    attribute mti_svvh_generic_type of TIME_COUNT_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end tb_controller;
