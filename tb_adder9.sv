module tb_adder9();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter DATA_WIDTH = 64;
	
	logic signed [DATA_WIDTH-1:0] Din0;
   logic signed [DATA_WIDTH-1:0] Din1;
	logic signed [DATA_WIDTH-1:0] Din2;
	logic signed [DATA_WIDTH-1:0] Din3;
   logic signed [DATA_WIDTH-1:0] Din4;
	logic signed [DATA_WIDTH-1:0] Din5;
	logic signed [DATA_WIDTH-1:0] Din6;
   logic signed [DATA_WIDTH-1:0] Din7;
	logic signed [DATA_WIDTH-1:0] Din8;
	logic signed [DATA_WIDTH-1:0] Dout;
	
	adder9 #(.DATA_WIDTH(DATA_WIDTH)) adder0 (.*);
	
	initial begin
		Din0 = 64'h01_000000_00000000; // 1 (Q8.24)
		Din1 = 64'h02_000000_00000000; // 2
		Din2 = 64'h03_000000_00000000; // 3
		Din3 = 64'h04_000000_00000000; // 4
		Din4 = 64'h05_000000_00000000; // 5
		Din5 = 64'h06_000000_00000000; // 6
		Din6 = 64'h07_000000_00000000; // 7
		Din7 = 64'h08_000000_00000000; // 8
		Din8 = 64'h09_000000_00000000; // 9
		// expected sum = 0x2D_000000 = 45
		
		#10 Din8 = 64'hF7_000000_00000000; // -9
		// expected sum = 0x1B_000000 = 27
		
		#10 Din4 = 64'hFE_FE8000_00000000; // -1.005859375
		// expected sum = 0x14_FE8000 = 20.994140625

		#10 $finish;
	end
	
endmodule
