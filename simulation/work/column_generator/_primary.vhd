library verilog;
use verilog.vl_types.all;
entity column_generator is
    generic(
        GRID_DIM        : integer := 16;
        ADDRESS_WIDTH   : vl_notype
    );
    port(
        Clk             : in     vl_logic;
        start           : in     vl_logic;
        count_init      : in     vl_logic_vector;
        column          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
end column_generator;
