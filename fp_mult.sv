module fp_mult
	#(parameter FRACTIONAL_BITS=24,
		parameter DATA_WIDTH=32,
		parameter INTEGER_BITS=DATA_WIDTH-FRACTIONAL_BITS) (
	
	input logic signed [DATA_WIDTH-1:0] Din0,
	input logic signed [DATA_WIDTH-1:0] Din1,
	output logic signed [DATA_WIDTH-1:0] Dout);
	
	logic signed [2*DATA_WIDTH-1:0] product;
	
	always @ (Din0 or Din1) begin
		product = (Din0 * Din1);
		Dout = product[2*FRACTIONAL_BITS+INTEGER_BITS-1:2*FRACTIONAL_BITS-FRACTIONAL_BITS];
	end
	
endmodule
