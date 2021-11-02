library verilog;
use verilog.vl_types.all;
entity controller is
    generic(
        DATA_WIDTH      : integer := 32;
        GRID_DIM        : integer := 256;
        ADDRESS_WIDTH   : vl_notype
    );
    port(
        Clk             : in     vl_logic;
        Reset           : in     vl_logic;
        count_init      : in     vl_logic_vector;
        div_valid       : in     vl_logic;
        WE_p_mem        : out    vl_logic;
        WE_ux_mem       : out    vl_logic;
        WE_uy_mem       : out    vl_logic;
        WE_fin_mem      : out    vl_logic;
        WE_fout_mem     : out    vl_logic;
        WE_feq_mem      : out    vl_logic;
        select_p        : out    vl_logic;
        select_ux       : out    vl_logic;
        select_uy       : out    vl_logic;
        select_fin      : out    vl_logic;
        count_init_en   : out    vl_logic;
        div_start       : out    vl_logic;
        LD_EN_P         : out    vl_logic;
        LD_EN_PUX       : out    vl_logic;
        LD_EN_PUY       : out    vl_logic;
        LD_EN_UX        : out    vl_logic;
        LD_EN_UY        : out    vl_logic;
        LD_EN_FEQ0      : out    vl_logic;
        LD_EN_FEQ1      : out    vl_logic;
        LD_EN_FEQ2      : out    vl_logic;
        LD_EN_FEQ3      : out    vl_logic;
        LD_EN_FEQ4      : out    vl_logic;
        LD_EN_FEQ5      : out    vl_logic;
        LD_EN_FEQ6      : out    vl_logic;
        LD_EN_FEQ7      : out    vl_logic;
        LD_EN_FEQ8      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of GRID_DIM : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 3;
end controller;