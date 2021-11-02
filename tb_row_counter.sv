module tb_row_counter();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM = 16*16;
	parameter INIT_COUNT_WIDTH=$clog2(GRID_DIM);
	parameter COUNT_WIDTH=$clog2(GRID_DIM/16);
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	logic Clk;
	logic Reset;
	logic Enable;
	logic [INIT_COUNT_WIDTH-1:0] count_init;
	logic [COUNT_WIDTH-1:0] Data_out;
	
	counter_init #(.GRID_DIM(GRID_DIM), .ADDRESS_WIDTH(INIT_COUNT_WIDTH)) counter_init0 (.Clk(Clk), .Reset(Reset), .Enable(Enable), .Data_out(count_init));
	row_counter #(.GRID_DIM(GRID_DIM), .INIT_COUNT_WIDTH(INIT_COUNT_WIDTH), .COUNT_WIDTH(COUNT_WIDTH)) row_cnter (.*);
	
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
