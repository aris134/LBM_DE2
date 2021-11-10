module reg32 #(WIDTH=64) (input logic Clk, Reset, LD_EN,
								  input logic signed [WIDTH-1:0] Data_In,
								  output logic signed [WIDTH-1:0] Data_Out);	

	 logic [WIDTH-1:0] d_out;
	 assign Data_Out = d_out;
    always_ff @ (posedge Clk or negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= 0;
		 else if (LD_EN)
			  d_out <= Data_In;
	 end

endmodule
