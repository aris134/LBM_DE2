module adder2 #(DATA_WIDTH=64) (input logic signed [DATA_WIDTH-1:0] Din0,
										  input logic signed [DATA_WIDTH-1:0] Din1,
										  output logic signed [DATA_WIDTH-1:0] Dout);
										  
	assign Dout = Din0 + Din1;
	
endmodule
