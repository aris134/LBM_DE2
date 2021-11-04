library verilog;
use verilog.vl_types.all;
entity tb_sign_extend is
    generic(
        INPUT_WIDTH     : integer := 8;
        OUTPUT_WIDTH    : integer := 9
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_WIDTH : constant is 1;
end tb_sign_extend;
