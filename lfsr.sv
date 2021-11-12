module lfsr
	#(parameter FRACTIONAL_BITS=56,
		parameter DATA_WIDTH=64,
		parameter INTEGER_BITS=DATA_WIDTH-FRACTIONAL_BITS) (
	
	input Clk,
	input Enable, // whether to run the LFSR
	input logic signed [DATA_WIDTH-1:0] Din, // seed value

	output logic signed [DATA_WIDTH-1:0] Dout, // output value
	output logic LFSR_Done); // signal that output is ready
	
	logic signed [DATA_WIDTH-1:0] r_LFSR = 0;
	logic signed r_XNOR;
	
	// if enabled, shift the register on rising clock edge
	always @(posedge Clk) begin
      		if (Enable == 1'b1)
           		r_LFSR <= {r_LFSR[DATA_WIDTH-1:1], r_XNOR};
    	end

	// calculate new pseudorandom value
	always @(*) begin
		r_XNOR = r_LFSR[64] ^~ r_LFSR[63] ^~ r_LFSR[61] ^~ r_LFSR[60];
	end

	// assign output from LFSR register
	assign Dout = r_LFSR[DATA_WIDTH:1];
	// signify whether LFSR operation is complete
	assign LFSR_Done = (r_LFSR[DATA_WIDTH:1] == Din) ? 1'b1 : 1'b0;	

endmodule
