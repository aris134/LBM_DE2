module sign_extender #(INPUT_WIDTH=8, OUTPUT_WIDTH=9) // input width of 8 for cx, cy
						  (input logic signed [INPUT_WIDTH-1:0] Data_In,
						   output logic signed [OUTPUT_WIDTH-1:0] Data_Out);

logic [OUTPUT_WIDTH-1:0] d_out;
assign Data_Out = d_out;			
always_comb
begin
	if (Data_In[INPUT_WIDTH-1] == 0) begin
		d_out = {{OUTPUT_WIDTH-INPUT_WIDTH{1'b0}}, Data_In};
	end
	else if (Data_In[INPUT_WIDTH-1] == 1) begin
		d_out = {{OUTPUT_WIDTH-INPUT_WIDTH{1'b1}}, Data_In};
	end else begin
		d_out = 0;
	end
end
endmodule
