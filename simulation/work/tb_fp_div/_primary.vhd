library verilog;
use verilog.vl_types.all;
entity tb_fp_div is
    generic(
        CLK_PERIOD      : integer := 20;
        WIDTH           : integer := 64;
        FBITS           : integer := 56
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of FBITS : constant is 1;
end tb_fp_div;
