module tflipflop
	(input logic Clk,
	 input logic Reset,
	 input logic T,
	 output logic Dout);
	 
	 always_ff @ (posedge Clk or negedge Reset)	
    begin
	 	 if (~Reset)
			  Dout <= 0;
		 else if (T)
			  Dout <= ~Dout;
	 end


	 
endmodule
