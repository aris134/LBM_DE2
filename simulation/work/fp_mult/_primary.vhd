library verilog;
use verilog.vl_types.all;
entity fp_mult is
    generic(
        FRACTIONAL_BITS : integer := 56;
        DATA_WIDTH      : integer := 64;
        INTEGER_BITS    : vl_notype
    );
    port(
        Din0            : in     vl_logic_vector;
        Din1            : in     vl_logic_vector;
        Dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FRACTIONAL_BITS : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of INTEGER_BITS : constant is 3;
end fp_mult;
