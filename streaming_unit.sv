module streaming_unit #(GRID_DIM=16*16, ADDRESS_WIDTH=$clog2(GRID_DIM)+1)
							  (input logic signed [ADDRESS_WIDTH-1:0] x,
							   input logic signed [ADDRESS_WIDTH-1:0] y, // zero extended from 4 to 8 bits
								input logic signed [9*ADDRESS_WIDTH-1:0] cx, // sign extended by one bit
								input logic signed [9*ADDRESS_WIDTH-1:0] cy, // sign extended by one bit
								output logic [9*ADDRESS_WIDTH-1:0] write_addresses); // extra bit at the front of each address to indicate whether the address is valid (e.g., corner)
								
logic signed [ADDRESS_WIDTH-1:0] x_stream0;
logic signed [ADDRESS_WIDTH-1:0] y_stream0;
logic signed [ADDRESS_WIDTH-1:0] x_stream1;
logic signed [ADDRESS_WIDTH-1:0] y_stream1;	
logic signed [ADDRESS_WIDTH-1:0] x_stream2;
logic signed [ADDRESS_WIDTH-1:0] y_stream2;	
logic signed [ADDRESS_WIDTH-1:0] x_stream3;
logic signed [ADDRESS_WIDTH-1:0] y_stream3;	
logic signed [ADDRESS_WIDTH-1:0] x_stream4;
logic signed [ADDRESS_WIDTH-1:0] y_stream4;	
logic signed [ADDRESS_WIDTH-1:0] x_stream5;
logic signed [ADDRESS_WIDTH-1:0] y_stream5;	
logic signed [ADDRESS_WIDTH-1:0] x_stream6;
logic signed [ADDRESS_WIDTH-1:0] y_stream6;	
logic signed [ADDRESS_WIDTH-1:0] x_stream7;
logic signed [ADDRESS_WIDTH-1:0] y_stream7;	
logic signed [ADDRESS_WIDTH-1:0] x_stream8;
logic signed [ADDRESS_WIDTH-1:0] y_stream8;	
// need to take off sign bit from final address calculation since addresses are unsigned
always_comb
begin
	x_stream0 = x + cx[9*ADDRESS_WIDTH-1:8*ADDRESS_WIDTH];
	y_stream0 = y + cy[9*ADDRESS_WIDTH-1:8*ADDRESS_WIDTH];
	write_addresses[9*ADDRESS_WIDTH-1:8*ADDRESS_WIDTH] = ((x_stream0 < 0 | x_stream0 >= GRID_DIM) | (y_stream0 < 0 | y_stream0 >= GRID_DIM)) ? -1 : 16*y_stream0 + x_stream0;
	
	x_stream1 = x + cx[8*ADDRESS_WIDTH-1:7*ADDRESS_WIDTH];
	y_stream1 = y + cy[8*ADDRESS_WIDTH-1:7*ADDRESS_WIDTH];
	write_addresses[8*ADDRESS_WIDTH-1:7*ADDRESS_WIDTH] = ((x_stream1 < 0 | x_stream1 >= GRID_DIM) | (y_stream1 < 0 | y_stream1 >= GRID_DIM)) ? -1 : 16*y_stream1 + x_stream1;
	
	x_stream2 = x + cx[7*ADDRESS_WIDTH-1:6*ADDRESS_WIDTH];
	y_stream2 = y + cy[7*ADDRESS_WIDTH-1:6*ADDRESS_WIDTH];
	write_addresses[7*ADDRESS_WIDTH-1:6*ADDRESS_WIDTH] = ((x_stream2 < 0 | x_stream2 >= GRID_DIM) | (y_stream2 < 0 | y_stream2 >= GRID_DIM)) ? -1 : 16*y_stream2 + x_stream2;
	
	x_stream3 = x + cx[6*ADDRESS_WIDTH-1:5*ADDRESS_WIDTH];
	y_stream3 = y + cy[6*ADDRESS_WIDTH-1:5*ADDRESS_WIDTH];
	write_addresses[6*ADDRESS_WIDTH-1:5*ADDRESS_WIDTH] = ((x_stream3 < 0 | x_stream3 >= GRID_DIM) | (y_stream3 < 0 | y_stream3 >= GRID_DIM)) ? -1 : 16*y_stream3 + x_stream3;
	
	x_stream4 = x + cx[5*ADDRESS_WIDTH-1:4*ADDRESS_WIDTH];
	y_stream4 = y + cy[5*ADDRESS_WIDTH-1:4*ADDRESS_WIDTH];
	write_addresses[5*ADDRESS_WIDTH-1:4*ADDRESS_WIDTH] = ((x_stream4 < 0 | x_stream4 >= GRID_DIM) | (y_stream4 < 0 | y_stream4 >= GRID_DIM)) ? -1 : 16*y_stream4 + x_stream4;
	
	x_stream5 = x + cx[4*ADDRESS_WIDTH-1:3*ADDRESS_WIDTH];
	y_stream5 = y + cy[4*ADDRESS_WIDTH-1:3*ADDRESS_WIDTH];
	write_addresses[4*ADDRESS_WIDTH-1:3*ADDRESS_WIDTH] = ((x_stream5 < 0 | x_stream5 >= GRID_DIM) | (y_stream5 < 0 | y_stream5 >= GRID_DIM)) ? -1 : 16*y_stream5 + x_stream5;
	
	x_stream6 = x + cx[3*ADDRESS_WIDTH-1:2*ADDRESS_WIDTH];
	y_stream6 = y + cy[3*ADDRESS_WIDTH-1:2*ADDRESS_WIDTH];
	write_addresses[3*ADDRESS_WIDTH-1:2*ADDRESS_WIDTH] = ((x_stream6 < 0 | x_stream6 >= GRID_DIM) | (y_stream6 < 0 | y_stream6 >= GRID_DIM)) ? -1 : 16*y_stream6 + x_stream6;
	
	x_stream7 = x + cx[2*ADDRESS_WIDTH-1:ADDRESS_WIDTH];
	y_stream7 = y + cy[2*ADDRESS_WIDTH-1:ADDRESS_WIDTH];
	write_addresses[2*ADDRESS_WIDTH-1:ADDRESS_WIDTH] = ((x_stream7 < 0 | x_stream7 >= GRID_DIM) | (y_stream7 < 0 | y_stream7 >= GRID_DIM)) ? -1 : 16*y_stream7 + x_stream7;
	
	x_stream8 = x + cx[ADDRESS_WIDTH-1:0];
	y_stream8 = y + cy[ADDRESS_WIDTH-1:0];
	write_addresses[ADDRESS_WIDTH-1:0] = ((x_stream8 < 0 | x_stream8 >= GRID_DIM) | (y_stream8 < 0 | y_stream8 >= GRID_DIM)) ? -1 : 16*y_stream8 + x_stream8;
	
end
			  
endmodule
