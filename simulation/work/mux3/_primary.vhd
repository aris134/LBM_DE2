library verilog;
use verilog.vl_types.all;
entity mux3 is
    generic(
        DATA_WIDTH      : integer := 32
    );
    port(
        Din0            : in     vl_logic_vector;
        Din1            : in     vl_logic_vector;
        Din2            : in     vl_logic_vector;
        \select\        : in     vl_logic_vector(1 downto 0);
        Dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end mux3;
