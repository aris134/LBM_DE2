library verilog;
use verilog.vl_types.all;
entity tb_fp_to_unsigned is
    generic(
        INPUT_WIDTH     : integer := 32;
        OUTPUT_WIDTH    : integer := 8
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_WIDTH : constant is 1;
end tb_fp_to_unsigned;
