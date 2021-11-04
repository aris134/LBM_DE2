library verilog;
use verilog.vl_types.all;
entity tb_zero_extend is
    generic(
        INPUT_WIDTH     : integer := 4;
        OUTPUT_WIDTH    : integer := 8
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_WIDTH : constant is 1;
end tb_zero_extend;
