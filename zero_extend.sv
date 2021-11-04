module zero_extend #(INPUT_WIDTH=4, OUTPUT_WIDTH=9) // adding extra 0 for sign bit (positive since unsigned number originally)
						  (input logic [INPUT_WIDTH-1:0] Data_In,
						   output logic [OUTPUT_WIDTH-1:0] Data_Out);

logic [OUTPUT_WIDTH-1:0] d_out;
assign Data_Out = d_out;			
always_comb
begin
	d_out = {{OUTPUT_WIDTH-INPUT_WIDTH{1'b0}}, Data_In};
end
endmodule
