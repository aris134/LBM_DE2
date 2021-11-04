module fp_to_unsigned #(INPUT_WIDTH=32, OUTPUT_WIDTH=8)
					     (input logic [INPUT_WIDTH-1:0] Data_In,
						   output logic [OUTPUT_WIDTH-1:0] Data_Out);

logic [OUTPUT_WIDTH-1:0] d_out;
assign Data_Out = d_out;			
always_comb
begin
	d_out = Data_In[INPUT_WIDTH-1:INPUT_WIDTH-OUTPUT_WIDTH];
end
endmodule
