library verilog;
use verilog.vl_types.all;
entity tb_adder9 is
    generic(
        DATA_WIDTH      : integer := 64
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end tb_adder9;
