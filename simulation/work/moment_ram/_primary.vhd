library verilog;
use verilog.vl_types.all;
entity moment_ram is
    generic(
        DEPTH           : integer := 256;
        ADDRESS_WIDTH   : vl_notype;
        DATA_WIDTH      : integer := 32
    );
    port(
        address         : in     vl_logic_vector;
        Clk             : in     vl_logic;
        WE              : in     vl_logic;
        data_in         : in     vl_logic_vector;
        data_out        : out    vl_logic_vector;
        mem_array       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end moment_ram;
