module tb_controller();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM = 16*16;
	parameter DATA_WIDTH = 32;
	
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	// inputs and outputs
	logic Clk, Reset;
	logic [7:0] count_init;
	logic div_valid;
	logic LID, BOTTOM_WALL, LEFT_WALL, RIGHT_WALL;
	logic WE_p_mem, WE_ux_mem, WE_uy_mem, WE_fin_mem, WE_fout_mem, WE_feq_mem;
	logic select_p_mem, select_ux_mem, select_uy_mem, select_fin_mem;
	logic [1:0] select_ux_reg;
	logic select_p_reg, select_uy_reg;
	logic count_init_en;
	logic div_start;
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
	
	controller #(.GRID_DIM(GRID_DIM), .DATA_WIDTH(DATA_WIDTH)) controller0 (.*);
	
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
