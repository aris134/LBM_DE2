module tb_controller();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter DATA_WIDTH = 32;
	parameter GRID_DIM = 16*16;
	parameter ADDRESS_WIDTH = $clog2(GRID_DIM);
	parameter ADDRESS_WIDTH2 = $clog2(GRID_DIM) + 1;
	parameter MAX_TIME=100;
	parameter TIME_COUNT_WIDTH=$clog2(MAX_TIME);
	
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	// inputs and outputs
	logic Clk, Reset;
	logic [7:0] count_init;
	logic [TIME_COUNT_WIDTH:0] time_count;
	logic [ADDRESS_WIDTH-1:0] wall_address;
	logic div_valid;
	logic LID, BOTTOM_WALL, LEFT_WALL, RIGHT_WALL;
	logic WE_p_mem, WE_ux_mem, WE_uy_mem, WE_fin_mem, WE_fout_mem, WE_feq_mem, WE_f_streamed;
	logic select_p_mem, select_uy_mem;
	logic [1:0] select_ux_mem;
	logic [1:0] select_fin_mem;
	logic [3:0] select_f_streamed;
	logic [3:0] select_fin_addr;
	logic [1:0] select_ux_reg;
	logic select_moment_addr;
	logic select_p_reg, select_uy_reg;
	logic count_init_en;
	logic row_count_en;
	logic time_count_en;
	logic bc_addr_iter_en;
	logic div_start;
	logic [ADDRESS_WIDTH2-1:0] stream_addr0;
	logic [ADDRESS_WIDTH2-1:0] stream_addr1;
	logic [ADDRESS_WIDTH2-1:0] stream_addr2;
	logic [ADDRESS_WIDTH2-1:0] stream_addr3;
	logic [ADDRESS_WIDTH2-1:0] stream_addr4;
	logic [ADDRESS_WIDTH2-1:0] stream_addr5;
	logic [ADDRESS_WIDTH2-1:0] stream_addr6;
	logic [ADDRESS_WIDTH2-1:0] stream_addr7;
	logic [ADDRESS_WIDTH2-1:0] stream_addr8;
	logic signed [DATA_WIDTH-1:0] p_mem_array [GRID_DIM-1:0];
	logic signed [DATA_WIDTH-1:0] ux_mem_array [GRID_DIM-1:0];
	logic signed [DATA_WIDTH-1:0] uy_mem_array [GRID_DIM-1:0];
	logic signed [DATA_WIDTH-1:0] epsilon;
	logic can_pred;
	logic toggle_out;
	logic LD_EN_P;
	logic LD_EN_PUX;
	logic LD_EN_PUY;
	logic LD_EN_UX;
	logic LD_EN_UY;
	logic LD_EN_FEQ0;
	logic LD_EN_FEQ1;
	logic LD_EN_FEQ2;
	logic LD_EN_FEQ3;
	logic LD_EN_FEQ4;
	logic LD_EN_FEQ5;
	logic LD_EN_FEQ6;
	logic LD_EN_FEQ7;
	logic LD_EN_FEQ8;
	logic LD_EN_FOUT0;
	logic LD_EN_FOUT1;
	logic LD_EN_FOUT2;
	logic LD_EN_FOUT3;
	logic LD_EN_FOUT4;
	logic LD_EN_FOUT5;
	logic LD_EN_FOUT6;
	logic LD_EN_FOUT7;
	logic LD_EN_FOUT8;
	logic LD_EN_f_streamed_REG_0;
	logic LD_EN_f_streamed_REG_1;
	logic LD_EN_f_streamed_REG_2;
	logic LD_EN_f_streamed_REG_3;
	logic LD_EN_f_streamed_REG_4;
	logic LD_EN_f_streamed_REG_5;
	logic LD_EN_f_streamed_REG_6;
	logic LD_EN_f_streamed_REG_7;
	logic LD_EN_f_streamed_REG_8;
	logic LD_EN_UX_PRED;
	logic LD_EN_UY_PRED;
	logic rand_en;
	logic tog;
	logic FINISH;
	
	controller #(.GRID_DIM(GRID_DIM), .DATA_WIDTH(DATA_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .ADDRESS_WIDTH2(ADDRESS_WIDTH2),
					 .MAX_TIME(MAX_TIME), .TIME_COUNT_WIDTH(TIME_COUNT_WIDTH)) controller0 (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Clk = 0;
		Reset = 1;
		count_init = 0;
		
		#10 Reset = 0;
		
		#15 Reset = 1;
		
		#20 count_init = count_init + 1'b1;
		
		#20 count_init = count_init + 1'b1;
		
		#20 count_init = count_init + 1'b1;
		
		#20 count_init = count_init + 1'b1;
		
		#20 count_init = count_init + 1'b1;
		
		#20 count_init = 9'b111111111;
		
		#20 $finish;
	end
	
endmodule
