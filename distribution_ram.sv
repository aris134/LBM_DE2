/*
	This module describes memory that stores distribution function vectors
	Each entry is a vector of 9 elements (hence the D2Q9) where each
	element corresponds to the particle population for one of the 9
	discrete velocities
*/

module distribution_ram #(DEPTH=16*16,
		ADDRESS_WIDTH=$clog2(DEPTH),
		DATA_WIDTH=32*9) (input logic [ADDRESS_WIDTH-1:0] address,
							 input Clk,
							 input WE,
							 input logic signed [DATA_WIDTH-1:0] data_in,
							 output logic signed [DATA_WIDTH-1:0] data_out);
		
		logic signed [DATA_WIDTH-1:0] mem [DEPTH-1:0];
				
		// assign data_out = mem[address];
		
		always @ (posedge Clk)
		begin
			if (WE)
				mem[address] <= data_in;
			data_out <= mem[address];
		end
endmodule 
