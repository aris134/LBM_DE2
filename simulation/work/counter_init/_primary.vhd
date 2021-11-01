library verilog;
use verilog.vl_types.all;
entity counter_init is
    generic(
        GRID_DIM        : integer := 256;
        ADDRESS_WIDTH   : vl_notype
    );
    port(
        Clk             : in     vl_logic;
        Reset           : in     vl_logic;
        Enable          : in     vl_logic;
        Data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
end counter_init;
