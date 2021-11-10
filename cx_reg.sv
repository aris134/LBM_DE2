module cx_reg #(WIDTH=64*9) (input logic Reset,	
              output logic signed [WIDTH-1:0] Data_Out);	

	 logic [WIDTH-1:0] d_out;
	 assign Data_Out = d_out;
    always_ff @ (negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= {64'h00_00000000000000, 64'h01_00000000000000, 64'h00_00000000000000, 64'hFF_00000000000000, 64'h00_00000000000000, 64'h01_00000000000000, 64'hFF_00000000000000, 64'hFF_00000000000000, 64'h01_00000000000000};
		 else
			  d_out <= d_out;
	 end

endmodule
