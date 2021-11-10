library verilog;
use verilog.vl_types.all;
entity tb_fp_mult is
    generic(
        DATA_WIDTH      : integer := 64;
        FRACTIONAL_BITS : integer := 56;
        INTEGER_BITS    : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of FRACTIONAL_BITS : constant is 1;
    attribute mti_svvh_generic_type of INTEGER_BITS : constant is 3;
end tb_fp_mult;
