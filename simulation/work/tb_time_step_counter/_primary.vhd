library verilog;
use verilog.vl_types.all;
entity tb_time_step_counter is
    generic(
        MAX_TIME        : integer := 100;
        TIME_COUNT_WIDTH: vl_notype;
        CLK_PERIOD      : integer := 20
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MAX_TIME : constant is 1;
    attribute mti_svvh_generic_type of TIME_COUNT_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end tb_time_step_counter;
