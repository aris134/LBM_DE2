module tb_bc_addr_iter();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter GRID_DIM = 16*16;
	parameter ADDRESS_WIDTH=$clog2(GRID_DIM);
	parameter CLK_PERIOD = 20; // 50 MHz clock
	
	logic Clk;
	logic Reset;
	logic Enable;
	logic [ADDRESS_WIDTH-1:0] address;
	
	bc_addr_iter #(.GRID_DIM(GRID_DIM), .ADDRESS_WIDTH(ADDRESS_WIDTH)) bc_addr (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Clk = 0;
		Reset = 1;
		Enable = 0;
		
		#10 Reset = 0;
		
		#15 Reset = 1;
		#5 Enable = 1;
		
		#5125 $finish;
	end
	
endmodule
