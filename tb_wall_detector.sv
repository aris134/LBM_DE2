module tb_wall_detector();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM = 16*16;
	parameter INIT_COUNT_WIDTH=$clog2(GRID_DIM);
	parameter COUNT_WIDTH=$clog2(GRID_DIM/16);
	
	logic [INIT_COUNT_WIDTH-1:0] x;
	logic [COUNT_WIDTH-1:0] y;
	logic LID, BOTTOM_WALL, LEFT_WALL, RIGHT_WALL;
	
	wall_detector #(.GRID_DIM(GRID_DIM), .INIT_COUNT_WIDTH(INIT_COUNT_WIDTH), .COUNT_WIDTH(COUNT_WIDTH)) wall_detector0 (.*);
	
	initial begin
		#5 x = 13; // no wall
		   y = 3;
			
		#10 x = 15; // LID
			 y = 2;
			 
		#10 x = 0; // bottom wall
			 y = 5;
			 
		#10 x = 15; // left wall
			 y = 0;
			 
		#10 x = 9;
		    y = 15; // right wall
			 
		#10 x = 7; // no wall
			 y = 7;
		
		#10 $finish;
	end
	
endmodule
