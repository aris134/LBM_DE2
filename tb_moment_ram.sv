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
	logic signed [DATA_WIDTH-1:0] mem_array [DEPTH-1:0];
	
	moment_ram #(.DEPTH(DEPTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ram0 (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Clk = 0;
		WE = 1;
		address = 8'h00;
		data_in = 32'h01_000000;//00000000;
		#10 $finish;
	end

endmodule
