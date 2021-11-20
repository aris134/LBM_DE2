module tb_gaussian();

	timeunit 1ns;
	timeprecision 1ns;

	parameter CLK_PERIOD = 20;
	parameter DATA_WIDTH = 32;
	parameter FRACTIONAL_BITS = 24;
	parameter OFFSET=32'hFF_FC28F6;
	parameter SHIFTAMT=6;
	
	
	logic Clk;
	logic Enable;
	logic Reset;
	logic signed [FRACTIONAL_BITS:0] seed;
	logic signed [DATA_WIDTH-1:0] randnum;
	integer gauss_data;
	
	gaussian #(.DATA_WIDTH(DATA_WIDTH), .FRACTIONAL_BITS(FRACTIONAL_BITS), .OFFSET(OFFSET), .SHIFTAMT(SHIFTAMT)) gaus (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		gauss_data = $fopen("gaussian_output.txt");
		$fmonitor(gauss_data, "%b", randnum);
		
		Reset = 0;
		Clk = 0;
		Enable = 1;
		seed = 25'b1110111001011000000000000;
		
		#10 Reset = 1;
		
		#5000000 $finish;//#96433600 $finish; 5 * 10^6 samples just like in paper
	end
	
endmodule
