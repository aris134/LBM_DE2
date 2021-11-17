module tb_distribution_ram();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter DEPTH = 16*16;
	parameter ADDRESS_WIDTH = $clog2(DEPTH);
	parameter DATA_WIDTH = 32*9;
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	logic [ADDRESS_WIDTH-1:0] address;
	logic Clk;
	logic WE;
	logic signed [DATA_WIDTH-1:0] data_in;
	logic signed [DATA_WIDTH-1:0] data_out;
	
	distribution_ram #(.DEPTH(DEPTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ram0 (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Clk = 0;
		WE = 0;
		address = 8'h00;
		#10 data_in = 5;
		#12 WE = 1'b1;
		#12 address = 8'h12;
		#10 data_in = 6;
		#20 WE = 1'b0;
		#10 address = 8'h00;
		#20 $finish;
	end

endmodule
