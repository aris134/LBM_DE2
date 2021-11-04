library verilog;
use verilog.vl_types.all;
entity streaming_unit is
    generic(
        GRID_DIM        : integer := 256;
        ADDRESS_WIDTH   : vl_notype
    );
    port(
        x               : in     vl_logic_vector;
        y               : in     vl_logic_vector;
        cx              : in     vl_logic_vector;
        cy              : in     vl_logic_vector;
        write_addresses : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
end streaming_unit;
