library verilog;
use verilog.vl_types.all;
entity tb_weights_reg is
    generic(
        WIDTH           : integer := 576
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end tb_weights_reg;
