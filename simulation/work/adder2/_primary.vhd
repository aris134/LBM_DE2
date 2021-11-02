library verilog;
use verilog.vl_types.all;
entity adder2 is
    generic(
        DATA_WIDTH      : integer := 32
    );
    port(
        Din0            : in     vl_logic_vector;
        Din1            : in     vl_logic_vector;
        Dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end adder2;
