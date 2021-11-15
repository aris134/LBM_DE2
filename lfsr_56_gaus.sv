module lfsr_56_gaus		// hard-coded to 56 here just to make it simple (would want to generalize)
				 (input logic Clk,
				  input logic Reset,
				  input logic [55:0] seed,
				  output logic [55:0] pseudo_rand_gaus);
	
    
	logic [55:0] interm_out1;
	logic [55:0] interm_out2;
	logic [55:0] interm_out3;
	logic [55:0] interm_out4;

	logic [55:0] interm_out1s;
	logic [55:0] interm_out2s;
	logic [55:0] interm_out3s;
	logic [55:0] interm_out4s;

	logic [55:0] interm_out5;
	logic [55:0] interm_out6;

	logic [55:0] interm_out5s;
	logic [55:0] interm_out6s;

	logic [55:0] interm_out7;
	logic [55:0] interm_out7s;

	logic [55:0] d_out;
	 assign pseudo_rand_gaus = d_out;
	 
	initial begin
	 // based off https://ietresearch.onlinelibrary.wiley.com/doi/epdf/10.1049/el.2015.3418
	 lfsr_56 (.Clk(Clk),
		 		.Reset(Reset),
				.seed(seed),
				.pseudo_rand(interm_out1));

	 lfsr_56 (.Clk(Clk),
		 		.Reset(Reset),
				.seed(seed),
				.pseudo_rand(interm_out2));

	 lfsr_56 (.Clk(Clk),
		 		.Reset(Reset),
				.seed(seed),
				.pseudo_rand(interm_out3));

	 lfsr_56 (.Clk(Clk),
		 		.Reset(Reset),
				.seed(seed),
				.pseudo_rand(interm_out4));

	 assign interm_out1s = interm_out1 >> 1;
	 assign interm_out2s = interm_out2 >> 1;
	 assign interm_out3s = interm_out3 >> 1;
	 assign interm_out4s = interm_out4 >> 1;

	 assign interm_out5 = interm_out1 + interm_out2; 
	 assign interm_out6 = interm_out3 + interm_out4 ;

	 assign interm_out5s = interm_out5 >> 1;
	 assign interm_out6s = interm_out6 >> 1;

	 assign interm_out7 = interm_out5 + interm_out6;

	 assign interm_out7s = interm_out7 >> 1;

	end
	 
	 always_ff @ (posedge Clk or negedge Reset)	
    begin
	 	 if (~Reset)
			  d_out <= seed;
		 else
			  d_out <= interm_out7s;
	 end

endmodule

				