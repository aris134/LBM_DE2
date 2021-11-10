module tb_weights_reg();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter WIDTH = 64*9;

	logic Reset;
	logic signed [WIDTH-1:0] Data_Out;
	
	weights_reg #(.WIDTH(WIDTH)) weights_reg0 (.*);
	
	initial begin
		Reset = 1;
		
		#10 Reset = 0;
		
		#10 Reset = 1;
		
		#20 $finish;
	end
	
endmodule
