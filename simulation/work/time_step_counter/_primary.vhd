library verilog;
use verilog.vl_types.all;
entity time_step_counter is
    generic(
        MAX_TIME        : integer := 8;
        TIME_COUNT_WIDTH: vl_notype
    );
    port(
        Clk             : in     vl_logic;
        Reset           : in     vl_logic;
        Enable          : in     vl_logic;
        Data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MAX_TIME : constant is 1;
    attribute mti_svvh_generic_type of TIME_COUNT_WIDTH : constant is 3;
end time_step_counter;
