module tb_counter_init();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_SIZE = 16*16;
	parameter COUNT_SIZE=$clog2(GRID_SIZE);
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	logic Clk;
	logic Reset;
	logic Enable;
	logic [COUNT_SIZE-1:0] Data_out;
	
	counter_init #(.GRID_SIZE(GRID_SIZE), .COUNT_SIZE(COUNT_SIZE)) counter_init0 (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Clk = 0;
		Reset = 1;
		Enable = 0;
		// expected sum = 5 = 0x05_000000
		
		#10 Reset = 0;
		
		#15 Reset = 1;
		#5 Enable = 1;
		
		#5125 $finish;
	end
	
endmodule
