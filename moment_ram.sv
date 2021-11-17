/*
	This module describes memory that stores moment data (ux, uy, p, etc.)
*/

module moment_ram #(DEPTH=16*16,
		ADDRESS_WIDTH=$clog2(DEPTH),
		DATA_WIDTH=32) (input logic [ADDRESS_WIDTH-1:0] address,
							 input Clk,
							 input WE,
							 input logic signed [DATA_WIDTH-1:0] data_in,
							 output logic signed [DATA_WIDTH-1:0] data_out,
							 output logic signed [DATA_WIDTH-1:0] mem_array [DEPTH-1:0]); // for testing purposes
		
		logic signed [DATA_WIDTH-1:0] mem [DEPTH-1:0];
		assign mem_array = mem; // for testing purposes
		
		always @ (posedge Clk)
		begin
			if (WE)
				mem[address] <= data_in;
			data_out <= mem[address];
		end
endmodule
