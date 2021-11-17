module adder9 #(DATA_WIDTH=32) (input logic signed [DATA_WIDTH-1:0] Din0,
										  input logic signed [DATA_WIDTH-1:0] Din1,
										  input logic signed [DATA_WIDTH-1:0] Din2,
										  input logic signed [DATA_WIDTH-1:0] Din3,
										  input logic signed [DATA_WIDTH-1:0] Din4,
										  input logic signed [DATA_WIDTH-1:0] Din5,
										  input logic signed [DATA_WIDTH-1:0] Din6,
										  input logic signed [DATA_WIDTH-1:0] Din7,
										  input logic signed [DATA_WIDTH-1:0] Din8,
										  output logic signed [DATA_WIDTH-1:0] Dout);
										  
	assign Dout = Din0 + Din1 + Din2 + Din3 + Din4 + Din5 + Din6 + Din7 + Din8;
	
endmodule
