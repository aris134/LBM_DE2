module tb_controller();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM = 16*16;
	parameter DATA_WIDTH = 32;
	
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	// inputs and outputs
	logic Clk, Reset;
	logic [7:0] count_init;
	logic WE_p_mem, WE_ux_mem, WE_uy_mem, WE_fin_mem, WE_fout_mem, WE_feq_mem;
	logic select_p, select_ux, select_uy, select_fin;
	logic count_init_en;
	logic LD_EN_P;
	
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
