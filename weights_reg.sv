module weights_reg #(WIDTH=32*9) (input logic Reset,	
              output logic signed [WIDTH-1:0] Data_Out);	

	 logic [WIDTH-1:0] d_out;
	 assign Data_Out = d_out;
    always_ff @ (negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= {32'h00_71C71C, {4{32'h00_1C71C7}}, {4{32'h00_071C71}}};
		 else
			  d_out <= d_out;
	 end

endmodule
