module tb_reg32();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter WIDTH = 64;
	parameter CLK_PERIOD = 20; // 50 MHz clock

	logic Clk;
	logic Reset;
	logic LD_EN;
	logic signed [WIDTH-1:0] Data_In;
	logic signed [WIDTH-1:0] Data_Out;
	
	reg32 #(.WIDTH(WIDTH)) reg0 (.*);
	
	always #(CLK_PERIOD / 2) Clk = ~Clk;
	
	initial begin
		Reset = 1;
		LD_EN = 1;
		Clk = 0;
		Data_In = 64'h0000_0000_0000_0000;
		
		#10 Reset = 0;
		
		#10 Reset = 1;
		
		#10 LD_EN = 1;
		Data_In = 64'h1234_5678_0000_0000;
		
		#20 $finish;
	end
	
endmodule
