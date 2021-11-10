library verilog;
use verilog.vl_types.all;
entity tb_moment_ram is
    generic(
        DEPTH           : integer := 256;
        ADDRESS_WIDTH   : vl_notype;
        DATA_WIDTH      : integer := 64;
        CLK_PERIOD      : integer := 20
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end tb_moment_ram;
