module tb_time_step_counter();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter MAX_TIME=100;
	parameter TIME_COUNT_WIDTH=$clog2(MAX_TIME);
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	logic Clk;
	logic Reset;
	logic Enable;
	logic [TIME_COUNT_WIDTH:0] Data_out;
	
	time_step_counter #(.MAX_TIME(MAX_TIME), .TIME_COUNT_WIDTH(TIME_COUNT_WIDTH)) timer (.*);
	
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
