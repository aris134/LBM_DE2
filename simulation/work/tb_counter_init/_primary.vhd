library verilog;
use verilog.vl_types.all;
entity tb_counter_init is
    generic(
        GRID_SIZE       : integer := 256;
        COUNT_SIZE      : vl_notype;
        CLK_PERIOD      : integer := 20
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_SIZE : constant is 1;
    attribute mti_svvh_generic_type of COUNT_SIZE : constant is 3;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end tb_counter_init;
