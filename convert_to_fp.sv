module convert_to_fp #(INPUT_WIDTH=8, OUTPUT_WIDTH=32, FBITS=24)
					     (input logic [INPUT_WIDTH-1:0] Data_In,
						   output logic [OUTPUT_WIDTH-1:0] Data_Out);

logic [OUTPUT_WIDTH-1:0] d_out;
assign Data_Out = d_out;			
always_comb
begin
	d_out = {{OUTPUT_WIDTH-INPUT_WIDTH{1'b0}}, Data_In}; // zero extend to 32 bits
	d_out = d_out << FBITS; // convert to fixed point
end

endmodule
