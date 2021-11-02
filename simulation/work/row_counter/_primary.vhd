library verilog;
use verilog.vl_types.all;
entity row_counter is
    generic(
        GRID_DIM        : integer := 256;
        INIT_COUNT_WIDTH: vl_notype;
        COUNT_WIDTH     : vl_notype
    );
    port(
        Clk             : in     vl_logic;
        Reset           : in     vl_logic;
        Enable          : in     vl_logic;
        count_init      : in     vl_logic_vector;
        Data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of INIT_COUNT_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of COUNT_WIDTH : constant is 3;
end row_counter;
