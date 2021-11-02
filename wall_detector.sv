module wall_detector #(GRID_DIM = 16*16, INIT_COUNT_WIDTH = $clog2(GRID_DIM), COUNT_WIDTH=$clog2(GRID_DIM/16)) (
							  input logic Reset, Clear, // Clear comes from controller
							  input logic [INIT_COUNT_WIDTH-1:0] x,
							  input logic [COUNT_WIDTH-1:0] y,
							  output logic LID, BOTTOM_WALL, LEFT_WALL, RIGHT_WALL);


always_ff @ (negedge Reset or posedge Clear)	
    begin
	 	 if (~Reset) begin
			  LID <= 1'b0;
			  BOTTOM_WALL <= 1'b0;
			  LEFT_WALL <= 1'b0;
			  RIGHT_WALL <= 1'b0;
		 end else if (y >= 1 & y <= 14 & x == 15) begin
			  LID <= 1'b1;
		 end else if (x == 0) begin
			  BOTTOM_WALL = 1'b1;
		 end else if (y == 0) begin
			  LEFT_WALL = 1'b1;
		 end else if (y == 15) begin
			  RIGHT_WALL = 1'b1;
		 end
	 end
endmodule
