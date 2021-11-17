module tb_fp_mult();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter DATA_WIDTH = 32;
	parameter FRACTIONAL_BITS = 24;
	parameter INTEGER_BITS = DATA_WIDTH - FRACTIONAL_BITS;
	
	logic signed [DATA_WIDTH-1:0] Din0;
	logic signed [DATA_WIDTH-1:0] Din1;
	logic signed [DATA_WIDTH-1:0] Dout;
	
	fp_mult #(.FRACTIONAL_BITS(FRACTIONAL_BITS), .DATA_WIDTH(DATA_WIDTH), .INTEGER_BITS(INTEGER_BITS)) fp_mult0 (.*);
	
	initial begin
		Din0 = 32'h02_000000; // 2
		Din1 = 32'h02_800000; // 2.5
		// expected sum = 5 = 0x05_000000
		
		#10 Din0 = 32'h01_A80000; // 1.65625
		Din1 = 32'h00_A00000; // 0.625
		// expected sum = 1.03515625 = 0x01090000
		
		#10 Din0 = 32'h03_000000; // 3
		Din1 = 32'hFF_200000; // -0.875
		// expected sum = -2.625 = 0xFD_600000;
		
		#10 Din0 = 32'hFC_240000; // -3.859375
		// expected sum = 3.376953125
		
		#10 $finish;
	end
	
endmodule
