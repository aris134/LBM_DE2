module tb_zero_extend();

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter INPUT_WIDTH=4;
	parameter OUTPUT_WIDTH=8;
	
	logic [INPUT_WIDTH-1:0] Data_In;
	logic [OUTPUT_WIDTH-1:0] Data_Out;
	
	zero_extend #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)) zextend (.*);

	initial begin
		#5 Data_In = 4'b0000;
		
		#5 Data_In = 4'b0101;
		
		#5 Data_In = 4'b1111;
		
		#10 $finish;
	end
	
endmodule

