library verilog;
use verilog.vl_types.all;
entity div is
    generic(
        WIDTH           : integer := 32;
        FBITS           : integer := 24
    );
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        busy            : out    vl_logic;
        valid           : out    vl_logic;
        dbz             : out    vl_logic;
        ovf             : out    vl_logic;
        x               : in     vl_logic_vector;
        y               : in     vl_logic_vector;
        q               : out    vl_logic_vector;
        r               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of FBITS : constant is 1;
end div;
