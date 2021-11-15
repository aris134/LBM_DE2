module lfsr_56_gaus		// hard-coded to 56 here just to make it simple (would want to generalize)
				 (input logic Clk,
				  input logic Reset,
				  input logic [55:0] seed,
				  output logic [55:0] pseudo_rand_gaus);
	
    logic [55:0] d_out;
	 assign pseudo_rand_gaus = d_out;
	 
	 // based off https://ietresearch.onlinelibrary.wiley.com/doi/epdf/10.1049/el.2015.3418
	 logic feedback1;
	 logic feedback2;
	 logic feedback3;
	 logic feedback4;

	 assign feedback1 = (d_out[22] ~^ d_out[21]) ~^ (d_out[1] ~^ d_out[0]);
	 assign feedback2 = (d_out[55] ~^ d_out[54]) ~^ (d_out[1] ~^ d_out[0]);
	 assign feedback3 = (d_out[31] ~^ d_out[30]) ~^ (d_out[1] ~^ d_out[0]);
	 assign feedback4 = (d_out[15] ~^ d_out[14]) ~^ (d_out[1] ~^ d_out[0]);

	 feedback1 = feedback1 >> 1;
	 feedback2 = feedback2 >> 1;
	 feedback3 = feedback3 >> 1;
	 feedback4 = feedback4 >> 1;

	 feedback1 = feedback1 + feedback2;
	 feedback3 = feedback3 + feedback4;

	 feedback1 = feedback1 >> 1;
	 feedback3 = feedback3 >> 1;

	 feedback1 = feedback1 >> 1;
	 
	 always_ff @ (posedge Clk or negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= seed;
		 else
			  d_out <= {feedback1, d_out[55:1]};
	 end

endmodule

				