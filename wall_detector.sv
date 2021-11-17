module wall_detector #(GRID_DIM = 16*16, INIT_COUNT_WIDTH = $clog2(GRID_DIM), COUNT_WIDTH=$clog2(GRID_DIM/16)) (
							  input logic [INIT_COUNT_WIDTH-1:0] x,
							  input logic [COUNT_WIDTH-1:0] y,
							  output logic LID, BOTTOM_WALL, LEFT_WALL, RIGHT_WALL);
							  


always_comb
    begin
		 if (x >= 1 & x <= 14 & y == 15) begin
			  LID = 1'b1;
			  BOTTOM_WALL = 1'b0;
			  LEFT_WALL = 1'b0;
			  RIGHT_WALL = 1'b0;
		 end else if (x == 0) begin
			  BOTTOM_WALL = 1'b1;
			  LID = 1'b0;
			  LEFT_WALL = 1'b0;
			  RIGHT_WALL = 1'b0;
		 end else if (y == 0) begin
			  LEFT_WALL = 1'b1;
			  LID = 1'b0;
			  BOTTOM_WALL = 1'b0;
			  RIGHT_WALL = 1'b0;
		 end else if (x == 15) begin
			  RIGHT_WALL = 1'b1;
			  LID = 1'b0;
			  LEFT_WALL = 1'b0;
			  BOTTOM_WALL = 1'b0;
		 end
		 else begin
			  LID = 1'b0;
			  BOTTOM_WALL = 1'b0;
			  LEFT_WALL = 1'b0;
			  RIGHT_WALL = 1'b0;
		 end
	 end
endmodule
