library verilog;
use verilog.vl_types.all;
entity mux12 is
    generic(
        DATA_WIDTH      : integer := 288
    );
    port(
        Din0            : in     vl_logic_vector;
        Din1            : in     vl_logic_vector;
        Din2            : in     vl_logic_vector;
        Din3            : in     vl_logic_vector;
        Din4            : in     vl_logic_vector;
        Din5            : in     vl_logic_vector;
        Din6            : in     vl_logic_vector;
        Din7            : in     vl_logic_vector;
        Din8            : in     vl_logic_vector;
        Din9            : in     vl_logic_vector;
        Din10           : in     vl_logic_vector;
        Din11           : in     vl_logic_vector;
        \select\        : in     vl_logic_vector(3 downto 0);
        Dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end mux12;
