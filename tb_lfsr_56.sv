module tb_lfsr_56();

	timeunit 1ns;
	timeprecision 1ns;

	parameter CLK_PERIOD = 20;
	
	logic Clk;
	logic Reset;
	logic [55:0] seed;
	logic [55:0] pseudo_rand;
	
	lfsr_56 lfsr (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Reset = 0;
		Clk = 0;
		seed = 56'h1010_1010_1010_10;
		
		#10 Reset = 1;
		
		#100 $finish;
	end
	
endmodule
