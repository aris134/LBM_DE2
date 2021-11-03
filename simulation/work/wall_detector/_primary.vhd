library verilog;
use verilog.vl_types.all;
entity wall_detector is
    generic(
        GRID_DIM        : integer := 256;
        INIT_COUNT_WIDTH: vl_notype;
        COUNT_WIDTH     : vl_notype
    );
    port(
        x               : in     vl_logic_vector;
        y               : in     vl_logic_vector;
        LID             : out    vl_logic;
        BOTTOM_WALL     : out    vl_logic;
        LEFT_WALL       : out    vl_logic;
        RIGHT_WALL      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of INIT_COUNT_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of COUNT_WIDTH : constant is 3;
end wall_detector;
