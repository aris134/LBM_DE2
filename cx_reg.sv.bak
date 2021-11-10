module cx_reg #(WIDTH=32*9) (input logic Reset,	
              output logic signed [WIDTH-1:0] Data_Out);	

	 logic [WIDTH-1:0] d_out;
	 assign Data_Out = d_out;
    always_ff @ (negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= {32'h00_000000, 32'h01_000000, 32'h00_000000, 32'hFF_000000, 32'h00_000000, 32'h01_000000, 32'hFF_000000, 32'hFF_000000, 32'h01_000000};
		 else
			  d_out <= d_out;
	 end

endmodule
