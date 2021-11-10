library verilog;
use verilog.vl_types.all;
entity tb_reg32 is
    generic(
        WIDTH           : integer := 64;
        CLK_PERIOD      : integer := 20
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end tb_reg32;
