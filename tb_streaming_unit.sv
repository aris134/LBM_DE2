module tb_streaming_unit();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM=16*16;
	parameter ADDRESS_WIDTH=$clog2(GRID_DIM)+1;
	
	logic signed [ADDRESS_WIDTH-1:0] x; // reminder: width = address_width + 1 
	logic signed [ADDRESS_WIDTH-1:0] y;
	logic signed [9*ADDRESS_WIDTH-1:0] cx;
	logic signed [9*ADDRESS_WIDTH-1:0] cy;
	logic [9*ADDRESS_WIDTH-1:0] write_addresses;
	
	streaming_unit #(.GRID_DIM(GRID_DIM)) streamer (.*);
	
	initial begin
		#5 cx = {9'b0_0000_0000, 9'b0_0000_0001, 9'b0_0000_0000, 9'b1_1111_1111, 9'b0_0000_0000, 9'b0_0000_0001, 9'b1_1111_1111, 9'b1_1111_1111, 9'b0_0000_0001};
			cy = {9'b0_0000_0000, 9'b0_0000_0000, 9'b1_1111_1111, 9'b0_0000_0000, 9'b0_0000_0001, 9'b1_1111_1111, 9'b1_1111_1111, 9'b0_0000_0001, 9'b0_0000_0001};
			x = 9'b0_0000_0000; // NW corner
			y = 9'b0_0000_0000;
		
		#10 $finish;
	end
	
endmodule
