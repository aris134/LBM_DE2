library verilog;
use verilog.vl_types.all;
entity tb_streaming_unit is
    generic(
        GRID_DIM        : integer := 256;
        SIDE_LENGTH     : vl_notype;
        ADDRESS_WIDTH   : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of SIDE_LENGTH : constant is 3;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
end tb_streaming_unit;
