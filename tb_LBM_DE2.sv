module tb_LBM_DE2();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM = 16*16;
	parameter DATA_WIDTH = 32;
	parameter ADDRESS_WIDTH = $clog2(GRID_DIM);
	parameter DATA_WIDTH_F=9*DATA_WIDTH;
	parameter FRACTIONAL_BITS = 24;
	parameter INTEGER_BITS=DATA_WIDTH-FRACTIONAL_BITS;
	
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	// inputs and outputs
	logic CLOCK_50;
	logic RESET;
	logic signed [DATA_WIDTH-1:0] p_mem_data_out;
	logic signed [DATA_WIDTH-1:0] ux_mem_data_out;
	logic signed [DATA_WIDTH-1:0] uy_mem_data_out;
	logic signed [DATA_WIDTH_F-1:0] fin_mem_data_out;
	
	LBM_DE2 #(.GRID_DIM(GRID_DIM), .DATA_WIDTH(DATA_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH_F(DATA_WIDTH_F), .FRACTIONAL_BITS(FRACTIONAL_BITS), .INTEGER_BITS(INTEGER_BITS)) LBM_DE2_0 (.*);
	
	always #(CLK_PERIOD / 2) CLOCK_50 = ~CLOCK_50;
	
	initial begin
		CLOCK_50 = 0;
		RESET = 1;
		
		#10 RESET = 0;
		
		#15 RESET = 1;
		
		#6000 $finish;
	end
	
endmodule
