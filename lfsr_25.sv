module lfsr_25 // MSB is sign bit
				 (input logic Clk,
				  input logic Enable,
				  input logic Reset,
				  input logic signed [24:0] seed,
				  output logic signed [24:0] pseudo_rand);
	
    logic signed [24:0] d_out;
	 assign pseudo_rand = d_out;
	 
	 logic feedback;
	 assign feedback = d_out[0] ~^ d_out[3]; // taps for maximum cycle length
	 
	 always_ff @ (posedge Clk or negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= seed;
		 else if (Enable)
			  d_out <= {feedback, d_out[24:1]};
	 end

endmodule

				