module tb_wall_detector();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM = 16*16;
	parameter INIT_COUNT_WIDTH=$clog2(GRID_DIM);
	parameter COUNT_WIDTH=$clog2(GRID_DIM/16);
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	logic Reset;
	logic Clear;
	logic [INIT_COUNT_WIDTH-1:0] x;
	logic [COUNT_WIDTH-1:0] y;
	logic LID, BOTTOM_WALL, LEFT_WALL, RIGHT_WALL;
	
	wall_detector #(.GRID_DIM(GRID_DIM), .INIT_COUNT_WIDTH(INIT_COUNT_WIDTH), .COUNT_WIDTH(COUNT_WIDTH)) wall_detector0 (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Reset = 1;
		Clear = 0;
		
		#10 Reset = 0;
		
		#5 Reset = 1;
		
		#5 x = 13; // make sure no wall signals are asserted
		   y = 3;
			
		#10 x = 15; // LID
			 y = 2;
			 
		#10 x = 
		
		#10 $finish;
	end
	
endmodule
