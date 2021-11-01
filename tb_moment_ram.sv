module tb_moment_ram();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter DEPTH = 16*16;
	parameter ADDRESS_WIDTH = $clog2(DEPTH);
	parameter DATA_WIDTH = 32;
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	logic [ADDRESS_WIDTH-1:0] address;
	logic Clk;
	logic WE;
	logic signed [DATA_WIDTH-1:0] data_in;
	logic signed [DATA_WIDTH-1:0] data_out;
	
	moment_ram #(.DEPTH(DEPTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ram0 (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Clk = 0;
		WE = 1;
		address = 8'h00;
		data_in = 8'h01;
		/*
		#10 data_in = 32'h1234_5678;
		#12 WE = 1'b1;
		#12 address = 8'h12;
		#2	 data_in = 32'hABCC_CDEF;
		#20 WE = 1'b0;
		#10 $finish;
		*/
		#10 address = 8'h01;
		#20 address = 8'h02;
		#20 address = 8'h03;
		#10 $finish;
	end

endmodule
