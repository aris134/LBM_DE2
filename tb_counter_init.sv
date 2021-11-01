module tb_counter_init();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM = 16*16;
	parameter ADDRESS_WIDTH=$clog2(GRID_DIM);
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	logic Clk;
	logic Reset;
	logic Enable;
	logic [ADDRESS_WIDTH-1:0] Data_out;
	
	counter_init #(.GRID_DIM(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH)) counter_init0 (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Clk = 0;
		Reset = 1;
		Enable = 0;
		
		#10 Reset = 0;
		
		#15 Reset = 1;
		#5 Enable = 1;
		
		#5125 $finish;
	end
	
endmodule
