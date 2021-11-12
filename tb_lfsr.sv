module tb_lfsr();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter DATA_WIDTH = 64;
	parameter FRACTIONAL_BITS = 56;
	parameter INTEGER_BITS = DATA_WIDTH - FRACTIONAL_BITS;
	
	logic Clk0 = 1'b0;
	logic Enable0 = 1'b1;

	logic signed [DATA_WIDTH-1:0] Din0 = 64'h02_000000_00000000;
	logic signed [DATA_WIDTH-1:0] Dout0;
	logic LFSR_d;
	
	lfsr #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) lfsr0
	(.Clk(Clk0),
	 .Enable(Enable0),
	 .Din(Din0),
	 .Dout(Dout0),
	 .LFSR_Done(LFSR_d)
	);
	
	initial begin
    		#10 Clk0 <= ~Clk0; 

    		#10 Clk0 <= ~Clk0; 

    		#10 Clk0 <= ~Clk0; 

    		#10 Clk0 <= ~Clk0; 

    		#10 Clk0 <= ~Clk0; 

    		#10 Clk0 <= ~Clk0; 

    		#10 Clk0 <= ~Clk0; 

    		#10 Clk0 <= ~Clk0; 

    		#10 Enable0 <= ~Enable0;
		// $display("%b",Dout0);
	end
	
endmodule
