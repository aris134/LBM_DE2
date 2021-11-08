module distribution_ram #(DEPTH=16*16,
		ADDRESS_WIDTH=$clog2(DEPTH),
		DATA_WIDTH=32*9) (input logic [ADDRESS_WIDTH-1:0] address,
							 input Clk,
							 input WE,
							 input logic signed [DATA_WIDTH-1:0] data_in,
							 output logic signed [DATA_WIDTH-1:0] data_out);
		
		logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];
		// assign data_out = mem[address];
		
		always @ (posedge Clk)
		begin
			if (WE) begin
				mem[address] <= data_in;
				data_out <= mem[address]; ///// this line was just added
			end	
		end
endmodule
