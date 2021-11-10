module weights_reg #(WIDTH=64*9) (input logic Reset,	
              output logic signed [WIDTH-1:0] Data_Out);	

	 logic [WIDTH-1:0] d_out;
	 assign Data_Out = d_out;
    always_ff @ (negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= {64'h00_71C71C71C71C71, {4{64'h00_1C71C71C71C71C}}, {4{64'h00_071C71C71C71C7}}};
		 else
			  d_out <= d_out;
	 end

endmodule
