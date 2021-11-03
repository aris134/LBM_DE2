module streaming_unit #(GRID_DIM=16*16, DATA_WIDTH=32, ADDRESS_WIDTH=$clog2(GRID_DIM))
							  (input logic [DATA_WIDTH-1:0] x,
							   input logic [DATA_WIDTH-1:0] y,
								input logic [9*DATA_WIDTH-1:0] cx,
								input logic [9*DATA_WIDTH-1:0] cy,
							   output logic [3:0] num_writes,
								output logic signed [9*ADDRESS_WIDTH:0] write_addresses); // extra bit at the front of each address to indicate whether the address is valid (e.g., corner)
								

logic [DATA_WIDTH-1:0] x_stream;
logic [DATA_WIDTH-1:0] y_stream;
logic 							
always_comb
begin
	int i;
	for (i = 0; i < 9; i = i + 1)
		x_stream = x + cx[(9-i)*DATA_WIDTH-1:(8-i)*DATA_WIDTH];
		y_stream = y + cy[(9-i)*DATA_WIDTH-1:(8-i)*DATA_WIDTH];
		
end
							  

endmodule
