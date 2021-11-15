module lfsr_56		// hard-coded to 56 here just to make it simple (would want to generalize)
				 (input logic Clk,
				  input logic Reset,
				  input logic [55:0] seed,
				  output logic [55:0] pseudo_rand);
	
    logic [55:0] d_out;
	 assign pseudo_rand = d_out;
	 
	 logic feedback;
	 assign feedback = (d_out[22] ~^ d_out[21]) ~^ (d_out[1] ~^ d_out[0]);
	 
	 always_ff @ (posedge Clk or negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= seed;
		 else
			  d_out <= {feedback, d_out[55:1]};
	 end

endmodule

				